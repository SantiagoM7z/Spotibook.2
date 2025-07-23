import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth para manejar excepciones específicas

class NewPassword extends StatefulWidget {
  final String userEmail;

  const NewPassword({super.key, required this.userEmail});

  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordValid = false;

  @override
  void initState() {
    super.initState();
  }

  void _validateForm() {
    setState(() {
      isPasswordValid = newPasswordController.text == confirmPasswordController.text &&
                        newPasswordController.text.isNotEmpty &&
                        newPasswordController.text.length >= 8;
    });
  }

  Future<void> _resetPasswordViaCloudFunction() async {
    if (_formKey.currentState!.validate()) {
      try {
        await AuthService().resetPasswordViaCloudFunction(widget.userEmail, newPasswordController.text);

        _showSuccessDialog();
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        // Manejo de errores específicos de FirebaseAuth
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'El correo electrónico no está registrado.';
            break;
          case 'weak-password':
            errorMessage = 'La contraseña es demasiado débil. Usa al menos 6 caracteres, combinando letras, números y símbolos.'; // Firebase default es 6
            break;
          case 'invalid-email':
            errorMessage = 'El formato del correo electrónico es inválido.';
            break;
          // Aunque unlikely para este flujo (reset), lo dejamos por si acaso
          case 'requires-recent-login':
            errorMessage = 'Esta operación requiere autenticación reciente. Por favor, intenta de nuevo el proceso de recuperación.';
            break;
          default:
            errorMessage = 'Ocurrió un error inesperado al restablecer la contraseña: ${e.message}';
            break;
        }
        print("Error al restablecer contraseña: ${e.code} - ${e.message}"); // Para depuración detallada
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (error) {
        // Manejo de otros errores no relacionados con FirebaseAuth
        print("Error general al restablecer contraseña: $error");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hubo un error inesperado al restablecer la contraseña. Intenta nuevamente.")));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Contraseña Restablecida"),
          content: const Text("Tu contraseña ha sido restablecida con éxito. ¿Deseas iniciar sesión ahora?"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SingIn()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2E4D4D),
                foregroundColor: Colors.white,
              ),
              child: const Text("Iniciar Sesión", style: TextStyle(fontSize: 15, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restablecer Contraseña',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        onChanged: _validateForm,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Introduce una nueva contraseña para tu cuenta",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Nueva Contraseña",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "La contraseña es obligatoria";
                      }
                      // **IMPORTANTE**: Firebase Auth tiene un mínimo de 6 caracteres por defecto.
                      // Si tu política es 8, es mejor validar aquí y también en Firebase.
                      if (value.length < 8) {
                        return "La contraseña debe tener al menos 8 caracteres";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirmar Contraseña",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "La confirmación de la contraseña es obligatoria";
                      }
                      if (value != newPasswordController.text) {
                        return "Las contraseñas no coinciden";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  if (newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty && newPasswordController.text != confirmPasswordController.text)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Las contraseñas no coinciden",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: isPasswordValid ? _resetPasswordViaCloudFunction : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPasswordValid ? const Color(0xff2E4D4D) : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Restablecer Contraseña", style: TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}