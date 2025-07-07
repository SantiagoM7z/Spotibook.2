import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart';
import 'package:spotibook2/Pages/Index/Settings/Configuracion.dart'; // Importar Configuracion si la usan los autores
// import 'package:spotibook2/Services/Firestore_service.dart'; // Si vas a buscar en Firestore

class BuscarA extends StatefulWidget {
  const BuscarA({super.key});

  @override
  State<BuscarA> createState() => _BuscarAState();
}

class _BuscarAState extends State<BuscarA> {
  final TextEditingController _controller = TextEditingController();
  // Esta lista 'libros' es solo para el ejemplo.
  // En una aplicación real, cargarías los libros desde Firestore.
  List<String> libros = [
    "Cien años de soledad",
    "El principito",
    "Don Quijote de la Mancha",
    "Harry Potter",
    "Crónica de una muerte anunciada",
    "Rayuela",
    "La Sombra del Viento",
    "Fahrenheit 451",
    "1984",
    "Orgullo y Prejuicio",
  ];
  List<String> resultados = [];

  // El índice para "Buscar" es 1 en tu BottomNavigationBar
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    resultados = libros; // Inicialmente muestra todos los libros
  }

  // TODO: En una aplicación real, esta función debería interactuar con Firestore.
  // void _buscar(String query) async {
  //   if (query.isEmpty) {
  //     setState(() {
  //       resultados = []; // O todos los libros, si prefieres
  //     });
  //     return;
  //   }
  //   // Ejemplo de cómo llamarías a un servicio de Firestore:
  //   // List<Map<String, dynamic>> fetchedBooks = await FirestoreService().searchBooks(query);
  //   // setState(() {
  //   //   resultados = fetchedBooks.map((book) => book['titulo'] as String).toList();
  //   // });

  //   // Mientras tanto, para el ejemplo con lista estática:
  //   setState(() {
  //     resultados = libros
  //         .where((libro) =>
  //             libro.toLowerCase().contains(query.toLowerCase()))
  //         .toList();
  //   });
  // }
  // Para este ejemplo, mantenemos la búsqueda local.
  void _buscar(String query) {
    setState(() {
      if (query.isEmpty) {
        resultados = libros; // Muestra todos los libros si la búsqueda está vacía
      } else {
        resultados = libros
            .where((libro) =>
                libro.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }


  void _onItemTapped(int index) {
    // Si el índice ya es el seleccionado, no hacemos nada
    if (_selectedIndex == index) return;

    // Actualizamos el índice seleccionado
    setState(() {
      _selectedIndex = index;
    });

    // Usamos Navigator.pushReplacement para una navegación limpia
    switch (index) {
      case 0: // CatálogoA
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CatalogoA()));
        break;
      case 1: // BuscarA (Esta es la página actual, no navegamos si ya estamos aquí)
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
            hintText: "Buscar libros...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true, // Para que el teclado aparezca al entrar
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white), // Color del ícono del drawer
      ),
      body: ListView.builder(
        itemCount: resultados.length,
        itemBuilder: (context, index) {
          // TODO: En una aplicación real, aquí mostrarías un widget de tarjeta de libro más elaborado.
          return ListTile(
            title: Text(resultados[index]),
            // onTap: () {
            //   // TODO: Navegar a la página de detalles del libro, pasando los datos del libro
            //   // Navigator.push(context, MaterialPageRoute(builder: (_) => ModuloLec(bookData: bookDataMap)));
            // },
          );
        },
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Configuracion()));
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
      // --- Inicio del BottomNavigationBar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xff2E4D4D),
        selectedItemColor: Colors.white, // Resalta el ítem seleccionado en blanco
        unselectedItemColor: Colors.grey[400], // Ítems no seleccionados en un gris más claro
        type: BottomNavigationBarType.fixed, // Asegura que todos los ítems sean visibles
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