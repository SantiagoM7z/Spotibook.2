import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Lectores/ModuloLec.dart'; // Asegúrate de importar ModuloLec.dart correctamente
// Si necesitas interactuar con Dropbox para obtener las URLs de los libros,
// asegúrate de importar el servicio de Dropbox.
// import 'package:spotibook2/Services/DropboxService.dart'; // Descomenta si lo usas aquí directamente

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  int _selectedIndex = 0;
  int _paginaActual = 0;
  final PageController _pageController = PageController();

  // Esta variable indicaría si el usuario es autor.
  // En una aplicación real, esto se obtendría del estado de autenticación/perfil del usuario.
  bool isAuthor = false;

  // Aquí se agregan las páginas. _buildLibros ahora es un Widget que se construye
  // con un FutureBuilder para cargar las imágenes dinámicamente.
  late List<Widget> _paginas;

  // Lista para almacenar las URLs de las portadas de los libros.
  List<String> _bookCoverUrls = [];

  @override
  void initState() {
    super.initState();
    // Inicializamos las páginas DESPUÉS de haber cargado las URLs si es necesario.
    // O podemos hacer que _buildLibros maneje su propia carga asíncrona.
    _paginas = [
      _buildLibros(), // Mostrar libros con imágenes dinámicas
      _buildNovedades(), // Novedades 🆕
      _buildRecomendaciones(), // Recomendaciones 💡
      _buildCategorias(), // Gén con ExpansionTile
    ];
    // Iniciar la carga de las URLs de las portadas.
    _fetchBookCovers();
  }

  // Simula la obtención de URLs de portadas de libros.
  // En una app real, esto llamaría a tu backend/DropboxService.
  Future<void> _fetchBookCovers() async {
    // === LÓGICA DE SIMULACIÓN ===
    // En una aplicación real, aquí harías una llamada a tu backend (Firestore, etc.)
    // para obtener una lista de objetos de libro, cada uno con su 'portadaUrlDropbox'.
    //
    // Ejemplo de cómo obtendrías URLs de DropboxService (solo si tienes los nombres de los archivos):
    // List<String> filePathsInDropbox = ['/libros/libro_ejemplo1.jpg', '/libros/libro_ejemplo2.jpg'];
    // List<String> fetchedUrls = [];
    // final dropboxService = DropboxService();
    // for (String path in filePathsInDropbox) {
    //   String? url = await dropboxService.getSharedLink(path); // Necesitas un método getSharedLink público
    //   if (url != null) {
    //     fetchedUrls.add(url);
    //   }
    // }
    // setState(() {
    //   _bookCoverUrls = fetchedUrls;
    // });
    //
    // === URLs de ejemplo para pruebas ===
    // IMPORTANTE: Reemplaza estas URLs con URLs REALES de tus imágenes en Dropbox
    // cuando tengas tu integración lista y funcionando.
    // Puedes obtener URLs públicas de Dropbox para probar inicialmente.
    // Ejemplo de URL pública de Dropbox (reemplaza 'dl=0' con 'raw=1'):
    // 'https://www.dropbox.com/s/abcdef123456789/nombre_imagen.jpg?dl=0'
    // Se convierte en:
    // 'https://www.dropbox.com/s/abcdef123456789/nombre_imagen.jpg?raw=1'

    final List<String> dummyUrls = [
      'https://www.dropbox.com/scl/fi/c9c381e4b868e4a77e8a9/libro_ejemplo1.jpg?rlkey=xxxxxx&raw=1', // <-- Reemplaza con tus URLs reales
      'https://www.dropbox.com/scl/fi/b7e098d5c412e8f192b3a/libro_ejemplo2.jpg?rlkey=yyyyyy&raw=1', // <-- Reemplaza con tus URLs reales
      'https://www.dropbox.com/scl/fi/d1e2f3a4b5c6d7e8f9012/libro_ejemplo3.jpg?rlkey=zzzzzz&raw=1', // <-- Reemplaza con tus URLs reales
      'https://www.dropbox.com/scl/fi/e2f3a4b5c6d7e8f90123/libro_ejemplo4.jpg?rlkey=aaaaaa&raw=1', // <-- Reemplaza con tus URLs reales
      'https://www.dropbox.com/scl/fi/f3a4b5c6d7e8f9012345/libro_ejemplo5.jpg?rlkey=bbbbbb&raw=1', // <-- Reemplaza con tus URLs reales
      'https://www.dropbox.com/scl/fi/a4b5c6d7e8f901234567/libro_ejemplo6.jpg?rlkey=cccccc&raw=1', // <-- Reemplaza con tus URLs reales
      // Agrega más URLs de ejemplo o tus URLs reales de Dropbox aquí
    ];

    // Simula un retardo de red
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) { // Asegura que el widget sigue montado antes de llamar setState
      setState(() {
        _bookCoverUrls = dummyUrls;
      });
    }
  }


  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Buscar()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Biblioteca()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Perfil()));
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

  // Mostrar libros con imágenes cargadas dinámicamente
  Widget _buildLibros() {
    // Usamos FutureBuilder para esperar a que _bookCoverUrls se llene
    return FutureBuilder<void>(
      // Future que estamos esperando (la carga de las URLs).
      // En este caso, el `_fetchBookCovers` ya actualiza el estado,
      // por lo que el `FutureBuilder` es para asegurar que la UI se reconstruya
      // cuando las URLs estén listas. Una forma más directa sería pasar el Future
      // retornado por _fetchBookCovers directamente aquí si _fetchBookCovers retornara un Future<List<String>>.
      // Aquí, Future.value(_bookCoverUrls) es solo un truco para que FutureBuilder se ejecute
      // después de que _bookCoverUrls se haya actualizado.
      // Ojo: Si _fetchBookCovers fuera independiente y retornara un Future, sería así:
      // future: _fetchBookCovers(),
      // Pero como ya actualiza el estado, vamos a manejarlo de otra forma más simple:
      future: _bookCoverUrls.isEmpty ? _fetchBookCovers() : Future.value(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _bookCoverUrls.isEmpty) {
          // Si aún estamos cargando y no hay URLs, muestra un indicador de carga.
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Si hubo un error al cargar.
          return Center(child: Text('Error al cargar los libros: ${snapshot.error}'));
        } else if (_bookCoverUrls.isEmpty) {
          // Si no hay URLs después de la carga (ej. no hay libros disponibles).
          return const Center(child: Text('No hay libros disponibles en este momento.'));
        } else {
          // Si las URLs ya están cargadas, muestra el GridView.
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
                  // Cuando se toque un libro, navega a ModuloLec.
                  // Podrías pasar la URL de la imagen u otros detalles del libro a ModuloLec aquí.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModuloLec(),
                      // Ejemplo de cómo pasar la URL si ModuloLec la aceptara:
                      // builder: (context) => ModuloLec(bookImageUrl: imageUrl),
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

  // Novedades 🆕
  static Widget _buildNovedades() {
    return const Center(child: Text("Novedades 🆕", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }

  // Recomendaciones 💡
  static Widget _buildRecomendaciones() {
    return const Center(child: Text("Recomendaciones 💡", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }

  // Categorías con ExpansionTile
  static Widget _buildCategorias() {
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
        // Puedes añadir más categorías aquí
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
            if (isAuthor) ...[
              ListTile(
                title: const Text('Publicar Libro'),
                onTap: () {
                  Navigator.pop(context);
                  print("Publicar Libro");
                },
              ),
            ],
            if (!isAuthor) ...[
              ListTile(
                title: const Text('Plan de Suscripción'),
                onTap: () {
                  Navigator.pop(context);
                  print("Plan de Suscripción");
                },
              ),
              ListTile(
                title: const Text('Foros'),
                onTap: () {
                  Navigator.pop(context);
                  print("Foros");
                },
              ),
              ListTile(
                title: const Text('Biblioteca'),
                onTap: () {
                  Navigator.pop(context);
                  print("Biblioteca");
                },
              ),
            ],
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xff2E4D4D),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xff2E4D4D),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catálogo'), // Etiqueta corregida
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