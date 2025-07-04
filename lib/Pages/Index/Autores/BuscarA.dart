import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart';

class BuscarA extends StatefulWidget {
  const BuscarA({super.key});

  @override
  State<BuscarA> createState() => _BuscarAState();
}

class _BuscarAState extends State<BuscarA> {
  final TextEditingController _controller = TextEditingController();
  List<String> libros = [
    "Cien años de soledad",
    "El principito",
    "Don Quijote de la Mancha",
    "Harry Potter",
    "Crónica de una muerte anunciada",
    "Rayuela"
  ];
  List<String> resultados = [];

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    resultados = libros;
  }

  void _buscar(String query) {
    setState(() {
      resultados = libros
          .where((libro) =>
              libro.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CatalogoA()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AgregarA())); 
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => BibliotecaA()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PerfilA()));
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: _buscar,
          decoration: InputDecoration(
            hintText: "Buscar libros...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: TextStyle(color: Colors.white),
          autofocus: true,
        ),
        backgroundColor: Color(0xff2E4D4D),
      ),
      body: ListView.builder(
        itemCount: resultados.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(resultados[index]),
          );
        },
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color(0xff2E4D4D),
        selectedItemColor: Color(0xff2E4D4D),
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catalogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
