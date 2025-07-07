import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Settings/Configuracion.dart';
import 'package:spotibook2/Services/Firestore_service.dart'; // Importar FirestoreService
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para obtener el usuario actual
import 'package:spotibook2/Pages/Index/Lectores/ModuloLec.dart'; // Import para ModuloLec

class Buscar extends StatefulWidget {
  const Buscar({super.key});

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> resultados = []; // Ahora almacenará mapas de libros
  bool _isLoading = false;
  String? _searchError;

  int _selectedIndex = 1; // Índice para 'Buscar' en la BottomNavigationBar

  bool isAuthor = false; // Se actualizará dinámicamente
  String? currentUserId; // Para almacenar el UID del usuario actual

  @override
  void initState() {
    super.initState();
    _checkUserType(); // Verifica el tipo de usuario al iniciar
  }

  // Método para verificar el tipo de usuario
  Future<void> _checkUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      final userType = await FirestoreService().getUserType(user.uid);
      if (mounted) {
        setState(() {
          isAuthor = (userType == 'Autor'); // Asume 'Autor' es el userType para autores
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
      final fetchedResults = await FirestoreService().searchBooks(query);
      if (mounted) {
        setState(() {
          resultados = fetchedResults;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error al buscar libros en Firestore: $e");
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
      case 0: // Catálogo
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Catalogo()));
        break;
      case 1: // Buscar (current page)
        break;
      case 2: // Biblioteca
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Biblioteca()));
        break;
      case 3: // Perfil
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Perfil()));
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
            hintText: "Buscar libros, autores o editoriales...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
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
                Navigator.pop(context);
                print("Foros");
                // TODO: Navegar a la página de foros
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Configuracion())); // Navigate to Configuracion
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
      body: _isLoading
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
}