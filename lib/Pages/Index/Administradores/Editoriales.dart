import 'package:flutter/material.dart';
import 'Verificaciones.dart';
import 'Usuarios.dart';
import 'Foros.dart';
import 'CentroA.dart';
import 'package:spotibook2/Services/Auth_Service.dart'; 
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
class Editoriales extends StatefulWidget {
  const Editoriales({super.key});

  @override
  State<Editoriales> createState() => _EditorialesState();
}

class _EditorialesState extends State<Editoriales> {
  final int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Verificaciones()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Usuarios()));
        break;
      case 2:
        // Estamos aquí
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Foros()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CentroA()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editoriales", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(child: Text("Contenido de Editoriales")),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xff2E4D4D),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xff2E4D4D),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Verificaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Editoriales'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Foros'),
          BottomNavigationBarItem(icon: Icon(Icons.help_center), label: 'Centro de ayuda'),
        ],
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
                await AuthService().signOut(); 
                Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => SingIn()),
                (route) => false, 
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
