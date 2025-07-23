import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Administradores/Verificaciones.dart';
import 'package:spotibook2/Pages/Index/Editoriales/BibliotecaE.dart';
import 'package:spotibook2/Pages/Inicio/NewPassword.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Services/Firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotibook2/Services/RecoverPassService.dart'; // Se mantiene para enviar el correo de recuperación
import 'package:spotibook2/Pages/Suport/HelpCenter.dart'; // ¡Asegúrate de que esta ruta sea correcta!

import 'dart:math'; // Necesario para generar códigos aleatorios

class SingIn extends StatefulWidget {
  const SingIn({super.key});

  @override
  State<SingIn> createState() => _SingInState();
}

class _SingInState extends State<SingIn> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController correoController = TextEditingController();
  TextEditingController contraseniaController = TextEditingController();
  
  //* Controladores para los campos de código del AlertDialog de recuperación
  final List<TextEditingController> _recoveryCodeControllers = List.generate(4, (_) => TextEditingController());
  bool _isRecoveryCodeValid = false; // Estado para validar el código de 4 dígitos ingresado

  bool isFormValid = false;
  bool isRememberMeChecked = false;

  //* Instancia de RecoverPassService
  final RecoverPassService _recoverPassService = RecoverPassService();

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  //* Lógica para "Recuérdame"
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

  //* Función para generar un código de verificación de 4 dígitos
  int _generarCodigoRecuperacion() {
    final random = Random();
    return 1000 + random.nextInt(9000); // Genera un número entre 1000 y 9999
  }

  //* Función para guardar el código de recuperación en Firestore
  Future<void> _guardarCodigoRecuperacion(String email, int codigo) async {
    await FirebaseFirestore.instance.collection('password_recovery_codes').doc(email).set({
      'code': codigo,
      'createdAt': FieldValue.serverTimestamp(),
      'used': false, // Para marcar si el código ya fue usado
    });
  }

  //* Función principal para iniciar el flujo de recuperación de contraseña
  Future<void> _iniciarRecuperacionContrasenia() async {
    // Reiniciar los controladores de código y el estado de validación
    for (var controller in _recoveryCodeControllers) {
      controller.clear();
    }
    setState(() {
      _isRecoveryCodeValid = false;
    });

    final mainContext = context; // Capturamos el contexto principal para SnackBar y navegación

    showDialog(
      context: mainContext,
      barrierDismissible: false, // El usuario debe interactuar con el diálogo
      builder: (contextDialog) {
        String emailToRecover = ''; // Variable para almacenar el correo ingresado
        final TextEditingController dialogEmailController = TextEditingController();

        return AlertDialog(
          title: const Text("Recuperar Contraseña"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Por favor, ingresa tu correo electrónico registrado para enviarte un código de verificación."),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  controller: dialogEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Correo Electrónico",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "El correo es obligatorio";
                    if (!RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$').hasMatch(value)) return "Correo inválido";
                    return null;
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(contextDialog).pop(); // Cerrar el diálogo
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                emailToRecover = dialogEmailController.text.trim();
                if (emailToRecover.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$').hasMatch(emailToRecover)) {
                  ScaffoldMessenger.of(mainContext).showSnackBar(
                    const SnackBar(content: Text("Por favor, ingresa un correo electrónico válido.")),
                  );
                  return;
                }

                // * Verificar si el correo existe en Firestore (colección 'users')
                try {
                  final querySnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: emailToRecover)
                      .limit(1)
                      .get();

                  if (querySnapshot.docs.isEmpty) {
                    ScaffoldMessenger.of(mainContext).showSnackBar(
                      const SnackBar(content: Text("El correo electrónico no está registrado.")),
                    );
                    return;
                  }
                  
                  // * Generar y guardar el código
                  final codigo = _generarCodigoRecuperacion();
                  await _guardarCodigoRecuperacion(emailToRecover, codigo);

                  // * Enviar el correo con el código usando RecoverPassService
                  final username = querySnapshot.docs.first['username'] ?? 'Usuario';
                  await _recoverPassService.enviarCorreoRecuperacion(
                    destinatario: emailToRecover,
                    username: username,
                    codigoVerificacion: codigo.toString(), // Ahora RecoverPassService debe aceptar esto
                  );

                  ScaffoldMessenger.of(mainContext).showSnackBar(
                    const SnackBar(content: Text("Código enviado a tu correo.")),
                  );

                  Navigator.of(contextDialog).pop(); // Cerrar el diálogo actual

                  // * Mostrar el diálogo para ingresar el código de verificación
                  _mostrarDialogoCodigoRecuperacion(emailToRecover);

                } catch (e) {
                  print("Error al enviar el código de recuperación: $e"); // Para depuración
                  ScaffoldMessenger.of(mainContext).showSnackBar(
                    const SnackBar(content: Text("Error al enviar el código de recuperación.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2E4D4D),
                foregroundColor: Colors.white,
              ),
              child: const Text("Enviar Código"),
            ),
          ],
        );
      },
    );
  }

  //* Diálogo para ingresar el código de recuperación
  void _mostrarDialogoCodigoRecuperacion(String emailParaRecuperar) {
    final mainContext = context; // Capturamos el contexto principal
    
    showDialog(
      context: mainContext,
      barrierDismissible: false,
      builder: (contextDialog) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Ingresa el código de recuperación"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text("Ingresa el código de 4 dígitos que te enviamos al correo."),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) { // Ahora son 4 TextField
                        return SizedBox(
                          width: 40,
                          child: TextField(
                            controller: _recoveryCodeControllers[index],
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: '-',
                              counterText: "",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              // * Mover el foco al siguiente campo
                              if (value.isNotEmpty && index < _recoveryCodeControllers.length - 1) {
                                FocusScope.of(context).nextFocus();
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                              // * Validar si todos los campos tienen un valor
                              setState(() {
                                _isRecoveryCodeValid = _recoveryCodeControllers.every((controller) => controller.text.isNotEmpty);
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  if (!_isRecoveryCodeValid && _recoveryCodeControllers.any((controller) => controller.text.isNotEmpty)) 
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "El código debe tener 4 dígitos.",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: _isRecoveryCodeValid ? () async {
                    String codigoIngresado = _recoveryCodeControllers.map((e) => e.text).join();
                    
                    try {
                      //* Obtener el código almacenado y verificar su caducidad
                      DocumentSnapshot recoveryDoc = await FirebaseFirestore.instance
                          .collection('password_recovery_codes')
                          .doc(emailParaRecuperar)
                          .get();

                      if (recoveryDoc.exists) {
                        final storedCodigo = recoveryDoc['code'].toString();
                        final createdTimestamp = (recoveryDoc['createdAt'] as Timestamp).toDate();
                        final bool used = recoveryDoc['used'] ?? false;
                        final expiryTime = createdTimestamp.add(const Duration(minutes: 5)); // Código válido por 5 minutos

                        if (used) {
                          setState(() { _isRecoveryCodeValid = false; });
                          ScaffoldMessenger.of(mainContext).showSnackBar(
                            const SnackBar(content: Text("Este código ya ha sido usado.")),
                          );
                          return;
                        }

                        if (DateTime.now().isAfter(expiryTime)) {
                          setState(() { _isRecoveryCodeValid = false; });
                          ScaffoldMessenger.of(mainContext).showSnackBar(
                            const SnackBar(content: Text("El código ha caducado. Por favor, reenvíalo.")),
                          );
                          // Opcional: Eliminar el documento caducado para limpiar la base de datos
                          await FirebaseFirestore.instance.collection('password_recovery_codes').doc(emailParaRecuperar).delete();
                          return;
                        }

                        if (codigoIngresado == storedCodigo) {
                          // * Código correcto: Marcar como usado y navegar
                          await FirebaseFirestore.instance.collection('password_recovery_codes').doc(emailParaRecuperar).update({
                            'used': true,
                          });
                          
                          setState(() {
                            _isRecoveryCodeValid = true;
                          });

                          ScaffoldMessenger.of(mainContext).showSnackBar(
                            const SnackBar(content: Text("Código verificado con éxito. ¡Establece tu nueva contraseña!")),
                          );

                          Navigator.of(contextDialog).pop(); // Cerrar el diálogo de verificación
                          
                          // * Navegar a la pantalla para establecer la nueva contraseña
                          Navigator.pushReplacement(
                            mainContext,
                            MaterialPageRoute(
                              builder: (context) => NewPassword(userEmail: emailParaRecuperar), // Pasa el correo a la nueva pantalla
                            ),
                          );
                        } else {
                          // * Código incorrecto
                          setState(() {
                            _isRecoveryCodeValid = false;
                          });
                          ScaffoldMessenger.of(mainContext).showSnackBar(
                            const SnackBar(content: Text("Código incorrecto, por favor verifica los números.")),
                          );
                        }
                      } else {
                        // * No hay documento de recuperación para este email (podría ser un reintento tardío o error)
                        setState(() { _isRecoveryCodeValid = false; });
                        ScaffoldMessenger.of(mainContext).showSnackBar(
                          const SnackBar(content: Text("No se encontró una solicitud de recuperación para este correo. Intenta de nuevo.")),
                        );
                      }
                    } catch (e) {
                      print("Error durante la verificación del código: $e"); // Para depuración
                      ScaffoldMessenger.of(mainContext).showSnackBar(
                        const SnackBar(content: Text("Error al verificar el código.")),
                      );
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecoveryCodeValid ? const Color(0xff2E4D4D) : Colors.grey, 
                    foregroundColor: Colors.white, 
                  ),
                  child: const Text("Verificar"),
                ),
                TextButton(
                  onPressed: () async {
                    // * Reenviar código: Genera uno nuevo, lo guarda y lo envía
                    try {
                      final nuevoCodigo = _generarCodigoRecuperacion();
                      await _guardarCodigoRecuperacion(emailParaRecuperar, nuevoCodigo); // Sobreescribe el anterior
                      
                      // * Obtener nombre de usuario para el correo de reenvío
                      final userQuery = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: emailParaRecuperar).limit(1).get();
                      final username = userQuery.docs.isNotEmpty ? userQuery.docs.first['username'] : 'Usuario';

                      await _recoverPassService.enviarCorreoRecuperacion( // Usando RecoverPassService
                        destinatario: emailParaRecuperar,
                        username: username,
                        codigoVerificacion: nuevoCodigo.toString(),
                      );

                      // Limpiar los campos del código y reiniciar estado de validación
                      for (var controller in _recoveryCodeControllers) {
                        controller.clear();
                      }
                      setState(() {
                        _isRecoveryCodeValid = false;
                      });

                      ScaffoldMessenger.of(mainContext).showSnackBar(
                        const SnackBar(content: Text("Nuevo código reenviado a tu correo.")),
                      );
                    } catch (e) {
                      print("Error al reenviar el código: $e"); // Para depuración
                      ScaffoldMessenger.of(mainContext).showSnackBar(
                        const SnackBar(content: Text("Hubo un error al reenviar el código.")),
                      );
                    }
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
              // * Botón para iniciar el flujo de recuperación de contraseña
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _iniciarRecuperacionContrasenia, // Llama a la nueva función para iniciar el flujo
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
    // * Añadir validación de formato de correo más robusta si no está ya en el FormField
    if (!RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$').hasMatch(value)) return "Correo inválido";
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
          border: OutlineInputBorder( // Asegurar que el borde está definido
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
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