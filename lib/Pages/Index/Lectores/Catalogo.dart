import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Notificaciones.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Lectores/ModuloLec.dart'; // Asegúrate de que este import exista
import 'package:spotibook2/Pages/Index/Settings/ConfiguracionporUsuario/ConfiguracionLec.dart';
import 'package:spotibook2/Services/Firestore_service.dart'; // Importa FirestoreService
import 'package:spotibook2/Pages/Index/Foros/ForosporUsuario/ForosLectores.dart'; 

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  int _selectedIndex = 0;
  int _paginaActual = 0;
  final PageController _pageController = PageController();

  // Lista para almacenar los datos completos de los libros, no solo las URLs
  List<Map<String, dynamic>> _books = [];
  bool _isLoadingBooks = true; // Para controlar el estado de carga de los libros
  String? _booksError; // Para manejar errores en la carga de libros

  // --- CAMBIO CLAVE AQUÍ: Inicializar _paginas inmediatamente ---
  List<Widget> _paginas = []; // Inicializamos con una lista vacía
  bool _isPageContentInitialized = false; // Nuevo flag para controlar la inicialización de las páginas

  @override
  void initState() {
    super.initState();
    _initializePageContent(); // Nueva función para manejar la inicialización
  }

  // Nueva función para manejar la inicialización del contenido de las páginas
  Future<void> _initializePageContent() async {
    // Primero, muestra un indicador de carga mientras se obtienen los datos iniciales
    if (mounted) {
      setState(() {
        _isPageContentInitialized = false;
        _paginas = [
          const Center(child: CircularProgressIndicator()),
          const Center(child: CircularProgressIndicator()),
          const Center(child: CircularProgressIndicator()),
          const Center(child: CircularProgressIndicator()),
        ];
      });
    }

    // AÑADIDO: Llama a _fetchBooks() para cargar los datos reales del catálogo.
    await _fetchBooks();

    // Una vez que los datos están listos, actualiza _paginas con el contenido real
    if (mounted) {
      setState(() {
        _paginas = [
          _buildLibros(), // Mostrar libros con imágenes dinámicas
          _buildNovedades(), // Novedades 🆕
          _buildRecomendaciones(), // Recomendaciones 💡
          _buildCategorias(), // Géneros con ExpansionTile
        ];
        _isPageContentInitialized = true; // Marca que el contenido de las páginas está listo
      });
    }
  }

  // Obtiene los libros reales de Firestore
  Future<void> _fetchBooks() async {
    setState(() {
      _isLoadingBooks = true;
      _booksError = null;
    });
    try {
      final fetchedBooks = await FirestoreService().getAllBooks();
      if (mounted) {
        setState(() {
          _books = fetchedBooks;
          _isLoadingBooks = false;
        });
      }
    } catch (e) {
      print("Error al cargar libros desde Firestore: $e");
      if (mounted) {
        setState(() {
          _booksError = 'No se pudieron cargar los libros. Intenta de nuevo más tarde.';
          _isLoadingBooks = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    // Si ya estamos en la página actual del BottomNavigationBar, no hacemos nada.
    // La página 0 es Catálogo, que es esta misma página.
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    // Usamos pushReplacement para evitar acumular rutas y mantener limpia la pila de navegación.
    switch (index) {
      case 0: // Catálogo (current page) - No necesita navegación ya que estamos aquí
        break;
      case 1: // Buscar
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Buscar()));
        break;
      case 2: // Biblioteca
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Biblioteca()));
        break;
      case 3: // Perfil
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Perfil()));
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

  // Mostrar libros con imágenes cargadas dinámicamente desde Firestore
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
                onPressed: _fetchBooks, // Botón para reintentar la carga
                child: const Text('Reintentar Carga'),
              ),
            ],
          ),
        ),
      );
    } else if (_books.isEmpty) {
      return const Center(child: Text('No hay libros disponibles en este momento.'));
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
          final imageUrl = book['portadaUrlPublica'] as String?; // Asegúrate de usar 'portadaUrlPublica'

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModuloLec(bookData: book), // Pasa el mapa completo del libro
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

  // Novedades 🆕 (Aún placeholders - deben cargarse desde Firestore)
  Widget _buildNovedades() {
    return const Center(child: Text("Novedades 🆕", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }

  // Recomendaciones 💡 (Aún placeholders - deben cargarse desde Firestore)
  Widget _buildRecomendaciones() {
    return const Center(child: Text("Recomendaciones 💡", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }

  // Categorías con ExpansionTile (Aún placeholders - deben cargarse desde Firestore)
  Widget _buildCategorias() {
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
        // Puedes añadir más categorías aquí, idealmente cargadas desde Firestore.
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Catálogo",
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
            icon: const Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notificaciones()),
              );
            },
          ),
        ],
      ),
      // --- Inicio del Drawer (puedes moverlo a un widget separado como AppDrawer) ---
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForosLectores())); 
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
      // --- Fin del Drawer ---
      body: _isPageContentInitialized // Muestra un indicador de carga si las páginas no están listas
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIconTab(Icons.book, "Libros", 0),
                      _buildIconTab(Icons.fiber_new, "Novedades", 1),
                      _buildIconTab(Icons.lightbulb, "Recomendaciones", 2),
                      _buildIconTab(Icons.category, "Categorías", 3),
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
      // --- Inicio del BottomNavigationBar (puedes moverlo a un widget separado como AppBottomNavBar) ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        backgroundColor: const Color(0xff2E4D4D),
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
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