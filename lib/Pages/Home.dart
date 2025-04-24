import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // Para controlar la pestaña seleccionada

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambia la pestaña seleccionada
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Home",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,),),
            backgroundColor: Color(0xff2E4D4D),
            iconTheme: IconThemeData(color: Colors.white,), 
            leading: null,),
            drawer:Drawer(
              child: ListView(
              padding: EdgeInsets.zero, // Para quitar el padding predeterminado
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
            ListTile(
              title: Text('Plan de Suscripción'),
              onTap: () {
                // Aquí puedes agregar la lógica para abrir el apartado de Plan de Suscripción
                Navigator.pop(context); // Cierra el Drawer
                print("Plan de Suscripción");
              },
            ),
            ListTile(
              title: Text('Foros'),
              onTap: () {
                // Aquí puedes agregar la lógica para abrir los Foros
                Navigator.pop(context); // Cierra el Drawer
                print("Foros");
              },
            ),
            ListTile(
              title: Text('Configuración'),
              onTap: () {
                // Aquí puedes agregar la lógica para abrir Configuración
                Navigator.pop(context); // Cierra el Drawer
                print("Configuración");
              },
            ),
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () {
                // Aquí puedes agregar la lógica para cerrar sesión
                Navigator.pop(context); // Cierra el Drawer
                print("Cerrar sesión");
              },
            ),
          ],
        ),
      ),
      body: cuerpo(),
bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color(0xff2E4D4D), //!No esta se esta viendo bien el color verde de fondo
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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


Widget cuerpo(){
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(image: AssetImage("assets/images/.png"),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high)),
      child: Center(
        child: Text("Si"),
      ),
  );
}