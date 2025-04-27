import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Autores/Buscar.dart'; 
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Services/Auth_Service.dart';

class Administradores extends StatefulWidget {
  const Administradores({super.key});

  @override
  State<Administradores> createState() => _AdministradoresState();
}

class _AdministradoresState extends State<Administradores> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Buscar()),);
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
          "Administradores",
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
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
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
              title: Text('Notificaciones'),
              onTap: () {
                Navigator.pop(context);
                print("Notificaciones");
              },
            ),
            ListTile(
              title: Text('Foros'),
              onTap: () {
                Navigator.pop(context);
                print("Foros");
              },
            ),
            ListTile(
              title: Text('Biblioteca'),
              onTap: () {
                Navigator.pop(context);
                print("Biblioteca");
              },
            ),
            ListTile(
              title: Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                print("Configuración");
              },
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
      body: cuerpo(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color(0xff2E4D4D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Catalogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'joaquin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

Widget cuerpo() {
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/.png"),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    ),
    child: Center(
      child: Text("Administradores"),
    ),
  );
}
