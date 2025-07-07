import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart'; 
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart'; 
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart'; 
import 'package:spotibook2/Pages/Index/Settings/Configuracion.dart'; 
import 'package:spotibook2/Pages/Inicio/SingIn.dart';

class Notificaciones extends StatefulWidget {
  const Notificaciones({super.key});

  @override
  State<Notificaciones> createState() => _NotificacionesState();
}

class _NotificacionesState extends State<Notificaciones> {
  int _selectedIndex = 0; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: 
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Catalogo()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notificaciones", 
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
            ListTile(
              title: const Text('Plan de Suscripción'),
              leading: const Icon(Icons.subscriptions), 
              onTap: () {
                Navigator.pop(context); 
                print("Navegar a Plan de Suscripción");
                // TODO: Aquí iría la navegación a la página del plan de suscripción
              },
            ),
            ListTile(
              title: const Text('Foros'),
              leading: const Icon(Icons.forum), 
              onTap: () {
                Navigator.pop(context);
                print("Navegar a Foros");
                // TODO: Aquí iría la navegación a la página de foros
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings), 
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Configuracion()));
              },
            ),
            const Divider(), // Divisor visual para separar opciones
            ListTile(
              title: const Text('Cerrar sesión'),
              leading: const Icon(Icons.logout), // Icono para "Cerrar sesión"
              onTap: () async {
                await AuthService().signOut(); // Llama al servicio de autenticación para cerrar sesión
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

      body: const Center(
        child: Text(
          "Página de Notificaciones", 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff2E4D4D)),
        ),
      ),

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
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}