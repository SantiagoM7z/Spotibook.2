import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Suport/TermsYCond.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Pages/Index/Editoriales/BibliotecaE.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';

import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Services/Firestore_service.dart';
import 'package:spotibook2/Services/email_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importa la página del Centro de Ayuda
import 'package:spotibook2/Pages/Suport/HelpCenter.dart'; // ¡Asegúrate de que esta ruta sea correcta!

class SingUp extends StatefulWidget {
  final String UserType;

  const SingUp({super.key, required this.UserType});

  @override
  State<SingUp> createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController correoController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController contraseniaController = TextEditingController();
  TextEditingController confirmContraseniaController = TextEditingController();

  TextEditingController nombreLegalController = TextEditingController();
  TextEditingController rfcController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();

  bool ischecked = false, isformvalid = false;
  List<TextEditingController> codigoControllers = List.generate(6, (_) => TextEditingController());
  bool isCodigoValido = false;

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

  String? _selectedProfileImagePath;

  @override
  void initState() {
    super.initState();
    _selectedProfileImagePath = _profileImages[0];
  }

  void _validateForm() {
    setState(() {
      isformvalid = _formKey.currentState!.validate() && ischecked && _selectedProfileImagePath != null;
    });
  }

  // * Función de validación del RFC 
  bool esRFCDeEmpresa(String rfc) {
    final regex = RegExp(r'^[A-ZÑ&]{3}\d{6}[A-Z0-9]{3}$');
    return regex.hasMatch(rfc.toUpperCase());
  }

  void _mostrarDialogoCodigoVerificacion(String userId, int codigoVerificacion) {
    final mainContext = context; 

    showDialog(
      context: mainContext,
      builder: (contextDialog) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Ingresa el código de verificación"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text("Ingresa el código que te enviamos por correo"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 40,
                        child: TextField(
                          controller: codigoControllers[index],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: '-',
                            counterText: "",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              isCodigoValido = codigoControllers.every((controller) => controller.text.isNotEmpty);
                            });
                          },
                        ),
                      );
                    }),
                  ),
                  if (!isCodigoValido && codigoControllers.any((controller) => controller.text.isNotEmpty)) 
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "El código está mal. Verifica los números.",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: isCodigoValido ? () async {
                    String codigoIngresado = codigoControllers.map((e) => e.text).join();
                    DocumentSnapshot verificacionDoc = await FirebaseFirestore.instance
                        .collection('verificaciones')
                        .doc(userId)
                        .get();

                    if (verificacionDoc.exists) {
                      final storedCodigo = verificacionDoc['codigo'].toString();
                      if (codigoIngresado == storedCodigo) {
                        await FirebaseFirestore.instance.collection('users').doc(userId).update({
                          'verificado': true,
                        });

                        setState(() {
                          isCodigoValido = true;
                        });

                        ScaffoldMessenger.of(mainContext).showSnackBar(
                          const SnackBar(content: Text("¡Cuenta verificada con éxito!"))
                        );

                        Navigator.of(contextDialog).pop();

                        if (widget.UserType == 'Editorial') {
                          Navigator.pushReplacement(
                            mainContext,
                            MaterialPageRoute(builder: (context) => BibliotecaE())
                          );
                        } else if (widget.UserType == 'Autor') {
                          Navigator.pushReplacement(
                            mainContext,
                            MaterialPageRoute(builder: (context) => CatalogoA())
                          );
                        }
                        else {
                          Navigator.pushReplacement(
                            mainContext,
                            MaterialPageRoute(builder: (context) => Catalogo())
                          );
                        }
                      } else {
                        setState(() {
                          isCodigoValido = false;
                        });
                        ScaffoldMessenger.of(mainContext).showSnackBar(
                          const SnackBar(content: Text("Código incorrecto, por favor verifica los números."))
                        );
                      }
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCodigoValido ? const Color(0xff2E4D4D) : Colors.grey, 
                    foregroundColor: Colors.white, 
                  ),
                  child: const Text("Verificar"),
                ),
                TextButton(
                  onPressed: () async {
                    final nuevoCodigoVerificacion = generarCodigoVerificacion();

                    await FirebaseFirestore.instance.collection('verificaciones').doc(userId).update({
                      'codigo': nuevoCodigoVerificacion,
                      'creadoEn': FieldValue.serverTimestamp(),
                    });

                    await enviarCorreoVerificacion(
                      destinatario: correoController.text,
                      username: nombreController.text,
                      codigoVerificacion: nuevoCodigoVerificacion.toString(),
                    );

                    ScaffoldMessenger.of(mainContext).showSnackBar(
                      const SnackBar(content: Text("Código Reenviado al Correo."))
                    );
                  },
                  child: const Text("Reenviar Código"),
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
        title: Text(
          "Registrarse como ${widget.UserType}",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  // * Widget de los campos del formulario
  Widget cuerpo(String tipoUsuario) {
    return Container(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20.0), 
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
              _buildProfilePictureSelector(),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsYCond()));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xff2E4D4D),
                      textStyle: const TextStyle(fontSize: 10),
                    ),
                    child: const Text("Términos y Condiciones"),
                  ),
                ],
              ),
              // Aquí se agrega el nuevo TextButton "Centro de Ayuda"
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>HelpCenter()));
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xff2E4D4D),
                  textStyle: const TextStyle(fontSize: 10),
                ),
                child: const Text("Centro de Ayuda"),
              ),
              const SizedBox(height: 20), 
              ElevatedButton(
                onPressed: isformvalid ? () async {
                  final email = correoController.text;
                  final username = nombreController.text;
                  final contrasenia = contraseniaController.text;
                  final userType = widget.UserType;
                  final profilePicture = _selectedProfileImagePath; 

                  if (profilePicture == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Por favor, selecciona una foto de perfil."))
                    );
                    return;
                  }

                  // * Registrar usuario en Firebase
                  final user = await AuthService().registerWithEmailPassword(email, contrasenia);
                  if (user != null) {
                    if (userType == 'Editorial') {
                      await FirestoreService().saveEditorialExtended( 
                        user,
                        nombreLegalController.text,
                        rfcController.text,
                        direccionController.text,
                        telefonoController.text,
                        username,
                        profilePicture, 
                      );
                    } else {
                      await FirestoreService().saveUser(
                        user,
                        username,
                        userType,
                        profilePicture,
                      );
                    }

                    final codigoVerificacion = generarCodigoVerificacion();

                    // * Enviar el correo de verificación
                    await enviarCorreoVerificacion(
                      destinatario: user.email!,
                      username: username,
                      codigoVerificacion: codigoVerificacion.toString(),
                    );

                    await guardarCodigoVerificacion(user.uid, codigoVerificacion);

                    _mostrarDialogoCodigoVerificacion(user.uid, codigoVerificacion);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error al Registrar"))
                    );
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isformvalid ? const Color(0xff2E4D4D) : Colors.grey,
                  foregroundColor: Colors.white, // Color del texto del botón
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Registrarse", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // * Widget para el selector de fotos de perfil
  Widget _buildProfilePictureSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selecciona tu foto de perfil:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff2E4D4D)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _profileImages.length,
              itemBuilder: (context, index) {
                final imagePath = _profileImages[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProfileImagePath = imagePath;
                      _validateForm(); 
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: _selectedProfileImagePath == imagePath
                              ? const Color(0xff2E4D4D) 
                              : Colors.grey[300],
                          child: CircleAvatar(
                            radius: 38,
                            backgroundImage: AssetImage(imagePath),
                            onBackgroundImageError: (exception, stackTrace) {
                              debugPrint('Error loading image $imagePath: $exception');
                            },
                          ),
                        ),
                        if (_selectedProfileImagePath == imagePath)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24.0,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedProfileImagePath == null)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "Por favor, selecciona una foto de perfil.",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget correo() => campoTexto("Correo", correoController, TextInputType.emailAddress, true, validator: (value) {
    if (value == null || value.isEmpty) return "El correo es obligatorio";
    if (!RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$').hasMatch(value)) return "Correo inválido";
    return null;
  });

  Widget nombre() => campoTexto("Nombre de Usuario", nombreController, TextInputType.text, true);

  Widget contrasenia() => campoTexto("Contraseña", contraseniaController, TextInputType.visiblePassword, true,
    obscure: true, validator: (value) {
      if (value == null || value.isEmpty) return "Contraseña obligatoria";
      if (value.length < 8) return "Debe tener mínimo 8 caracteres";
      return null;
    });

  Widget confirmcontrasenia() => campoTexto("Confirme la contraseña", confirmContraseniaController,
    TextInputType.visiblePassword, true, obscure: true, validator: (value) {
      if (value == null || value.isEmpty) return "Confirme la contraseña";
      if (value != contraseniaController.text) return "Las contraseñas no coinciden";
      return null;
    });

  Widget nombrelegal() => campoTexto("Nombre Legal de la Editorial", nombreLegalController, TextInputType.text, true);

  Widget rfc() => campoTexto(
    "RFC",
    rfcController,
    TextInputType.text,
    true,
    validator: (value) {
      if (value == null || value.isEmpty) return "El RFC es obligatorio";
      final regex = RegExp(r'^[A-ZÑ&]{3}\d{6}[A-Z0-9]{3}$');
      if (!regex.hasMatch(value.toUpperCase())) {
        return "RFC inválido. Ej. EMP900101ABC";
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
          border: OutlineInputBorder( 
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
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
        decoration: InputDecoration(
          labelText: "Tipo de Usuario",
          fillColor: Colors.grey[200],
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  int generarCodigoVerificacion() {
    // Genera un código de 6 dígitos
    return 100000 + (DateTime.now().millisecondsSinceEpoch % 900000);
  }

  Future<void> enviarCorreoVerificacion({
    required String destinatario,
    required String username,
    required String codigoVerificacion,
  }) async {
    final emailService = EmailService();
    await emailService.enviarCorreo(
      destinatario: destinatario,
      username: username,
      codigoVerificacion: codigoVerificacion,
    );
  }

  Future<void> guardarCodigoVerificacion(String userId, int codigoVerificacion) async {
    await FirebaseFirestore.instance.collection('verificaciones').doc(userId).set({
      'codigo': codigoVerificacion,
      'email': correoController.text,
      'creadoEn': FieldValue.serverTimestamp(),
    });
  }
}