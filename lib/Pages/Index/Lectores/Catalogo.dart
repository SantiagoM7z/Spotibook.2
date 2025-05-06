import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';  
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  int _selectedIndex = 0; 
  bool isAuthor = false; 
  
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
          padding: EdgeInsets.zero,
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
                  Navigator.pop(context); 
                  print("Publicar Libro");
                },
              ),
            ],
            if (!isAuthor) ...[
              ListTile(
                title: Text('Plan de Suscripción'),
                onTap: () {
                  Navigator.pop(context);
                  print("Plan de Suscripción");
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
            ],
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
        image: AssetImage("assets/images/.png"),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    ),
    child: Center(
      child: Text("Si"), 
    ),
  );
}
