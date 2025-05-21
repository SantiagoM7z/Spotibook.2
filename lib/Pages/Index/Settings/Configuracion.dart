import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Pages/Index/Settings/Idioma.dart';
import 'package:spotibook2/Pages/Index/Settings/Noti.dart';
import 'package:spotibook2/Pages/Index/Settings/Pago.dart';
import 'package:spotibook2/Pages/Index/Settings/SoportConf.dart';
import 'package:spotibook2/Pages/Index/Settings/TemaConf.dart';

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  final int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Catalogo()),
      );
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
        backgroundColor: Color(0xff2E4D4D),
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
