import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart'; // Asegúrate de que esta importación esté correcta

class ModuloLec extends StatefulWidget {
  const ModuloLec({super.key});

  @override
  State<ModuloLec> createState() => _ModuloLecState();
}

class _ModuloLecState extends State<ModuloLec> {
  int _selectedIndex = 0;

  // Método para cambiar de página con BottomNavigationBar
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Catalogo()), // Navegar a Catalogo
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Buscar()), // Navegar a Buscar
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Biblioteca()), // Navegar a Biblioteca
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Perfil()), // Navegar a Perfil
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Módulo de Lectura",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xff2E4D4D),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Imagen del libro y detalles
            Row(
              children: <Widget>[
                Image.asset(
                  'assets/images/libro1.png', // Ruta de la imagen del libro
                  width: 100,
                  height: 150,
                ),
                SizedBox(width: 16),
                // Detalles del libro
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Título del Libro', // Título
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('Autor: Nombre del autor'),
                    Text('Editorial: Nombre de la editorial'),
                    Text('Género: Género del libro'),
                    Text('Calificación: ★★★★☆'),
                    SizedBox(height: 10),
                    // Sinopsis
                    Text(
                      'Sinopsis: Este es un resumen del contenido del libro.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Botones de acción (Leer, Favoritos, Descargar)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () {
                    // Acción para agregar a favoritos
                  },
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Acción para leer el libro
                  },
                  child: Text('Leer'),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () {
                    // Acción para descargar el libro
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // ListView con las categorías de estado del libro
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.access_time, color: Color(0xff2E4D4D)),
                    title: Text("Pendiente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Acción para marcar como pendiente
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.hourglass_empty, color: Color(0xff2E4D4D)),
                    title: Text("En Progreso", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Acción para marcar como en progreso
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Color(0xff2E4D4D)),
                    title: Text("Leído", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Acción para marcar como leído
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor:Color(0xff2E4D4D),
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
