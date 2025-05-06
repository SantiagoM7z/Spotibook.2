import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Auth_Service.dart';  
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'ModuloLec.dart'; // Asegúrate de importar ModuloLec.dart correctamente

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  int _selectedIndex = 0;
  int _paginaActual = 0;
  PageController _pageController = PageController();

  bool isAuthor = false;

  // Aquí se agregan las páginas, incluyendo el método _buildLibros
  List<Widget> _paginas = [];

  @override
  void initState() {
    super.initState();
    // Inicializamos las páginas
    _paginas = [
      _buildLibros(), // Mostrar libros con imágenes
      _buildNovedades(), // Novedades 🆕
      _buildRecomendaciones(), // Recomendaciones 💡
      _buildCategorias(), // Categorías con ExpansionTile
    ];
  }

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

  // Mostrar libros con imágenes
  Widget _buildLibros() {
  return Column(
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ModuloLec()),
              );
            },
            child: Container(
              width: 100, // Ancho ajustado
              height: 150, // Altura ajustada
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/libro1.png'),  // Ruta de la imagen del libro
                  fit: BoxFit.cover,  // Asegura que la imagen se recorte y ajuste correctamente
                ),
                borderRadius: BorderRadius.circular(10),  // Bordes redondeados opcionales
              ),
            ),
          ),
          SizedBox(width: 10),  // Espaciado entre los libros
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ModuloLec()),
              );
            },
            child: Container(
              width: 100, // Ancho ajustado
              height: 150, // Altura ajustada
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/libro2.png'),  // Ruta de la imagen del libro
                  fit: BoxFit.cover,  // Asegura que la imagen se recorte y ajuste correctamente
                ),
                borderRadius: BorderRadius.circular(10),  // Bordes redondeados opcionales
              ),
            ),
          ),
          SizedBox(width: 10),  // Espaciado entre los libros
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ModuloLec()),
              );
            },
            child: Container(
              width: 100, // Ancho ajustado
              height: 150, // Altura ajustada
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/libro3.png'),  // Ruta de la imagen del libro
                  fit: BoxFit.cover,  // Asegura que la imagen se recorte y ajuste correctamente
                ),
                borderRadius: BorderRadius.circular(10),  // Bordes redondeados opcionales
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

  // Novedades 🆕
  static Widget _buildNovedades() {
    return Center(child: Text("🆕"));
  }

  // Recomendaciones 💡
  static Widget _buildRecomendaciones() {
    return Center(child: Text("💡"));
  }

  // Categorías con ExpansionTile
  static Widget _buildCategorias() {
    return ListView(
      children: <Widget>[
        ExpansionTile(
          title: Text("Ficción ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Icono libro con texto
          leading: Text("📚", style: TextStyle(fontSize: 24)),  // Usando el emoji de libro
          children: <Widget>[
            ListTile(title: Text("Novelas")),
            ListTile(title: Text("Cuentos Cortos")),
            ListTile(title: Text("Literatura Contemporánea")),
          ],
        ),
        ExpansionTile(
          title: Text("No Ficción ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Icono carpeta con texto
          leading: Text("📂", style: TextStyle(fontSize: 24)),  // Usando el emoji de carpeta
          children: <Widget>[
            ListTile(title: Text("Biografías")),
            ListTile(title: Text("Historia")),
            ListTile(title: Text("Ciencias")),
          ],
        ),
      ],
    );
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconTab(Icons.book, "Libros", 0),
                _buildIconTab(Icons.fiber_new, "Novedades", 1),
                _buildIconTab(Icons.lightbulb, "Recomendaciones", 2),
                _buildIconTab(Icons.category, "Categorías", 3),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xff2E4D4D),
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
