import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Autores/ModuloLecA.dart'; // Asegúrate de que esta importación sea correcta para el módulo de lectura de AUTORES
// Si necesitas interactuar con Dropbox para obtener las URLs de los libros,
// asegúrate de importar el servicio de Dropbox.
// import 'package:spotibook2/Services/DropboxService.dart'; // Descomenta si lo usas aquí directamente

class CatalogoA extends StatefulWidget {
  const CatalogoA({super.key});

  @override
  State<CatalogoA> createState() => _CatalogoAState();
}

class _CatalogoAState extends State<CatalogoA> {
  int _selectedIndex = 0;
  int _paginaActual = 0;
  final PageController _pageController = PageController();

  // Esta variable es importante. Para el Catálogo de Autores,
  // es probable que `isAuthor` sea siempre `true` o se determine al inicio de la sesión.
  bool isAuthor = true; // Asumiendo que esta vista es para autores

  // Aquí se agregan las páginas. _buildLibros ahora es un Widget que se construye
  // con un FutureBuilder para cargar las imágenes dinámicamente.
  late List<Widget> _paginas;

  // Lista para almacenar las URLs de las portadas de los libros del autor.
  List<String> _bookCoverUrls = [];

  @override
  void initState() {
    super.initState();
    // Iniciar la carga de las URLs de las portadas de los libros del autor.
    _fetchAuthorBookCovers();
    // Inicializamos las páginas DESPUÉS de iniciar la carga.
    _paginas = [
      _buildLibros(), // Mostrar libros con imágenes dinámicas
      _buildNovedades(), // Novedades 🆕
      _buildRecomendaciones(), // Recomendaciones 💡
      _buildGeneros(), // Géneros con ExpansionTile
    ];
  }

  // Simula la obtención de URLs de portadas de los libros del autor.
  // En una app real, esto llamaría a tu backend/DropboxService para obtener
  // los libros ESPECÍFICOS de este autor.
  Future<void> _fetchAuthorBookCovers() async {
    // === LÓGICA DE SIMULACIÓN PARA LIBROS DE AUTOR ===
    // En una aplicación real:
    // 1. Obtendrías el ID del autor actualmente logueado (por ejemplo, desde Firebase Auth).
    // 2. Consultarías tu base de datos (Firestore, Realtime DB) para encontrar los libros
    //    asociados a ese autor.
    // 3. De cada libro, extraerías la 'portadaUrlDropbox' que hayas guardado.
    //
    // Ejemplo de URLs de ejemplo.
    // IMPORTANTE: Reemplaza estas URLs con URLs REALES de TUS imágenes en Dropbox
    // que representen los libros de un autor.
    final List<String> dummyAuthorUrls = [
      'https://www.dropbox.com/scl/fi/a1b2c3d4e5f6a7b8c9d01/autor_libro1.jpg?rlkey=xxxxxx&raw=1', // <-- Reemplaza con tus URLs reales
      'https://www.dropbox.com/scl/fi/f0e9d8c7b6a5e4d3c2b10/autor_libro2.jpg?rlkey=yyyyyy&raw=1', // <-- Reemplaza con tus URLs reales
      'https://www.dropbox.com/scl/fi/b3c4d5e6f7a8b9c0d1e2/autor_libro3.jpg?rlkey=zzzzzz&raw=1', // <-- Reemplaza con tus URLs reales
      'https://www.dropbox.com/scl/fi/e2f3a4b5c6d7e8f90123/autor_libro4.jpg?rlkey=aaaaaa&raw=1', // <-- Reemplaza con tus URLs reales
      // Agrega más URLs de ejemplo de los libros de un autor aquí
    ];

    // Simula un retardo de red
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) { // Asegura que el widget sigue montado antes de llamar setState
      setState(() {
        _bookCoverUrls = dummyAuthorUrls;
      });
    }
  }

  void _onItemTapped(int index) {
    // Aquí el índice 0 es el catálogo principal, y los demás son navegaciones.
    // El ítem "Agregar" es el índice 2 en el BottomNavigationBar.
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => BuscarA()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AgregarA())); // Opción para agregar libro
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => BibliotecaA())); // Biblioteca del autor
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PerfilA()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _cambiarPagina(int index) {
    setState(() {
      _paginaActual = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // Mostrar libros con imágenes cargadas dinámicamente para el autor
  Widget _buildLibros() {
    return FutureBuilder<void>(
      future: _bookCoverUrls.isEmpty ? _fetchAuthorBookCovers() : Future.value(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _bookCoverUrls.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar tus libros: ${snapshot.error}'));
        } else if (_bookCoverUrls.isEmpty) {
          return const Center(child: Text('Aún no has subido ningún libro.'));
        } else {
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 libros por fila
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.65, // Ajusta la relación de aspecto (ancho/alto) de los ítems
            ),
            itemCount: _bookCoverUrls.length,
            itemBuilder: (context, index) {
              final imageUrl = _bookCoverUrls[index];
              return GestureDetector(
                onTap: () {
                  // Cuando se toque un libro, navega a ModuloLecA.
                  // Podrías pasar la URL de la imagen u otros detalles del libro a ModuloLecA aquí.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModuloLecA(), // ¡CORREGIDO: Ahora llama a ModuloLecA!
                      // Ejemplo de cómo pasar la URL si ModuloLecA la aceptara:
                      // builder: (context) => ModuloLecA(bookImageUrl: imageUrl),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Bordes redondeados
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // Sombra para un efecto 3D
                      ),
                    ],
                  ),
                  child: ClipRRect( // Recorta la imagen con los bordes redondeados
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        // Muestra un icono de error si la imagen no se carga
                        print('Error al cargar imagen: $imageUrl - $error');
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // Novedades 🆕 (Podría mostrar novedades de otros autores, o tus propias novedades)
  static Widget _buildNovedades() {
    return const Center(child: Text("Novedades para Autores 🆕", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }

  // Recomendaciones 💡 (Podría ser recomendaciones para el autor, ej. sobre marketing)
  static Widget _buildRecomendaciones() {
    return const Center(child: Text("Recomendaciones para Autores 💡", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }

  // Géneros con ExpansionTile (Relevante para ver qué géneros son populares)
  static Widget _buildGeneros() {
    return ListView(
      children: <Widget>[
        ExpansionTile(
          title: const Text("Ficción ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          leading: const Text("📚", style: TextStyle(fontSize: 24)),
          children: const <Widget>[
            ListTile(title: Text("Novelas")),
            ListTile(title: Text("Cuentos Cortos")),
            ListTile(title: Text("Literatura Contemporánea")),
          ],
        ),
        ExpansionTile(
          title: const Text("No Ficción ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          leading: const Text("📂", style: TextStyle(fontSize: 24)),
          children: const <Widget>[
            ListTile(title: Text("Biografías")),
            ListTile(title: Text("Historia")),
            ListTile(title: Text("Ciencias")),
          ],
        ),
        // Puedes añadir más géneros aquí
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Catálogo de Autor", // Título ajustado para autores
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff2E4D4D),
              ),
              child: Text(
                'Menú de Autor', // Menú ajustado para autores
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Opciones específicas para autores
            ListTile(
              title: const Text('Publicar Libro'),
              onTap: () {
                Navigator.pop(context);
                // Navegar a la página para agregar/publicar un libro
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AgregarA()));
              },
            ),
            ListTile(
              title: const Text('Mis Estadísticas'),
              onTap: () {
                Navigator.pop(context);
                print("Mis Estadísticas");
                // Navegar a una página de estadísticas del autor
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                print("Configuración");
              },
            ),
            ListTile(
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await AuthService().signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SingIn()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconTab(Icons.book, "Mis Libros", 0), // Texto ajustado
                _buildIconTab(Icons.fiber_new, "Novedades", 1),
                _buildIconTab(Icons.lightbulb, "Recomendaciones", 2),
                _buildIconTab(Icons.category, "Géneros", 3),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _paginaActual = index;
                });
              },
              children: _paginas,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xff2E4D4D),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xff2E4D4D),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'), // Nuevo ítem para autores
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Mis Libros'), // Cambiado de 'Biblioteca'
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildIconTab(IconData icono, String texto, int index) {
    final bool activo = _paginaActual == index;
    return GestureDetector(
      onTap: () => _cambiarPagina(index),
      child: Column(
        children: [
          Icon(
            icono,
            size: 30,
            color: activo ? const Color(0xff2E4D4D) : Colors.grey,
          ),
          const SizedBox(height: 5),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              color: activo ? const Color(0xff2E4D4D) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}