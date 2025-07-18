import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Notificaciones.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Lectores/ModuloLec.dart';
import 'package:spotibook2/Pages/Index/Settings/ConfiguracionporUsuario/ConfiguracionLec.dart';
import 'package:spotibook2/Services/Firestore_service.dart';
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

  List<Map<String, dynamic>> _books = [];
  bool _isLoadingBooks = true;
  String? _booksError;

  List<String> _tags = [];
  bool _isLoadingTags = true;
  String? _tagsError;

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
        // Muestra indicadores de carga iniciales para todas las páginas
        _paginas = [
          const Center(child: CircularProgressIndicator()),
          const Center(child: CircularProgressIndicator()),
          const Center(child: CircularProgressIndicator()),
          const Center(child: CircularProgressIndicator()),
        ];
      });
    }

    // Carga las etiquetas y los libros principales
    await _fetchTags();
    await _fetchBooks();

    if (mounted) {
      setState(() {
        _paginas = [
          _buildLibros(), // Mostrar todos los libros
          _buildNovedades(),
          _buildRecomendaciones(),
          _buildCategorias(), // Ahora usará las etiquetas cargadas
        ];
        _isPageContentInitialized = true;
      });
    }
  }

  Future<void> _fetchTags() async {
    setState(() {
      _isLoadingTags = true;
      _tagsError = null;
    });
    try {
      final fetchedTags = await FirestoreService().loadTags();
      if (mounted) {
        setState(() {
          _tags = fetchedTags.map((tag) => tag['nombre'] as String).toList();
          _isLoadingTags = false;
        });
      }
    } catch (e) {
      print("Error al cargar etiquetas desde Firestore: $e");
      if (mounted) {
        setState(() {
          _tagsError = 'No se pudieron cargar los géneros. Intenta de nuevo más tarde.';
          _isLoadingTags = false;
        });
      }
    }
  }

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
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Buscar()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Biblioteca()));
        break;
      case 3:
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

    // Si la pestaña de "Libros" es seleccionada, volvemos a cargar todos los libros
    // para asegurar que se muestre el catálogo completo y no un filtro previo de género.
    if (index == 0) {
      _fetchBooks();
    }
  }

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
                onPressed: _fetchBooks,
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
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          final imageUrl = book['portadaUrlPublica'] as String?;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModuloLec(bookData: book),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow( // Corregido: BoxShadow
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

  Widget _buildNovedades() {
    return const Center(child: Text("Novedades 🆕", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }

  Widget _buildRecomendaciones() {
    return const Center(child: Text("Recomendaciones 💡", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }

  Widget _buildCategorias() {
    if (_isLoadingTags) {
      return const Center(child: CircularProgressIndicator());
    } else if (_tagsError != null) {
      return Center(
        child: Text(_tagsError!, style: const TextStyle(color: Colors.red)),
      );
    } else if (_tags.isEmpty) {
      return const Center(child: Text('No hay géneros disponibles en este momento.'));
    } else {
      return ListView.builder(
        itemCount: _tags.length,
        itemBuilder: (context, index) {
          final tag = _tags[index];
          return ExpansionTile(
            title: Text(tag, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            leading: const Text("📚", style: TextStyle(fontSize: 24)),
            children: <Widget>[
              ListTile(
                title: Text("Ver todos los libros de $tag"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BooksByTagScreen(tag: tag),
                    ),
                  );
                },
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
              },
            ),
            ListTile(
              title: const Text('Foros'),
              leading: const Icon(Icons.forum),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForosLectores()));
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionLec()));
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
                      _buildIconTab(Icons.book, "Libros", 0),
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
          : const Center(child: CircularProgressIndicator()),
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

// NUEVO WIDGET: Pantalla para mostrar libros por etiqueta
class BooksByTagScreen extends StatefulWidget {
  final String tag;

  const BooksByTagScreen({super.key, required this.tag});

  @override
  State<BooksByTagScreen> createState() => _BooksByTagScreenState();
}

class _BooksByTagScreenState extends State<BooksByTagScreen> {
  List<Map<String, dynamic>> _books = [];
  bool _isLoadingBooks = true;
  String? _booksError;

  @override
  void initState() {
    super.initState();
    _fetchBooksByTag();
  }

  Future<void> _fetchBooksByTag() async {
    setState(() {
      _isLoadingBooks = true;
      _booksError = null;
    });
    try {
      final fetchedBooks = await FirestoreService().getBooksByTag(widget.tag);
      if (mounted) {
        setState(() {
          _books = fetchedBooks;
          _isLoadingBooks = false;
        });
      }
    } catch (e) {
      print("Error al cargar libros por etiqueta '${widget.tag}' desde Firestore: $e");
      if (mounted) {
        setState(() {
          _booksError = 'No se pudieron cargar los libros para el género ${widget.tag}.';
          _isLoadingBooks = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Género: ${widget.tag}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingBooks
          ? const Center(child: CircularProgressIndicator())
          : _booksError != null
              ? Center(
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
                          onPressed: _fetchBooksByTag,
                          child: const Text('Reintentar Carga'),
                        ),
                      ],
                    ),
                  ),
                )
              : _books.isEmpty
                  ? Center(child: Text('No hay libros para el género "${widget.tag}" en este momento.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: _books.length,
                      itemBuilder: (context, index) {
                        final book = _books[index];
                        final imageUrl = book['portadaUrlPublica'] as String?;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModuloLec(bookData: book),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow( // Corregido: BoxShadow
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
                    ),
    );
  }
}