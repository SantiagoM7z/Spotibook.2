import 'package:flutter/material.dart';
import 'Verificaciones.dart';
import 'Foros.dart';
import 'Editoriales.dart';
import 'CentroA.dart';

class Usuarios extends StatefulWidget {
  const Usuarios({super.key});

  @override
  State<Usuarios> createState() => _UsuariosState();
}

class _UsuariosState extends State<Usuarios> {
  final int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Verificaciones()));
        break;
      case 1:
        // Estamos aquí
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Editoriales()));
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
        title: const Text("Usuarios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(child: Text("Contenido de Usuarios")),
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
    );
  }
}
