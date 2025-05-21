import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  int _selectedIndex = 3;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmContrasenaController = TextEditingController();

  String imageUrl = 'https://cdn-icons-png.flaticon.com/512/149/149071.png';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _contrasenaController.text = ''; // Campo contraseña vacío
    _confirmContrasenaController.text = '';
  }

  void _cargarDatosUsuario() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          // Si Firebase Auth tiene nombre, úsalo, sino usa Firestore
          _nombreController.text = user.displayName ?? (userDoc['nombre'] ?? '');
          _correoController.text = user.email ?? '';
          imageUrl = userDoc['imagen'] ?? imageUrl;
        });
      } else {
        // Si no existe doc en Firestore, usa Firebase Auth solo
        setState(() {
          _nombreController.text = user.displayName ?? '';
          _correoController.text = user.email ?? '';
        });
      }
    }
  }

  void _guardarCambios() async {
    final user = _auth.currentUser;
    if (user != null) {
      final newPassword = _contrasenaController.text.trim();
      final confirmPassword = _confirmContrasenaController.text.trim();

      // Validar que si una de las dos no está vacía, ambas coincidan
      if (newPassword.isNotEmpty || confirmPassword.isNotEmpty) {
        if (newPassword != confirmPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Las contraseñas no coinciden')),
          );
          return;
        }
      }

      try {
        // Actualizar nombre en Firebase Authentication
        await user.updateDisplayName(_nombreController.text);
        await user.reload(); // Refrescar usuario

        // Actualizar nombre e imagen en Firestore
        await _firestore.collection('usuarios').doc(user.uid).set({
          'nombre': _nombreController.text,
          'imagen': imageUrl,
          'correo': _correoController.text,
        }, SetOptions(merge: true));

        // Actualizar contraseña si fue escrita
        if (newPassword.isNotEmpty) {
          await user.updatePassword(newPassword);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados correctamente')),
        );

        _contrasenaController.clear();
        _confirmContrasenaController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar cambios: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Catalogo()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Buscar()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Biblioteca()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    // Aquí puedes implementar la selección y subida de imagen
    setState(() {
      imageUrl = 'https://cdn-icons-png.flaticon.com/512/149/149071.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: const Color(0xff2E4D4D),
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
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre de Usuario"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Text("Correo: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_correoController.text),
                ],
              ),
            ),
            TextField(
              controller: _contrasenaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Nueva Contraseña"),
            ),
            TextField(
              controller: _confirmContrasenaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirmar Nueva Contraseña"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2E4D4D),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Guardar Cambios", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xff2E4D4D),
        selectedItemColor: const Color(0xff2E4D4D),
        unselectedItemColor: Colors.grey,
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
