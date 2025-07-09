import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Services/firestore_service.dart'; // ¡Importamos el servicio de Firestore REAL!
import 'package:spotibook2/Pages/Index/Lectores/Notificaciones.dart'; // Para navegar a la pantalla de notificaciones
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el UID real del usuario

// Importaciones de navegación y autenticación (se mantienen)
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Settings/ConfiguracionporUsuario/ConfiguracionLec.dart';

// Importa la nueva pantalla de detalle de hilo
import 'package:spotibook2/Pages/Index/Foros/Hilos.dart'; // ¡Ahora sabemos que la clase se llama Hilos!
// Importa el widget de la tarjeta de hilo
import 'package:spotibook2/Pages/Index/Foros/ThreadCard.dart';


class ForosLectores extends StatefulWidget {
  const ForosLectores({super.key});

  @override
  State<ForosLectores> createState() => _ForosLectoresState();
}

class _ForosLectoresState extends State<ForosLectores> with SingleTickerProviderStateMixin {
  late TabController _tabController; // Controla la selección de pestañas
  String? _currentUserId; // Almacena el UID real del usuario actual
  final FirestoreService _firestoreService = FirestoreService(); // Instancia de tu servicio Firestore

  // Conjunto para almacenar los IDs de los foros principales que el usuario sigue
  Set<String> _followedForumIds = {};

  // Variable para el título dinámico de la AppBar
  String _currentAppBarTitle = "Principal"; // Estado inicial del título

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 pestañas (Principal y Descubrir)

    // Agregamos un listener al TabController para cambiar el título de la AppBar
    _tabController.addListener(_handleTabSelection);

    _loadCurrentUserAndFollowedForums(); // Carga el UID del usuario y los foros seguidos
  }

  // Método para manejar la selección de pestañas y actualizar el título de la AppBar
  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        if (_tabController.index == 0) {
          _currentAppBarTitle = "Principal";
        } else {
          _currentAppBarTitle = "Descubrir";
        }
      });
    }
  }

  // Método para obtener el UID del usuario actualmente autenticado y sus foros seguidos
  void _loadCurrentUserAndFollowedForums() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
      // Ahora, carga los IDs de los foros principales que este usuario sigue
      // Escucha los cambios en todos los foros para mantener _followedForumIds actualizado
      _firestoreService.getAllForums().listen((allForums) {
        final Set<String> tempFollowedIds = {};
        for (var forum in allForums) {
          // Accede al campo 'miembros_foro' directamente del documento del foro principal
          final List<dynamic> miembrosForo = forum['miembros_foro'] ?? [];
          if (miembrosForo.contains(_currentUserId)) {
            tempFollowedIds.add(forum['id'] as String); // Añade el ID del foro si el usuario es miembro
          }
        }
        if (mounted) {
          setState(() {
            _followedForumIds = tempFollowedIds;
          });
        }
      }, onError: (error) {
        print("Error al cargar foros para determinar seguimiento: $error");
      });
    } else {
      print("Advertencia: No hay usuario autenticado.");
      setState(() {
        _currentUserId = null;
        _followedForumIds = {}; // Limpia los foros seguidos si no hay usuario
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // ¡IMPORTANTE! Remover el listener
    _tabController.dispose(); // Es crucial liberar el TabController cuando el widget se destruye
    super.dispose();
  }

  // Método para construir la lista de hilos/posts para una pestaña específica
  Widget _buildThreadFeedList({required bool showOnlyFollowed}) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getThreadsCollectionGroup(), // ¡Obtenemos TODOS los hilos de CUALQUIER foro!
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Muestra un indicador de carga
        }
        if (snapshot.hasError) {
          print("Error en StreamBuilder de hilos (Collection Group): ${snapshot.error}"); // Imprime el error para depuración
          return Center(child: Text('Error al cargar hilos: ${snapshot.error}\nPor favor, asegúrate de tener el índice de grupo de colecciones para "hilos" en Firestore.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay hilos disponibles en la comunidad.')); // Mensaje si no hay datos
        }

        // Filtra los hilos/posts basándose en si su FORO PADRE es seguido por el usuario.
        final List<Map<String, dynamic>> allThreads = snapshot.data!;
        final List<Map<String, dynamic>> filteredThreads = allThreads.where((thread) {
          final String? forumIdOfThread = thread['forumId'] as String?; // ID del foro padre del hilo

          if (forumIdOfThread == null) {
            return false; // Si un hilo no tiene forumId, no lo consideramos para el filtro
          }

          // Verifica si el foro padre de este hilo está en el conjunto de foros seguidos
          final bool isForumFollowed = _followedForumIds.contains(forumIdOfThread);

          if (showOnlyFollowed) {
            // Para la pestaña "Principal": el foro padre del hilo DEBE ser seguido.
            return isForumFollowed;
          } else {
            // Para la pestaña "Descubrir": el foro padre del hilo NO DEBE ser seguido.
            return !isForumFollowed;
          }
        }).toList();

        // Si después de filtrar no hay hilos en esta categoría.
        if (filteredThreads.isEmpty) {
          return Center(
            child: Text(showOnlyFollowed
                ? 'Aún no sigues ningún hilo en esta sección Principal.' // Mensaje para "Principal"
                : 'No hay hilos disponibles en la sección Descubrir en este momento.'), // Mensaje para "Descubrir"
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: filteredThreads.length,
          itemBuilder: (context, index) {
            final thread = filteredThreads[index];
            // Asegúrate de que estos campos existan en tus documentos de hilo
            final String titulo = thread['titulo'] ?? 'Sin título';
            final String autorPostName = thread['autorpostname'] ?? 'Anónimo';
            final String contenido = thread['contenido'] ?? 'Sin contenido.';
            final String threadId = thread['id']; // El ID del documento del hilo
            final String forumId = thread['forumId'] ?? ''; // El ID del foro padre

            return ThreadCard(
              forumId: forumId, // ¡Pasamos el ID del foro padre!
              threadId: threadId,
              title: titulo,
              authorName: autorPostName,
              contentPreview: contenido,
              currentUserId: _currentUserId, // Pasa el UID del usuario actual
              // AÑADIMOS EL CALLBACK onTap para navegar a la pantalla de Hilos
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Hilos( // ¡CORREGIDO: Usamos la clase 'Hilos' directamente!
                      forumId: forumId,
                      threadId: threadId,
                      threadTitle: titulo, // Pasamos el título del hilo
                      currentUserId: _currentUserId, // Pasamos el UID del usuario actual
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El título de la AppBar ahora será dinámico y cambiará con el swipe
        title: Text(
          _currentAppBarTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff2E4D4D), // Color de fondo de la barra superior
        iconTheme: const IconThemeData(color: Colors.white), // Color de los iconos en la barra superior
        // Botón de notificaciones a la derecha
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications), // Icono de notificaciones
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notificaciones()), // Navega a la pantalla de notificaciones
              );
            },
          ),
        ],
        // ¡IMPORTANTE! Eliminamos la propiedad 'bottom' para quitar el TabBar visible
        // bottom: TabBar(...) // Esta sección ha sido eliminada
      ),
      // Si necesitas un Drawer para otras opciones de navegación (configuración, cerrar sesión, etc.)
      // puedes añadirlo aquí.
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff2E4D4D),
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            //! AQUI VA LA LISTA DE LOS FOROS
            const Divider(), // Divisor visual
            ListTile(
              title: const Text('Catálogo'),
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Catalogo())); // Navigate to Configuracion
              },
            ),
            ListTile(
              title: const Text('Plan de Suscripción'),
              leading: const Icon(Icons.subscriptions),
              onTap: () {
                Navigator.pop(context);
                print("Plan de Suscripción");
                // TODO: Navegar a la página del plan de suscripción
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionLec())); // Navigate to Configuracion
              },
            ),
            const Divider(), // Divisor visual
            ListTile(
              title: const Text('Cerrar sesión'),
              leading: const Icon(Icons.logout),
              onTap: () async {
                await AuthService().signOut();
                if (mounted) { // Asegura que el widget sigue montado
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SingIn()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      // Cuerpo de la pantalla, que muestra el contenido de las pestañas
      body: TabBarView(
        controller: _tabController, // Asocia el TabController para cambiar el contenido
        children: [
          // Contenido de la pestaña "Principal" (anteriormente "Foros que sigo")
          _buildThreadFeedList(showOnlyFollowed: true),
          // Contenido de la pestaña "Descubrir" (anteriormente "Foros públicos")
          _buildThreadFeedList(showOnlyFollowed: false),
        ],
      ),
    );
  }
}