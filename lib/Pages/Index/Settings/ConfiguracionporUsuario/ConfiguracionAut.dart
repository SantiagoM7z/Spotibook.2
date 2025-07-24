import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart'; // Para navegar de vuelta al CatalogoA
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart'; // Para navegar a BuscarA
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart'; // Para navegar a PerfilA
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart'; // Para navegar a BibliotecaA
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart'; import 'package:spotibook2/Pages/Index/Settings/Idioma.dart';
import 'package:spotibook2/Pages/Index/Settings/Noti.dart';
import 'package:spotibook2/Pages/Index/Settings/Pago.dart';
import 'package:spotibook2/Pages/Index/Settings/SoportConf.dart';
import 'package:spotibook2/Pages/Index/Settings/TemaConf.dart';
import 'package:spotibook2/Pages/Suport/HelpCenter.dart';
import 'package:spotibook2/Pages/Suport/TermsYCond.dart';

class ConfiguracionAut extends StatefulWidget {
  const ConfiguracionAut({super.key});

  @override
  State<ConfiguracionAut> createState() => _ConfiguracionAutState();
}

class _ConfiguracionAutState extends State<ConfiguracionAut> {
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
              MaterialPageRoute(builder: (_) => CatalogoA()),
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
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Configuración del tema'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TermsYCond()),
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
                MaterialPageRoute(builder: (_) => HelpCenter()),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'), // Para que el autor agregue libros
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'), // El nombre de la pestaña sigue siendo "Biblioteca" aquí
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
