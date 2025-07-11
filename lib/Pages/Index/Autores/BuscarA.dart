import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart';
import 'package:spotibook2/Pages/Index/Settings/ConfiguracionporUsuario/ConfiguracionAut.dart';
import 'package:spotibook2/Services/Firestore_service.dart'; // Importar FirestoreService
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para obtener el usuario actual
import 'package:spotibook2/Pages/Index/Lectores/ModuloLec.dart'; // Import para ModuloLec (si los autores también ven detalles de libros)


class BuscarA extends StatefulWidget {
  const BuscarA({super.key});

  @override
  State<BuscarA> createState() => _BuscarAState();
}

class _BuscarAState extends State<BuscarA> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> resultados = []; // Ahora almacenará mapas de libros
  bool _isLoading = false;
  String? _searchError;

  int _selectedIndex = 1; // El índice para 'Buscar' en la BottomNavigationBar

  bool isAuthor = false; // Se actualizará dinámicamente (copiado de Buscar.dart)
  String? currentUserId; // Para almacenar el UID del usuario actual (copiado de Buscar.dart)

  @override
  void initState() {
    super.initState();
    _checkUserType(); // Verifica el tipo de usuario al iniciar (copiado de Buscar.dart)
  }

  // Método para verificar el tipo de usuario (copiado de Buscar.dart)
  Future<void> _checkUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      // Asumiendo que FirestoreService.getUserType también existe para autores o que esta info no es crítica para la búsqueda.
      // Si la búsqueda debe variar por tipo de usuario, aquí podrías añadir esa lógica.
      final userType = await FirestoreService().getUserType(user.uid); 
      if (mounted) {
        setState(() {
          isAuthor = (userType == 'Autor'); 
        });
      }
    }
  }

  void _buscar(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        resultados = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchError = null;
    });

    try {
      // Usar el servicio de Firestore para buscar libros, como en Buscar.dart
      final fetchedResults = await FirestoreService().searchBooks(query);
      if (mounted) {
        setState(() {
          resultados = fetchedResults;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error al buscar libros en Firestore para autor: $e");
      if (mounted) {
        setState(() {
          _searchError = 'No se pudo completar la búsqueda. Intenta de nuevo.';
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // CatálogoA
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CatalogoA()));
        break;
      case 1: // BuscarA (current page)
        break;
      case 2: // AgregarA
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AgregarA()));
        break;
      case 3: // BibliotecaA
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BibliotecaA()));
        break;
      case 4: // PerfilA
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PerfilA()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: _buscar,
          decoration: const InputDecoration(
            hintText: "Buscar libros, autores o editoriales...", // Mismo hint que Buscar.dart
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder( // Añadir el ícono de menú para el Drawer como en Buscar.dart
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      // --- Inicio del Drawer (Menú lateral) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xff2E4D4D)),
              child: Text(
                'Menú del Autor', // Título para el autor
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
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
              title: const Text('Foros'),
              leading: const Icon(Icons.forum),
              onTap: () {
                Navigator.pop(context);
                print("Foros");
                // TODO: Navegar a la página de foros
              },
            ),
            ListTile(
              title: const Text('Publicar Nuevo Libro'),
              leading: const Icon(Icons.add_circle_outline),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AgregarA()));
              },
            ),
            ListTile(
              title: const Text('Mis Estadísticas'),
              leading: const Icon(Icons.insights),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                print("Navegar a Mis Estadísticas de Autor");
                // TODO: Navegar a una página de estadísticas del autor
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionAut()));
              },
            ),
            const Divider(), // Divisor visual
            ListTile(
              title: const Text('Cerrar sesión'),
              leading: const Icon(Icons.logout),
              onTap: () async {
                await AuthService().signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SingIn()),
                    (route) => false, // Elimina todas las rutas anteriores
                  );
                }
              },
            ),
          ],
        ),
      ),
      // --- Fin del Drawer ---
      body: _isLoading // Lógica de visualización de resultados (copiado de Buscar.dart)
          ? const Center(child: CircularProgressIndicator())
          : _searchError != null
              ? Center(
                  child: Text(_searchError!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                )
              : resultados.isEmpty && _controller.text.isNotEmpty
                  ? const Center(
                      child: Text('No se encontraron resultados.', style: TextStyle(fontSize: 16)),
                    )
                  : ListView.builder(
                      itemCount: resultados.length,
                      itemBuilder: (context, index) {
                        final book = resultados[index];
                        final imageUrl = book['portadaUrl'] as String?;

                        return ListTile(
                          leading: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 50,
                                  height: 75,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.book, size: 50),
                          title: Text(book['titulo'] ?? 'Título Desconocido'),
                          subtitle: Text('${book['autor'] ?? 'Autor Desconocido'} - ${book['editorial'] ?? 'Editorial Desconocida'}'),
                          onTap: () {
                            // Navegar al detalle del libro (ModuloLec)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModuloLec(bookData: book),
                              ),
                            );
                          },
                        );
                      },
                    ),
      // --- Inicio del BottomNavigationBar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xff2E4D4D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      // --- Fin del BottomNavigationBar ---
    );
  }
}