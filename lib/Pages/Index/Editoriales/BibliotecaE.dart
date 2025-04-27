import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart'; // Importa AuthService
import 'package:spotibook2/Pages/Index/Editoriales/PerfilE.dart';
import 'AgregarE.dart'; // Asegúrate de importar la página SubirE.dart
import 'package:spotibook2/Pages/Inicio/SingIn.dart';

class BibliotecaE extends StatefulWidget {
  const BibliotecaE({super.key});

  @override
  State<BibliotecaE> createState() => _BibliotecaEState();
}

class _BibliotecaEState extends State<BibliotecaE> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navegar a la vista de Biblioteca
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BibliotecaE()));
    } else if (index == 3) {
      // Navegar a la vista del Perfil
      Navigator.push(context, MaterialPageRoute(builder: (_) => PerfilE()));
    } else if (index == 2) {
      // Navegar a la vista de SubirE (la pantalla de subir)
      Navigator.push(context, MaterialPageRoute(builder: (_) => AgregarE()));
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Biblioteca"),
        backgroundColor: Color(0xff2E4D4D),
      ),
      body: Center(
        child: Text("Aquí se mostrarán los libros en progreso y terminados 📚"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xff2E4D4D)),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color(0xff2E4D4D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          // Biblioteca en el lado izquierdo
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Biblioteca',
          ),
          // El botón de "subir" estará en el medio
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Subir',
          ),
          // Perfil en el lado derecho
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
