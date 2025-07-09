import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart';
import 'package:spotibook2/Pages/Index/Autores/NotificacionesA.dart';
import 'package:spotibook2/Pages/Index/Settings/ConfiguracionporUsuario/ConfiguracionAut.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Index/Foros/ForosporUsuario/ForosAutores.dart'; // Para navegar a Foros

class PerfilA extends StatefulWidget {
  const PerfilA({super.key});

  @override
  State<PerfilA> createState() => _PerfilAState();
}

class _PerfilAState extends State<PerfilA> {
  int _selectedIndex = 4; // Changed to 4 to reflect the new position of 'Perfil'

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmContrasenaController = TextEditingController(); // Added confirm password controller

  String? _selectedProfileImagePath; // Changed to nullable and will be populated from Firestore or default
  final List<String> _profileImages = [
    'assets/Profile_pics/profile_1.png',
    'assets/Profile_pics/profile_2.png',
    'assets/Profile_pics/profile_3.png',
    'assets/Profile_pics/profile_4.png',
    'assets/Profile_pics/profile_5.png',
    'assets/Profile_pics/profile_6.png',
    'assets/Profile_pics/profile_7.png',
    'assets/Profile_pics/profile_8.png',
    'assets/Profile_pics/profile_9.png',
    'assets/Profile_pics/profile_10.png',
  ];

  String? _currentUserType;
  String? _selectedUserType;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _contrasenaController.text = '';
    _confirmContrasenaController.text = '';
  }

  void _cargarDatosUsuario() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get(); // Changed to 'users' collection for consistency

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nombreController.text = userData['username'] ?? user.displayName ?? ''; // Consistency with 'username'
          _correoController.text = user.email ?? '';
          _selectedProfileImagePath = userData['profilePictureUrl'] ?? _profileImages[0];
          _currentUserType = userData['userType'] ?? 'Autor'; // Default to 'Autor' for this page
          _selectedUserType = _currentUserType;
        });
      } else {
        setState(() {
          _nombreController.text = user.displayName ?? '';
          _correoController.text = user.email ?? '';
          _selectedProfileImagePath = _profileImages[0];
          _currentUserType = 'Autor'; // Default to 'Autor'
          _selectedUserType = _currentUserType;
        });
      }
    }
  }

  void _guardarCambios() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado.')),
      );
      return;
    }

    final newPassword = _contrasenaController.text.trim();
    final confirmPassword = _confirmContrasenaController.text.trim();

    if (newPassword.isNotEmpty || confirmPassword.isNotEmpty) {
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden.')),
        );
        return;
      }
      if (newPassword.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La contraseña debe tener al menos 8 caracteres.')),
        );
        return;
      }
    }

    try {
      if (_nombreController.text.isNotEmpty && user.displayName != _nombreController.text) {
        await user.updateDisplayName(_nombreController.text);
      }

      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      Map<String, dynamic> updateData = {
        'username': _nombreController.text,
        'profilePictureUrl': _selectedProfileImagePath,
      };

      // Logic for changing user type
      if (_currentUserType == 'Autor' && _selectedUserType == 'Lector') {
        updateData['userType'] = 'Lector';
        print("Tipo de usuario actualizado de Autor a Lector para ${user.uid}");
      } else if (_currentUserType == 'Lector' && _selectedUserType == 'Autor') {
        // This case might not be directly reachable if the user is already an author
        // but included for completeness if the logic changes elsewhere
        updateData['userType'] = 'Autor';
        print("Tipo de usuario actualizado de Lector a Autor para ${user.uid}");
      }


      await _firestore.collection('users').doc(user.uid).set(updateData, SetOptions(merge: true));

      await user.reload();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cambios guardados correctamente!')),
      );

      _contrasenaController.clear();
      _confirmContrasenaController.clear();

      _cargarDatosUsuario();

    } catch (e) {
      print("Error al guardar cambios: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar cambios: ${e.toString()}')),
      );
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CatalogoA()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BuscarA()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AgregarA()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BibliotecaA()));
        break;
      case 4:
      // Current page, do nothing
        break;
    }
  }

  Future<void> _mostrarSelectorImagenPerfil() async {
    final selectedImage = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecciona tu foto de perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _profileImages.length,
                  itemBuilder: (context, index) {
                    final imagePath = _profileImages[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, imagePath);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(imagePath),
                          backgroundColor: _selectedProfileImagePath == imagePath
                              ? const Color(0xff2E4D4D).withOpacity(0.5)
                              : Colors.grey[300],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
      },
    );

    if (selectedImage != null) {
      setState(() {
        _selectedProfileImagePath = selectedImage;
      });
    }
  }

  Future<void> _mostrarDialogoCambiarNombre() async {
    TextEditingController tempNameController = TextEditingController(text: _nombreController.text);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar Nombre de Usuario'),
          content: TextField(
            controller: tempNameController,
            decoration: const InputDecoration(labelText: 'Nuevo Nombre de Usuario'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _nombreController.text = tempNameController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDialogoCambiarTipoUsuario() async {
    // Only allow changing type if the current user type is 'Autor' and they want to change to 'Lector'
    // or if they are 'Lector' and want to change to 'Autor'.
    // The original code only showed the option to change from Lector to Autor,
    // so I'm mirroring the ability to change back for Author.
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cambiar Tipo de Usuario'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Selecciona tu nuevo tipo de usuario:'),
                  RadioListTile<String>(
                    title: const Text('Autor'),
                    value: 'Autor',
                    groupValue: _selectedUserType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedUserType = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Lector'),
                    value: 'Lector',
                    groupValue: _selectedUserType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedUserType = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Reset selected type if cancelled
                    setState(() {
                      _selectedUserType = _currentUserType;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications), 
            color: Colors.white, 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificacionesA()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedProfileImagePath != null
                      ? AssetImage(_selectedProfileImagePath!)
                      : const NetworkImage('https://cdn-icons-png.flaticon.com/512/149/149071.png') as ImageProvider,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              TextButton(
                onPressed: _mostrarSelectorImagenPerfil,
                child: const Text("Cambiar foto de perfil"),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Text("Nombre de Usuario: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(_nombreController.text)),
                    TextButton(
                      onPressed: _mostrarDialogoCambiarNombre,
                      child: const Text("Cambiar"),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Text("Correo: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(_correoController.text)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Text("Tipo de Usuario: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(_currentUserType ?? 'Cargando...')),
                    TextButton(
                      onPressed: _mostrarDialogoCambiarTipoUsuario,
                      child: const Text("Cambiar"),
                    ),
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
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("Guardar Cambios", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xff2E4D4D)),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Plan de Suscripción'),
              leading: const Icon(Icons.subscriptions),
              onTap: () {
                Navigator.pop(context);
                print("Plan de Suscripción");
                // TODO: Navegar a la página del plan de suscripción
              },
            ),
            ListTile(
              title: const Text('Foros'),
              leading: const Icon(Icons.forum),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForosAutores())); 
              },
            ),
            ListTile(
              title: const Text('Mis Estadísticas'),
              leading: const Icon(Icons.insights),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                print("Navegar a Mis Estadísticas de Autor");
                // TODO: Navegar a una página de estadísticas del autor
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionAut()));
              },
            ),
            const Divider(), // Divisor visual
            ListTile(
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await AuthService().signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SingIn()),
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
        backgroundColor: const Color(0xff2E4D4D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}