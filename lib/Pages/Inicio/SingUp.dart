import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Suport/TermsYCond.dart';
import 'package:spotibook2/Pages/Index/Autores/Catalogo.dart';
import 'package:spotibook2/Pages/Index/Editoriales/BibliotecaE.dart';

import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Services/firestore_service.dart';

class SingUp extends StatefulWidget {
  final String UserType;

  const SingUp({super.key, required this.UserType});

  @override
  State<SingUp> createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  final _formKey = GlobalKey<FormState>();

  //* Controllers Generales
  TextEditingController correoController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController contraseniaController = TextEditingController();
  TextEditingController confirmContraseniaController = TextEditingController();

  //* Controllers para Editorial
  TextEditingController nombreLegalController = TextEditingController();
  TextEditingController rfcController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();

  bool ischecked = false, isformvalid = false;

  void _validateForm() {
    setState(() {
      isformvalid = _formKey.currentState!.validate() && ischecked;
    });
  }

  //* Validación RFC Empresa(Editorial) 
  bool esRFCDeEmpresa(String rfc) {
    final regex = RegExp(r'^[A-ZÑ&]{3}\d{6}[A-Z0-9]{3}$');
    return regex.hasMatch(rfc.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registrarse como ${widget.UserType}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        onChanged: _validateForm,
        child: cuerpo(widget.UserType),
      ),
    );
  }

  Widget cuerpo(String tipoUsuario) {
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
              correo(),
              nombre(),
              contrasenia(),
              confirmcontrasenia(),
              if (tipoUsuario == "Editorial") ...[
                nombrelegal(),
                rfc(),
                direccion(),
                telefono(),
              ],
              UserTypeField(tipoUsuario),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: ischecked,
                    onChanged: (bool? value) {
                      setState(() {
                        ischecked = value!;
                        _validateForm();
                      });
                    },
                  ),
                  const Text("Acepto los"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TermsYCond()));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xff2E4D4D),
                      textStyle: const TextStyle(fontSize: 10),
                    ),
                    child: const Text("Términos y Condiciones"),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isformvalid ? () async {
                  final email = correoController.text;
                  final username = nombreController.text;
                  final contrasenia = contraseniaController.text;
                  final userType = widget.UserType; 

                  final user = await AuthService().registerWithEmailPassword(email, contrasenia);
                  if (user != null) {
                    if (userType == 'Editorial') {
                      await FirestoreService().saveEditorial(user, nombreLegalController.text, rfcController.text, direccionController.text, telefonoController.text, username); // Agregar el username
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BibliotecaE()));
                    } else {
                      await FirestoreService().saveUser(user, username, userType);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Catalogo()));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al Registrar")));
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isformvalid ? const Color(0xff2E4D4D) : Colors.grey,
                ),
                child: const Text("Registrarse", style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget correo() => campoTexto("Correo", correoController, TextInputType.emailAddress, true, validator: (value) {
    if (value == null || value.isEmpty) return "El correo es obligatorio";
    if (!RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$').hasMatch(value)) return "Correo inválido";
    return null;
  });

  Widget nombre() => campoTexto("Nombre de Usuario", nombreController, TextInputType.text, true);

  Widget contrasenia() => campoTexto("Contraseña", contraseniaController, TextInputType.visiblePassword, true, obscure: true, validator: (value) {
    if (value == null || value.isEmpty) return "Contraseña obligatoria";
    if (value.length < 8) return "Debe tener mínimo 8 caracteres";
    return null;
  });

  Widget confirmcontrasenia() => campoTexto("Confirme la contraseña", confirmContraseniaController, TextInputType.visiblePassword, true, 
    obscure: true, validator: (value) {
      if (value == null || value.isEmpty) return "Confirme la contraseña";
      if (value != contraseniaController.text) return "Las contraseñas no coinciden";
      return null;
  });

  Widget nombrelegal() => campoTexto("Nombre Legal de la Editorial", nombreLegalController, TextInputType.text, true);

  Widget rfc() => campoTexto(
    "RFC / EIN / Registro Estatal",
    rfcController,
    TextInputType.text,
    true,
    validator: (value) {
      if (value == null || value.isEmpty) return "El RFC es obligatorio";
      if (!esRFCDeEmpresa(value)) {
        return "RFC inválido. Debe tener 12 caracteres (3 letras, 6 números, 3 letras/números)";
      }
      return null;
    },
  );

  Widget direccion() => campoTexto("Dirección de Oficinas", direccionController, TextInputType.text, true);
  Widget telefono() => campoTexto("Teléfono de Contacto", telefonoController, TextInputType.phone, true);

  Widget campoTexto(String hint, TextEditingController controller, TextInputType tipo, bool obligatorio,
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
        validator: validator ?? (obligatorio
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

  Widget UserTypeField(String tipoUsuario) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextFormField(
        controller: TextEditingController(text: tipoUsuario),
        readOnly: true,
        decoration: const InputDecoration(
          labelText: "Tipo de Usuario",
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
}