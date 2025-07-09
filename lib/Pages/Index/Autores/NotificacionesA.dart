import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart'; // Para navegar de vuelta al CatalogoA
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart'; // Para navegar a BuscarA
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart'; // Para navegar a PerfilA
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart'; // Para navegar a BibliotecaA
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart'; // Para navegar a AgregarA
import 'package:spotibook2/Pages/Index/Settings/ConfiguracionporUsuario/ConfiguracionAut.dart'; // Para navegar a Configuracion
import 'package:spotibook2/Pages/Inicio/SingIn.dart'; // Para Cerrar sesión
import 'package:spotibook2/Pages/Index/Foros/ForosporUsuario/ForosAutores.dart'; // Para navegar a Foros

class NotificacionesA extends StatefulWidget {
  const NotificacionesA({super.key});

  @override
  State<NotificacionesA> createState() => _NotificacionesAState();
}

class _NotificacionesAState extends State<NotificacionesA> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // CatálogoA
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CatalogoA()));
        break;
      case 1: // BuscarA
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BuscarA()));
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
        title: const Text(
          "Notificaciones de Autor", // Título de la AppBar para la página de Notificaciones de Autor
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff2E4D4D), // Color de fondo de la AppBar
        iconTheme: const IconThemeData(color: Colors.white), // Color de los iconos en la AppBar
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Icono de hamburguesa para abrir el Drawer
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Abre el menú lateral
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        // --- INICIO DE LA NUEVA ADICIÓN (Icono de campana) ---
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications), // Icono de campana
            color: Colors.white, // Color blanco
            onPressed: () {
              // Ya estamos en NotificacionesA, no necesitamos navegar a sí misma.
              // Podrías recargar el contenido de notificaciones aquí si fuera dinámico.
              print("Botón de Notificaciones presionado en NotificacionesA.");
            },
          ),
        ],
        // --- FIN DE LA NUEVA ADICIÓN ---
      ),
      // --- Inicio del Drawer (Menú lateral) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Elimina el padding por defecto del ListView
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff2E4D4D), // Color de fondo del encabezado del Drawer
              ),
              child: Text(
                'Menú de Autor', // Título del encabezado del Drawer
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Opciones específicas para autores (replicadas de CatalogoA)
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
            ListTile(
              title: const Text('Plan de Suscripción'),
              leading: const Icon(Icons.subscriptions),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                print("Navegar a Plan de Suscripción");
                // TODO: Aquí iría la navegación a la página del plan de suscripción
              },
            ),
            ListTile(
              title: const Text('Foros'),
              leading: const Icon(Icons.forum),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForosAutores())); 
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionAut())); // Navega a la página de Configuración
              },
            ),
            const Divider(), // Divisor visual para separar opciones
            ListTile(
              title: const Text('Cerrar sesión'),
              leading: const Icon(Icons.logout), // Icono para "Cerrar sesión"
              onTap: () async {
                await AuthService().signOut(); // Llama al servicio de autenticación para cerrar sesión
                if (mounted) { // Asegura que el widget sigue montado antes de realizar la navegación
                  // Navega a la pantalla de inicio de sesión y elimina todas las rutas anteriores
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

      // --- Cuerpo de la página de Notificaciones ---
      body: const Center(
        child: Text(
          "Contenido de Notificaciones de Autor", // Contenido principal de la página
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff2E4D4D)),
        ),
      ),
      // --- Fin del cuerpo ---

      // --- Inicio del BottomNavigationBar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // El índice del ítem actualmente seleccionado
        onTap: _onItemTapped, // Función que se llama al tocar un ítem
        selectedItemColor: Colors.white, // Color del ítem seleccionado
        unselectedItemColor: Colors.grey[400], // Color de los ítems no seleccionados
        backgroundColor: const Color(0xff2E4D4D), // Color de fondo del BottomNavigationBar
        type: BottomNavigationBarType.fixed, // Asegura que todos los ítems sean visibles y no se desplacen
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'), // Para que el autor agregue libros
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'), // El nombre de la pestaña sigue siendo "Biblioteca" aquí
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      // --- Fin del BottomNavigationBar ---
    );
  }
}