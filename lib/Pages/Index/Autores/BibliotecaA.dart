import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Autores/NotificacionesA.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart'; // Para que los autores agreguen libros
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Settings/Configuracion.dart'; // Si el autor tiene acceso a configuración

class BibliotecaA extends StatefulWidget {
  const BibliotecaA({super.key});

  @override
  State<BibliotecaA> createState() => _BibliotecaAState();
}

class _BibliotecaAState extends State<BibliotecaA> {
  // Ajustamos el _selectedIndex para que la Biblioteca sea el índice 3 según tu BottomNavigationBar actual.
  int _selectedIndex = 3;
  int _paginaActual = 0; // Para controlar las pestañas internas de la biblioteca del autor
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Aquí podrías inicializar la carga de datos del autor si es necesario
  }

  void _onItemTapped(int index) {
    // Si el índice actual ya es el seleccionado, no hacemos nada para evitar recargas innecesarias.
    if (_selectedIndex == index) return;

    // Actualizamos el índice seleccionado para que el BottomNavigationBar se resalte correctamente.
    setState(() {
      _selectedIndex = index;
    });

    // Usamos Navigator.pushReplacement para todas las navegaciones del BottomNavigationBar
    // para que no se acumulen páginas en la pila.
    switch (index) {
      case 0: // CatálogoA
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CatalogoA()));
        break;
      case 1: // BuscarA
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BuscarA()));
        break;
      case 2: // AgregarA (Ahora es la pestaña "Agregar" en el BottomNavigationBar)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AgregarA()));
        break;
      case 3: // BibliotecaA (Esta es la página actual, así que no navegamos, solo actualizamos el índice si venimos de otra forma)
        // No hay necesidad de navegar si ya estamos en esta página.
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

  // Actualizamos las páginas internas para que sean relevantes para un autor.
  // Aquí es donde iría la lógica para cargar los libros del autor desde tu FirestoreService.
  final List<Widget> _paginasAutor = [
    // TODO: Implementar la visualización de libros publicados por el autor.
    Center(child: Text("Mis Libros Publicados 📚", style: TextStyle(fontSize: 16))),
    // TODO: Implementar la visualización de libros o solicitudes en revisión/pendientes.
    Center(child: Text("En Revisión/Pendientes ⏳", style: TextStyle(fontSize: 16))),
    // TODO: Implementar la visualización de borradores o libros no publicados aún.
    Center(child: Text("Mis Borradores ✏️", style: TextStyle(fontSize: 16))),
    // TODO: Implementar la visualización de estadísticas de los libros del autor.
    Center(child: Text("Estadísticas de Mis Libros 📊", style: TextStyle(fontSize: 16))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mi Biblioteca (Autor)", // Título más descriptivo
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white), // Para el ícono del drawer
        leading: Builder( // Permite abrir el Drawer
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
      // --- Inicio del Drawer (Menú lateral) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xff2E4D4D)),
              child: Text(
                'Menú del Autor',
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
              leading: const Icon(Icons.add_circle_outline), // Un ícono relevante
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                // Navega directamente a la página de agregar libro
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
              leading: const Icon(Icons.logout), // Un ícono relevante
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconTab(Icons.upload_file, "Publicados", 0), // Ícono para libros subidos
                _buildIconTab(Icons.hourglass_empty, "En Revisión", 1), // Ícono para libros pendientes
                _buildIconTab(Icons.edit, "Borradores", 2), // Ícono para borradores
                _buildIconTab(Icons.insights, "Estadísticas", 3), // Ícono para estadísticas
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
              children: _paginasAutor, // Usamos las páginas relevantes para el autor
            ),
          ),
        ],
      ),
      // --- Inicio del BottomNavigationBar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xff2E4D4D),
        selectedItemColor: Colors.white, // Resalta el ítem seleccionado en blanco
        unselectedItemColor: Colors.grey[400], // Ítems no seleccionados en un gris más claro
        type: BottomNavigationBarType.fixed, // Asegura que todos los ítems sean visibles y no se desplacen
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'), // "Agregar" para publicar libros
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