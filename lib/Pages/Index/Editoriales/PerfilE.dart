import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotibook2/Services/Auth_Service.dart';  // Importa AuthService
import 'package:spotibook2/Pages/Index/Editoriales/BibliotecaE.dart';
import 'package:spotibook2/Pages/Index/Editoriales/AgregarE.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';

class PerfilE extends StatefulWidget {
  const PerfilE({super.key});

  @override
  State<PerfilE> createState() => _PerfilEState();
}

class _PerfilEState extends State<PerfilE> {
  int _selectedIndex = 3;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  String imageUrl = 'https://cdn-icons-png.flaticon.com/512/149/149071.png'; // Por defecto

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('editoriales').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _nombreController.text = userDoc['nombreLegal'] ?? '';  // Cargar el nombre legal de la editorial
          _correoController.text = user.email ?? '';
          _contrasenaController.text = '********'; // No se muestra directamente
          imageUrl = userDoc['imagen'] ?? imageUrl;
        });
      }
    }
  }

  void _guardarCambios() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('editoriales').doc(user.uid).set({
        'nombreLegal': _nombreController.text,
        'imagen': imageUrl,
        'correo': _correoController.text,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cambios guardados correctamente')),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => BibliotecaE()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AgregarE()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PerfilE()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    // Aquí iría código para subir imagen a Firebase Storage y obtener el URL
    // Por simplicidad se simula
    setState(() {
      imageUrl = 'https://cdn-icons-png.flaticon.com/512/149/149071.png'; // Cambia a una nueva imagen simulada
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil Editorial"),
        backgroundColor: Color(0xff2E4D4D),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _seleccionarImagen,
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(imageUrl),
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: "Nombre Legal de la Editorial"),
            ),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: "Correo"),
            ),
            TextField(
              controller: _contrasenaController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Contraseña"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _guardarCambios,
              style : ElevatedButton.styleFrom(
                backgroundColor: Color(0xff2E4D4D),
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text("Guardar Cambios", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
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
            // Opción de "Cerrar sesión"
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () async {
                await AuthService().signOut(); // Cerrar sesión
                Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => SingIn()), // Redirigir al formulario de inicio de sesión
                (route) => false, // Asegura que la pantalla de inicio de sesión no quede en la pila de navegación
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
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Subir',
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
