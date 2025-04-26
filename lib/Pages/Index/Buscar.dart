import 'package:flutter/material.dart';
import 'Perfil.dart';
import 'Catalogo.dart';
import 'Biblioteca.dart';



class Buscar extends StatefulWidget {
  const Buscar({super.key});

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  TextEditingController _controller = TextEditingController();
  List<String> libros = [
    "Cien años de soledad",
    "El principito",
    "Don Quijote de la Mancha",
    "Harry Potter",
    "Crónica de una muerte anunciada",
    "Rayuela"
  ];
  List<String> resultados = [];

  int _selectedIndex = 1; // Buscar está en el índice 1

  @override
  void initState() {
    super.initState();
    resultados = libros; // Mostrar todos al inicio
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Catalogo()));
  } else if (index == 2) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Biblioteca()));
  } else if (index == 3) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Perfil()));
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
            label: 'Biblioteca',
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
