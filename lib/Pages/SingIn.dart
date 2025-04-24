import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:spotibook2/Pages/Home.dart';
import 'package:spotibook2/Services/Auth_Service.dart';

class SingIn extends StatefulWidget {
  const SingIn({super.key});

  @override
  State<SingIn> createState() => _SingInState();
}

class _SingInState extends State<SingIn> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  TextEditingController correoORnombreController = TextEditingController();
  TextEditingController contraseniaController = TextEditingController();

  bool isFormValid = false;
  bool isRememberMeChecked = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();  // * Carga el estado de recuerdame
  }

  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isRememberMeChecked = prefs.getBool('rememberMe') ?? false;
      if (isRememberMeChecked) {
        correoORnombreController.text = prefs.getString('email') ?? '';
        contraseniaController.text = prefs.getString('password') ?? '';
      }
    });
  }

  void _saveRememberMe(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', value);
    if (value) {
      prefs.setString('email', correoORnombreController.text);
      prefs.setString('password', contraseniaController.text);
    } else {
      prefs.remove('email');
      prefs.remove('password');
    }
  }

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState!.validate();
    });
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/.png"),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _correoORnombre(),
              _contrasenia(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isRememberMeChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isRememberMeChecked = value!;
                        _saveRememberMe(isRememberMeChecked);  // Guardar la opción
                      });
                    },
                  ),
                  const Text("Recuerdame"),
                ],
              ),
              ElevatedButton(
                onPressed: isFormValid
                    ? () async {
                        final emailOrUsername = correoORnombreController.text;
                        final password = contraseniaController.text;

                        try {
                          final user = await AuthService().signInWithEmailOrUsername(emailOrUsername, password);
                          if (user != null) {
                            // Redirigir a la página de inicio si el usuario se autentica correctamente
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          }
                        } catch (e) {
                          // Mostrar el error en un Snackbar si ocurre algo al iniciar sesión
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Error al iniciar sesión: $e"),
                          ));
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

  Widget _correoORnombre() => _campoTexto("Correo o Nombre de Usuario", correoORnombreController, TextInputType.emailAddress, true, validator: (value) {
    if (value == null || value.isEmpty) return "El correo o Nombre de Usuario es obligatorio";
    return null;
  });

  Widget _contrasenia() => _campoTexto("Contraseña", contraseniaController, TextInputType.visiblePassword, true,
      obscure: true, validator: (value) {
    if (value == null || value.isEmpty) return "Contraseña obligatoria";
    return null;
  });

  Widget _campoTexto(String hint, TextEditingController controller, TextInputType tipo, bool obligatorio,
      {bool obscure = false, String? Function(String?)? validator}) {
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
        validator: validator ??
            (obligatorio
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return "Este campo es obligatorio";
                    }
                    return null;
                  }
                : null),
      ),
    );
  }
}
