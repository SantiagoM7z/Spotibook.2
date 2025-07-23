import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Notificaciones.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Settings/ConfiguracionporUsuario/ConfiguracionLec.dart';
import 'package:spotibook2/Services/Firestore_service.dart'; // Importar FirestoreService
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para obtener el usuario actual
import 'package:spotibook2/Pages/Index/Lectores/ModuloLec.dart';
import 'package:spotibook2/Pages/Index/Foros/ForosporUsuario/ForosLectores.dart';

class Biblioteca extends StatefulWidget {
  const Biblioteca({super.key});

  @override
  State<Biblioteca> createState() => _BibliotecaState();
}

class _BibliotecaState extends State<Biblioteca> {
  int _selectedIndex = 2; // Índice para 'Biblioteca' en la BottomNavigationBar
  int _paginaActual = 0;
  final PageController _pageController = PageController();

  bool isAuthor = false; // Se actualizará dinámicamente
  String? currentUserId; // Para almacenar el UID del usuario actual

  // Mapas para almacenar los libros por categoría de la biblioteca
  final Map<String, List<Map<String, dynamic>>> _userBooks = {
    'librosEnProgreso': [],
    'librosLeidos': [],
    'librosFavoritos': [],
    // 'librosDescargados' sería diferente, posiblemente manejado localmente
  };
  bool _isLoadingBooks = true;
  String? _booksError;

  @override
  void initState() {
    super.initState();
    _checkUserTypeAndLoadLibrary();
  }

  Future<void> _checkUserTypeAndLoadLibrary() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      final userType = await FirestoreService().getUserType(user.uid);
      if (mounted) {
        setState(() {
          isAuthor = (userType == 'Autor');
        });
      }
      await _loadUserBooks(); // Carga los libros de la biblioteca del usuario
    } else {
      if (mounted) {
        setState(() {
          _isLoadingBooks = false;
          _booksError = "Usuario no autenticado.";
        });
      }
    }
  }

  Future<void> _loadUserBooks() async {
    if (currentUserId == null) return;

    setState(() {
      _isLoadingBooks = true;
      _booksError = null;
    });

    try {
      final prog = await FirestoreService().getUserLibraryBooks(currentUserId!, 'librosEnProgreso');
      final read = await FirestoreService().getUserLibraryBooks(currentUserId!, 'librosLeidos');
      final fav = await FirestoreService().getUserLibraryBooks(currentUserId!, 'librosFavoritos');

      if (mounted) {
        setState(() {
          _userBooks['librosEnProgreso'] = prog;
          _userBooks['librosLeidos'] = read;
          _userBooks['librosFavoritos'] = fav;
          _isLoadingBooks = false;
        });
      }
    } catch (e) {
      print("Error al cargar la biblioteca del usuario: $e");
      if (mounted) {
        setState(() {
          _booksError = 'Error al cargar tu biblioteca. Intenta de nuevo.';
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
      case 0: // Catálogo
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Catalogo()));
        break;
      case 1: // Buscar
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Buscar()));
        break;
      case 2: // Biblioteca (current page)
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

  // Widget genérico para mostrar una lista de libros en la biblioteca
  Widget _buildBookListForCategory(String categoryKey) {
    if (_isLoadingBooks) {
      return const Center(child: CircularProgressIndicator());
    } else if (_booksError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text(
                _booksError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserBooks, // Botón para reintentar la carga
                child: Text('Reintentar Carga'),
              ),
            ],
          ),
        ),
      );
    }

    final books = _userBooks[categoryKey] ?? [];

    if (books.isEmpty) {
      String message;
      switch (categoryKey) {
        case 'librosEnProgreso': message = 'No tienes libros en progreso.'; break;
        case 'librosLeidos': message = 'No has marcado ningún libro como leído.'; break;
        case 'librosFavoritos': message = 'Aún no tienes libros favoritos.'; break;
        // case 'librosDescargados': message = 'No hay libros descargados.'; break; // Esto requerirá manejo de archivos locales
        default: message = 'No hay libros en esta categoría.';
      }
      return Center(child: Text(message));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 libros por fila
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65, // Ajusta la relación de aspecto
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final imageUrl = book['portadaUrl'] as String?;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Biblioteca",
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionLec())); // Navigate to ConfiguracionLec
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconTab(Icons.book, "En Progreso", 0),
                _buildIconTab(Icons.check_circle, "Leído", 1),
                _buildIconTab(Icons.favorite, "Favoritos", 2),
                _buildIconTab(Icons.download, "Descargados", 3), // Nota: 'Descargados' requerirá manejo local
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
              children: [
                _buildBookListForCategory('librosEnProgreso'),
                _buildBookListForCategory('librosLeidos'),
                _buildBookListForCategory('librosFavoritos'),
                const Center(child: Text("Libros Descargados (Implementación Local Pendiente) ⬇️")), // Placeholder para descargados
              ],
            ),
          ),
        ],
      ),
      // --- Inicio del BottomNavigationBar (puedes moverlo a un widget separado como AppBottomNavBar) ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xff2E4D4D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
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