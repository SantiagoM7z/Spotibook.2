import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:app_links/app_links.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  final String token;

  const NewPasswordPage({super.key,required this.email, required this.token});

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para la nueva contraseña
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordValid = false; // Para habilitar el botón cuando las contraseñas son válidas
  
  final AppLinks _appLinks = AppLinks();
  String? deepLink; // Cambié a String? para evitar problemas con la inicialización

  @override
  void initState() {
    super.initState();
    _initLinks(); // Iniciar el manejo de enlaces profundos
  }

  // Inicializa y escucha los enlaces profundos
  _initLinks() async {
    Uri? initialLink = await _appLinks.getInitialLink();
    setState(() {
      deepLink = initialLink.toString();
    });
  
    // Escuchar futuros enlaces profundos mientras la app está en segundo plano
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        setState(() {
          deepLink = uri.toString();
        });
      }
    });
  }

  void _validateForm() {
    setState(() {
      isPasswordValid = newPasswordController.text == confirmPasswordController.text && newPasswordController.text.isNotEmpty;
    });
  }

  // Función para restablecer la contraseña
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await AuthService().resetPassword(widget.email, newPasswordController.text);

        // Si el cambio es exitoso, mostramos un AlertDialog con éxito
        _showSuccessDialog();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hubo un error al restablecer la contraseña. Intenta nuevamente.")));
      }
    }
  }

  // Mostrar el AlertDialog después de un restablecimiento exitoso
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Contraseña Restablecida"),
          content: Text("Tu contraseña ha sido restablecida con éxito. ¿Deseas iniciar sesión ahora?"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SingIn()), // Navegar al inicio de sesión
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:const Color(0xff2E4D4D),
                ),
              child: Text("Iniciar Sesión", style: TextStyle(fontSize: 15, color: Colors.white)),
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
        title: const Text('Restablecer Contraseña'),
        backgroundColor: const Color(0xff2E4D4D),
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
                  Text(
                    "Introduce una nueva contraseña para tu cuenta",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  // Campo de nueva contraseña
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Nueva Contraseña",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "La contraseña es obligatoria";
                      }
                      if (value.length < 8) {
                        return "La contraseña debe tener al menos 8 caracteres";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Campo de confirmación de contraseña
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
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
                  SizedBox(height: 30),
                  // Mensaje de error si las contraseñas no coinciden
                  if (newPasswordController.text != confirmPasswordController.text)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Las contraseñas no coinciden",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  // Botón para restablecer la contraseña
                  ElevatedButton(
                    onPressed: isPasswordValid ? _resetPassword : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPasswordValid ? const Color(0xff2E4D4D) : Colors.grey,
                    ),
                    child: const Text("Restablecer Contraseña"),
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
