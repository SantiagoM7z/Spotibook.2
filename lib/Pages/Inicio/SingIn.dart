import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Administradores/Verificaciones.dart';
import 'package:spotibook2/Pages/Index/Editoriales/BibliotecaE.dart';

import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Services/Firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotibook2/Services/RecoverPassService.dart';
import 'package:uuid/uuid.dart';

// Importa la página del Centro de Ayuda
import 'package:spotibook2/Pages/Suport/HelpCenter.dart'; // ¡Asegúrate de que esta ruta sea correcta!

class SingIn extends StatefulWidget {
  const SingIn({super.key});

  @override
  State<SingIn> createState() => _SingInState();
}

class _SingInState extends State<SingIn> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController correoController = TextEditingController();
  TextEditingController contraseniaController = TextEditingController();

  bool isFormValid = false;
  bool isRememberMeChecked = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isRememberMeChecked = prefs.getBool('rememberMe') ?? false;
      if (isRememberMeChecked) {
        correoController.text = prefs.getString('email') ?? '';
      }
    });
  }

  void _saveRememberMe(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', value);
    if (value) {
      prefs.setString('email', correoController.text);
    } else {
      prefs.remove('email');
    }
  }

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState!.validate();
    });
  }

  // Función para enviar el correo de recuperación
  Future<void> _sendRecoveryEmail() async {
    final email = correoController.text;
    if (email.isNotEmpty) {
      try {
        // Generar un token único para esta solicitud
        final token = Uuid().v4(); // Genera un token único aleatorio
        // Ahora generamos el enlace con el token
        final resetUrl = RecoverPassService().generarResetUrl(token);
        // Envía el correo con el enlace de restablecimiento
        await RecoverPassService().enviarCorreoRecuperacion(
          destinatario: email,
          username: 'User', // Este debe ser el nombre real del usuario
          resetUrl: resetUrl,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correo de recuperación enviado")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hubo un error al enviar el correo")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inicia Sesión",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        onChanged: _validateForm,
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return Container(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _correo(),
              _contrasenia(),
              // Aquí se agrega el TextButton para recuperar la contraseña
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _sendRecoveryEmail,
                    child: const Text(
                      "Olvidé mi contraseña",
                      style: TextStyle(color: Color(0xff2E4D4D)),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isRememberMeChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isRememberMeChecked = value!;
                        _saveRememberMe(isRememberMeChecked);
                      });
                    },
                  ),
                  const Text("Recuerdame"),
                ],
              ),
              // --- Nuevo botón "Centro de Ayuda" ---
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>HelpCenter()));
                },
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xff2E4D4D),
                  textStyle: TextStyle(fontSize: 10),
                ),
                child: Text("Centro de Ayuda"),
              ),
              // --- Fin del nuevo botón ---
              ElevatedButton(
                onPressed: isFormValid
                    ? () async {
                        final email = correoController.text;
                        final password = contraseniaController.text;

                        try {
                          final user = await AuthService().signInWithEmail(email, password);
                          if (user != null) {
                            final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                            final username = userDoc['username'] ?? 'Usuario';
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Bienvenido $username")),
                            );

                            final userType = await FirestoreService().getUserType(user.uid);
                            if (userType == "Admin") {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Verificaciones()));
                            } else if (userType == "Lector"){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Catalogo()));
                            } else if (userType == "Autor"){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CatalogoA()));
                            } else {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BibliotecaE()));
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Usuario no encontrado")));
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid ? const Color(0xff2E4D4D) : Colors.grey,
                ),
                child: const Text("Iniciar Sesión", style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _correo() => _campoTexto("Correo", correoController, TextInputType.emailAddress, true, validator: (value) {
    if (value == null || value.isEmpty) return "El correo es obligatorio";
    return null;
  });

  Widget _contrasenia() => _campoTexto("Contraseña", contraseniaController, TextInputType.visiblePassword, true, obscure: true, validator: (value) {
    if (value == null || value.isEmpty) return "Contraseña obligatoria";
    return null;
  });

  Widget _campoTexto(String hint, TextEditingController controller, TextInputType tipo, bool obligatorio, {bool obscure = false, String? Function(String?)? validator}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.white,
          filled: true,
        ),
        validator: validator ?? (obligatorio ? (value) {
          if (value == null || value.isEmpty) {
            return "Este campo es obligatorio";
          }
          return null;
        } : null),
      ),
    );
  }
}