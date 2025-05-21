import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart'; 
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';

class Biblioteca extends StatefulWidget {
  const Biblioteca({super.key});

  @override
  State<Biblioteca> createState() => _BibliotecaState();
}

class _BibliotecaState extends State<Biblioteca> {
  int _selectedIndex = 2;
  int _paginaActual = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Catalogo()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Buscar()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Perfil()));
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _cambiarPagina(int index) {
    setState(() {
      _paginaActual = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  final List<Widget> _paginas = [
    Center(child: Text("Libros en Progreso 📖")),
    Center(child: Text("Libros Leídos ✅")),
    Center(child: Text("Libros Favoritos ❤️")),
    Center(child: Text("Libros Descargados ⬇️")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Biblioteca"),
        backgroundColor: Color(0xff2E4D4D),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconTab(Icons.book, "En Progreso", 0),
                _buildIconTab(Icons.check_circle, "Leído", 1),
                _buildIconTab(Icons.favorite, "Favoritos", 2),
                _buildIconTab(Icons.download, "Descargados", 3),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _paginaActual = index;
                });
              },
              children: _paginas,
            ),
          ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color(0xff2E4D4D),
        selectedItemColor: Color(0xff2E4D4D),
        unselectedItemColor: Colors.grey,
        items: <BottomNavigationBarItem>[
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

  Widget _buildIconTab(IconData icono, String texto, int index) {
    final bool activo = _paginaActual == index;
    return GestureDetector(
      onTap: () => _cambiarPagina(index),
      child: Column(
        children: [
          Icon(
            icono,
            size: 30,
            color: activo ? Color(0xff2E4D4D) : Colors.grey,
          ),
          SizedBox(height: 5),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              color: activo ? Color(0xff2E4D4D) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
