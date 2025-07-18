import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Autores/ModuloLecA.dart';
import 'package:spotibook2/Pages/Index/Settings/ConfiguracionporUsuario/ConfiguracionAut.dart';
import 'package:spotibook2/Services/Firestore_service.dart'; // Importa FirestoreService
import 'package:spotibook2/Pages/Index/Autores/NotificacionesA.dart';
import 'package:spotibook2/Pages/Index/Foros/ForosporUsuario/ForosAutores.dart';

class CatalogoA extends StatefulWidget {
  const CatalogoA({super.key});

  @override
  State<CatalogoA> createState() => _CatalogoAState();
}

class _CatalogoAState extends State<CatalogoA> {
  int _selectedIndex = 0;
  int _paginaActual = 0; // Para controlar las pestañas internas del catálogo
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> _allBooks = []; // Para todos los libros
  bool _isLoadingAllBooks = true;
  String? _allBooksError;

  // Mapa para almacenar los libros cargados por cada género
  final Map<String, List<Map<String, dynamic>>> _genreBooksCache = {};
  // Mapa para almacenar el estado de carga por género
  final Map<String, bool> _isLoadingGenreBooks = {};
  // Mapa para almacenar errores de carga por género
  final Map<String, String?> _genreBooksError = {};

  // Almacenaremos tanto el ID como el nombre de las etiquetas
  List<Map<String, dynamic>> _tags = [];
  bool _isLoadingTags = true; // Para controlar la carga de etiquetas
  String? _tagsError; // Para manejar errores en la carga de etiquetas

  List<Widget> _paginas = [];
  bool _isPageContentInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePageContent();
  }

  Future<void> _initializePageContent() async {
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

    await _fetchTags(); // Cargar géneros disponibles
    await _fetchAllBooks(); // Cargar todos los libros inicialmente

    if (mounted) {
      setState(() {
        _paginas = [
          _buildLibros(), // Mostrar todos los libros
          _buildNovedades(), // Novedades relevantes para autores (y lectores)
          _buildRecomendaciones(), // Recomendaciones relevantes para autores (y lectores)
          _buildCategorias(), // Categorías (géneros), relevantes para tendencias
        ];
        _isPageContentInitialized = true;
      });
    }
  }

  // Carga todos los libros del catálogo
  Future<void> _fetchAllBooks() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAllBooks = true;
      _allBooksError = null;
    });
    try {
      final fetchedBooks = await FirestoreService().getAllBooks();
      if (mounted) {
        setState(() {
          _allBooks = fetchedBooks;
          _isLoadingAllBooks = false;
        });
      }
    } catch (e) {
      print("Error al cargar todos los libros: $e");
      if (mounted) {
        setState(() {
          _allBooksError = 'No se pudieron cargar los libros del catálogo. Intenta de nuevo más tarde.';
          _isLoadingAllBooks = false;
        });
      }
    }
  }

  // Carga las etiquetas (géneros)
  Future<void> _fetchTags() async {
    if (!mounted) return;
    setState(() {
      _isLoadingTags = true;
      _tagsError = null;
    });
    try {
      final fetchedTags = await FirestoreService().loadTags();
      if (mounted) {
        setState(() {
          _tags = fetchedTags;
          _isLoadingTags = false;
        });
      }
    } catch (e) {
      print("Error al cargar etiquetas: $e");
      if (mounted) {
        setState(() {
          _tagsError = 'No se pudieron cargar los géneros. Intenta de nuevo más tarde.';
          _isLoadingTags = false;
        });
      }
    }
  }

  // Nuevo: Carga libros filtrados por el NOMBRE del género para el ExpansionTile
  Future<void> _fetchBooksForGenre(String tagName) async {
    if (_isLoadingGenreBooks[tagName] == true || _genreBooksCache.containsKey(tagName)) {
      return; // Ya se está cargando o ya se cargó
    }

    if (!mounted) return;
    setState(() {
      _isLoadingGenreBooks[tagName] = true;
      _genreBooksError[tagName] = null;
    });
    try {
      // Usar el método getBooksByTag que ahora resuelve el nombre a ID en FirestoreService
      final fetchedBooks = await FirestoreService().getBooksByTag(tagName);
      if (mounted) {
        setState(() {
          _genreBooksCache[tagName] = fetchedBooks;
          _isLoadingGenreBooks[tagName] = false;
        });
      }
    } catch (e) {
      print("Error al cargar libros para el género '$tagName': $e");
      if (mounted) {
        setState(() {
          _genreBooksError[tagName] = 'No se pudieron cargar los libros para este género.';
          _isLoadingGenreBooks[tagName] = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    // Mantiene la página superior actual si se queda en el Catálogo
    // En el caso de "Autores", si estaba en Generos y se va al Botón de Catálogo,
    // se mantiene en Generos para no perder el contexto, pero esta vez
    // no se resetea el filtro aquí, ya que el filtro está dentro de _buildCategorias.
    if (index == 0) { // Si vuelve a la pestaña "Catálogo" (inferior)
      _pageController.jumpToPage(_paginaActual); // Se mantiene en la sub-pestaña actual (ej. Generos)
    }


    switch (index) {
      case 0: // Catálogo (current page)
        // No hay necesidad de recargar todos los libros aquí,
        // ya que la lógica de filtro está ahora en _buildCategorias
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
      // No hay necesidad de resetear filtro aquí, ya que el filtro está encapsulado en _buildCategorias.
    });
  }

  // Widget para mostrar todos los libros (cuando no hay filtro de género activo)
  Widget _buildLibros() {
    if (_isLoadingAllBooks) {
      return const Center(child: CircularProgressIndicator());
    } else if (_allBooksError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text(
                _allBooksError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchAllBooks,
                child: const Text('Reintentar Carga'),
              ),
            ],
          ),
        ),
      );
    } else if (_allBooks.isEmpty) {
      return const Center(child: Text(
        'No hay libros disponibles en el catálogo en este momento.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.center,
      ));
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 libros por fila
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65, // Ajusta la relación de aspecto (ancho/alto) de los ítems
        ),
        itemCount: _allBooks.length,
        itemBuilder: (context, index) {
          final book = _allBooks[index];
          final imageUrl = book['portadaUrlPublica'] as String?;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModuloLecA(bookData: book),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
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
                    : Container(
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

  static Widget _buildNovedades() {
    return const Center(child: Text("Novedades 🆕", style: TextStyle(fontSize: 16, color: Colors.grey)));
  }

  static Widget _buildRecomendaciones() {
    return const Center(child: Text("Recomendaciones 💡", style: TextStyle(fontSize: 16, color: Colors.grey)));
  }

  // MODIFICADO: Ahora el _buildCategorias muestra directamente los libros dentro del ExpansionTile
  Widget _buildCategorias() {
    if (_isLoadingTags) {
      return const Center(child: CircularProgressIndicator());
    } else if (_tagsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text(
                _tagsError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchTags, // Botón para reintentar la carga de etiquetas
                child: const Text('Reintentar Carga de Géneros'),
              ),
            ],
          ),
        ),
      );
    } else if (_tags.isEmpty) {
      return const Center(child: Text('No hay géneros disponibles en este momento.', style: TextStyle(fontSize: 16, color: Colors.grey)));
    } else {
      return ListView.builder(
        itemCount: _tags.length,
        itemBuilder: (context, index) {
          final tag = _tags[index]; // Cada 'tag' es un Map<String, dynamic> {id: ..., nombre: ...}
          final tagName = tag['nombre'] as String; // Obtenemos el nombre del género

          return ExpansionTile(
            title: Text(tagName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff2E4D4D))),
            leading: const Text("📚", style: TextStyle(fontSize: 24)),
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                // Cuando se expande, cargamos los libros para este género
                _fetchBooksForGenre(tagName);
              }
            },
            children: <Widget>[
              _isLoadingGenreBooks[tagName] == true
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _genreBooksError[tagName] != null
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(_genreBooksError[tagName]!, style: const TextStyle(color: Colors.red)),
                              ElevatedButton(
                                onPressed: () => _fetchBooksForGenre(tagName),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      : (_genreBooksCache[tagName] != null && _genreBooksCache[tagName]!.isNotEmpty)
                          ? SizedBox(
                              height: 250, // Altura fija para el GridView dentro del ExpansionTile
                              child: GridView.builder(
                                padding: const EdgeInsets.all(10),
                                scrollDirection: Axis.horizontal, // Desplazamiento horizontal
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1, // Una fila de libros
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.5, // Ajustar para que las portadas se vean bien horizontalmente
                                ),
                                itemCount: _genreBooksCache[tagName]!.length,
                                itemBuilder: (context, bookIndex) {
                                  final book = _genreBooksCache[tagName]![bookIndex];
                                  final imageUrl = book['portadaUrlPublica'] as String?;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ModuloLecA(bookData: book),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 150, // Ancho fijo para cada tarjeta de libro
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
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
                                            : Container(
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: Icon(Icons.book, size: 50, color: Colors.grey),
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No hay libros disponibles en este género.', style: TextStyle(color: Colors.grey)),
                            ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Catálogo", // El título del AppBar es fijo, ya que los filtros se ven dentro de Géneros
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
                MaterialPageRoute(builder: (context) => const NotificacionesA()),
              );
            },
          ),
        ],
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
                'Menú de Autor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: const Text('Publicar Libro'),
              leading: const Icon(Icons.add_circle_outline),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AgregarA()));
              },
            ),
            ListTile(
              title: const Text('Mis Estadísticas'),
              leading: const Icon(Icons.insights),
              onTap: () {
                Navigator.pop(context);
                print("Navegar a Mis Estadísticas de Autor");
              },
            ),
            ListTile(
              title: const Text('Plan de Suscripción'),
              leading: const Icon(Icons.subscriptions),
              onTap: () {
                Navigator.pop(context);
                print("Plan de Suscripción");
              },
            ),
            ListTile(
              title: const Text('Foros'),
              leading: const Icon(Icons.forum),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForosAutores()));
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionAut()));
              },
            ),
            const Divider(),
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
      body: _isPageContentInitialized
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIconTab(Icons.book, "Libros", 0), // Cambiado a "Libros" para ser más general
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
                        // No hay necesidad de resetear el filtro aquí, ya que el manejo de libros
                        // por género está encapsulado en _buildCategorias.
                        // Cuando cambias de pestaña superior (ej. a Novedades), los géneros no están activos.
                      });
                    },
                    children: _paginas,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
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