import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart'; 
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart'; 
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart'; 
import 'package:spotibook2/Pages/Index/Settings/Idioma.dart';
import 'package:spotibook2/Pages/Index/Settings/Noti.dart';
import 'package:spotibook2/Pages/Index/Settings/Pago.dart';
import 'package:spotibook2/Pages/Index/Settings/SoportConf.dart';
import 'package:spotibook2/Pages/Index/Settings/TemaConf.dart';

class ConfiguracionLec extends StatefulWidget {
  const ConfiguracionLec({super.key});

  @override
  State<ConfiguracionLec> createState() => _ConfiguracionLecState();
}

class _ConfiguracionLecState extends State<ConfiguracionLec> {
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
        title: Text(
          "Configuración",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xff2E4D4D),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Catalogo()),
            );
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Idioma'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Idioma()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notificaciones'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Noti()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Pago'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Pago()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.support_agent),
            title: Text('Soporte Técnico'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SoportConf()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Configuración del tema'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TemaConf()),
              );
            },
          ),
          Divider(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xff2E4D4D),
        type: BottomNavigationBarType.fixed, // Asegura que todos los ítems sean visibles y no se desplacen
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catalogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
