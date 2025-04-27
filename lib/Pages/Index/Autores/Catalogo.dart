import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart'; // Importa AuthService
import 'package:spotibook2/Pages/Index/Autores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Autores/Perfil.dart';
import 'package:spotibook2/Pages/Index/Autores/Biblioteca.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  int _selectedIndex = 0; // Para controlar la pestaña seleccionada
  bool isAuthor = false; // Variable para determinar si el usuario es autor o lector
  
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Catalogo",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xff2E4D4D),
        iconTheme: IconThemeData(color: Colors.white),
        leading: null,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Para quitar el padding predeterminado
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff2E4D4D),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Si el usuario es autor
            if (isAuthor) ...[
              ListTile(
                title: Text('Publicar Libro'),
                onTap: () {
                  Navigator.pop(context); // Cierra el Drawer
                  print("Publicar Libro");
                },
              ),
            ],
            // Si el usuario es lector
            if (!isAuthor) ...[
              ListTile(
                title: Text('Plan de Suscripción'),
                onTap: () {
                  Navigator.pop(context); // Cierra el Drawer
                  print("Plan de Suscripción");
                },
              ),
              ListTile(
                title: Text('Foros'),
                onTap: () {
                  Navigator.pop(context); // Cierra el Drawer
                  print("Foros");
                },
              ),
              ListTile(
                title: Text('Biblioteca'),
                onTap: () {
                  Navigator.pop(context); // Cierra el Drawer
                  print("Biblioteca");
                },
              ),
            ],
            ListTile(
              title: Text('Configuración'),
              onTap: () {
                Navigator.pop(context); // Cierra el Drawer
                print("Configuración");
              },
            ),
            // Opción de "Cerrar sesión"
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () async {
                await AuthService().signOut(); // Cerrar sesión
                Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => SingIn()), // Redirigir al formulario de inicio de sesión
                (route) => false, // Asegura que la pantalla de inicio de sesión no quede en la pila de navegación
                );
              },
            ),
          ],
        ),
      ),
      body: cuerpo(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catalogo',),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar',),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca',),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil',),
        ],
      ),
    );
  }
}

Widget cuerpo() {
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/.png"), // Asegúrate de tener la imagen
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    ),
    child: Center(
      child: Text("Si"), // Aquí puedes personalizar el contenido de la página
    ),
  );
}
