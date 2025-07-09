import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart'; // Tu BibliotecaA ajustada para autor
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Autores/ModuloLecA.dart';
import 'package:spotibook2/Pages/Index/Settings/ConfiguracionporUsuario/ConfiguracionAut.dart'; 
import 'package:spotibook2/Services/Firestore_service.dart'; // Importa FirestoreService
import 'package:spotibook2/Pages/Index/Autores/NotificacionesA.dart'; // Importación para NotificacionesA
import 'package:spotibook2/Pages/Index/Foros/ForosporUsuario/ForosAutores.dart'; // Para navegar a Foros

class CatalogoA extends StatefulWidget {
  const CatalogoA({super.key});

  @override
  State<CatalogoA> createState() => _CatalogoAState();
}

class _CatalogoAState extends State<CatalogoA> {
  int _selectedIndex = 0;
  int _paginaActual = 0; // Para controlar las pestañas internas del catálogo
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> _books = [];
  bool _isLoadingBooks = true; // Para controlar el estado de carga de los libros
  String? _booksError; // Para manejar errores en la carga de libros

  // Las páginas se inicializan dinámicamente.
  List<Widget> _paginas = []; // Inicializamos con una lista vacía
  bool _isPageContentInitialized = false; // Nuevo flag para controlar la inicialización de las páginas

  @override
  void initState() {
    super.initState();
    _initializePageContent(); // Función para manejar la inicialización del contenido de las páginas
  }

  // Función para manejar la inicialización del contenido de las páginas de autor.
  // Ahora carga directamente todos los libros, sin depender del UID del autor para el filtrado.
  Future<void> _initializePageContent() async {
    // Primero, muestra un indicador de carga mientras se obtienen los datos iniciales
    if (mounted) {
      setState(() {
        _isPageContentInitialized = false;
        // Se asignan CircularProgressIndicator a _paginas para mostrar un estado de carga inicial.
        _paginas = [
          const Center(child: CircularProgressIndicator()),
          const Center(child: CircularProgressIndicator()),
          const Center(child: CircularProgressIndicator()),
          const Center(child: CircularProgressIndicator()),
        ];
      });
    }

    // Carga todos los libros del catálogo, ya que el autor también interactúa como lector.
    await _fetchAllBooks();

    // Una vez que los datos están listos, actualiza _paginas con el contenido real
    if (mounted) {
      setState(() {
        _paginas = [
          _buildLibros(), // Mostrar todos los libros con imágenes dinámicas
          _buildNovedades(), // Novedades relevantes para autores (y lectores)
          _buildRecomendaciones(), // Recomendaciones relevantes para autores (y lectores)
          _buildGeneros(), // Géneros, relevantes para tendencias
        ];
        _isPageContentInitialized = true; // Marca que el contenido de las páginas está listo
      });
    }
  }

  // Obtiene *todos* los libros del catálogo desde Firestore.
  // Esta función reemplaza a _fetchAuthorBooks para mostrar el catálogo completo.
  Future<void> _fetchAllBooks() async {
    setState(() {
      _isLoadingBooks = true;
      _booksError = null;
    });
    try {
      // Llama a FirestoreService para obtener todos los libros publicados,
      // sin filtrar por un autor específico, ya que esta vista es para ver el catálogo general.
      final fetchedBooks = await FirestoreService().getAllBooks();
      if (mounted) {
        setState(() {
          _books = fetchedBooks;
          _isLoadingBooks = false;
        });
      }
    } catch (e) {
      print("Error al cargar libros del catálogo: $e");
      if (mounted) {
        setState(() {
          _booksError = 'No se pudieron cargar los libros del catálogo. Intenta de nuevo más tarde.';
          _isLoadingBooks = false;
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
      case 0: // Catálogo (current page)
        break;
      case 1: // BuscarA
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BuscarA()));
        break;
      case 2: // AgregarA (Opción específica de autor)
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

  // Widget para mostrar los libros con imágenes cargadas dinámicamente
  Widget _buildLibros() {
    if (_isLoadingBooks) {
      return const Center(child: CircularProgressIndicator());
    } else if (_booksError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text(
                _booksError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchAllBooks, // Botón para reintentar la carga del catálogo completo
                child: const Text('Reintentar Carga'),
              ),
            ],
          ),
        ),
      );
    } else if (_books.isEmpty) {
      return const Center(child: Text('No hay libros disponibles en el catálogo en este momento.', style: TextStyle(fontSize: 16, color: Colors.grey)));
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 libros por fila
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65, // Ajusta la relación de aspecto (ancho/alto) de los ítems
        ),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          // Asume que 'portadaUrlPublica' es la propiedad para la URL de la portada pública de cualquier libro.
          final imageUrl = book['portadaUrlPublica'] as String?;

          return GestureDetector(
            onTap: () {
              // Cuando se toque un libro, navega a ModuloLecA.
              // Pasa los datos COMPLETO del libro para que ModuloLecA pueda mostrar el título, descripción, etc.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModuloLecA(bookData: book), // Pasa el mapa completo del libro
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
              child: ClipRRect(
                // Recorta la imagen con los bordes redondeados
                borderRadius: BorderRadius.circular(10),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
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
                      )
                    : Container( // Si no hay URL de imagen, muestra un placeholder
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.book, size: 50, color: Colors.grey[600]),
                        ),
                      ),
              ),
            ),
          );
        },
      );
    }
  }

  // Novedades para Autores (ej. noticias del gremio, nuevas herramientas)
  // Se mantiene el contenido específico para autores, aunque se muestren todos los libros.
  static Widget _buildNovedades() {
    return const Center(child: Text("Novedades 🆕", style: TextStyle(fontSize: 16, color: Colors.grey)));
  }

  // Recomendaciones para Autores (ej. consejos de escritura, marketing)
  // Se mantiene el contenido específico para autores, aunque se muestren todos los libros.
  static Widget _buildRecomendaciones() {
    return const Center(child: Text("Recomendaciones 💡", style: TextStyle(fontSize: 16, color: Colors.grey)));
  }
  
  // Géneros con ExpansionTile (Relevante para que los autores vean tendencias)
  // Se mantiene el contenido específico para autores, aunque se muestren todos los libros.
  static Widget _buildGeneros() {
    return ListView(
      children: <Widget>[
        ExpansionTile(
          title: const Text("Ficción", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff2E4D4D))),
          leading: const Text("📚", style: TextStyle(fontSize: 24)),
          children: const <Widget>[
            ListTile(title: Text("Novelas", style: TextStyle(color: Colors.grey))),
            ListTile(title: Text("Cuentos Cortos", style: TextStyle(color: Colors.grey))),
            ListTile(title: Text("Literatura Contemporánea", style: TextStyle(color: Colors.grey))),
          ],
        ),
        ExpansionTile(
          title: const Text("No Ficción", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff2E4D4D))),
          leading: const Text("📂", style: TextStyle(fontSize: 24)),
          children: const <Widget>[
            ListTile(title: Text("Biografías", style: TextStyle(color: Colors.grey))),
            ListTile(title: Text("Historia", style: TextStyle(color: Colors.grey))),
            ListTile(title: Text("Ciencias", style: TextStyle(color: Colors.grey))),
          ],
        ),
        // Puedes añadir más géneros relevantes para autores aquí (ej. Autoayuda, Negocios)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Catálogo", // Título ajustado para autores (ahora muestra el catálogo general)
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications), // Icono de campana
            color: Colors.white, // Color blanco
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificacionesA()), // Navega a NotificacionesA.dart
              );
            },
          ),
        ],
      ),
      // --- Inicio del Drawer (Menú lateral) ---
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
            // Opciones específicas para autores (se mantienen)
            ListTile(
              title: const Text('Publicar Libro'),
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
            // Opciones generales que también son relevantes para autores
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
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForosAutores())); // Navega a ForosAutores
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context); // Close the drawer
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
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SingIn()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      // --- Fin del Drawer ---
      body: _isPageContentInitialized // Muestra un indicador de carga si las páginas no están listas
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIconTab(Icons.book, "Catálogo General", 0), // Texto ajustado para reflejar que es el catálogo completo
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
            )
          : const Center(child: CircularProgressIndicator()), // Indicador de carga central
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
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'), // Para que el autor agregue libros
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      // --- Fin del BottomNavigationBar ---
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