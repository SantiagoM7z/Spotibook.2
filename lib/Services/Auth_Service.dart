import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; // Necesario para hacer llamadas HTTP
import 'dart:convert'; // Necesario para codificar/decodificar JSON

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // * Registro
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Error Durante el Registro: ${e.code} - ${e.message}");
      rethrow; // Relanza la excepción para que sea manejada por la UI
    } catch (e) {
      print("Error Durante el Registro: $e");
      throw Exception("Ocurrió un error inesperado durante el registro.");
    }
  }

  // * Inicio de sesión (solo con email)
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Error al Iniciar Sesión con Correo: ${e.code} - ${e.message}");
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception('Credenciales inválidas. Verifica tu correo y contraseña.');
      }
      rethrow;
    } catch (e) {
      print("Error al Iniciar Sesión con Correo: $e");
      throw Exception('Hubo un error al iniciar sesión. Intenta de nuevo.');
    }
  }

  // ** Nuevo método para restablecer la contraseña a través de Cloud Function **
  Future<void> resetPasswordViaCloudFunction(String email, String newPassword) async {
    // URL de tu Cloud Function. ¡DEBES REEMPLAZAR ESTO CON LA URL REAL DE TU FUNCIÓN!
    const String cloudFunctionUrl = 'https://us-central1-spotibook-736fe.cloudfunctions.net/resetPasswordWithEmail';

    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: <String, String>{
          'Content-Type': 'application/json', // <--- ¡CAMBIO REALIZADO AQUÍ!
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'newPassword': newPassword,
        }),
      );

      // Siempre intentar decodificar la respuesta para obtener el mensaje de la función
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          print('Contraseña restablecida exitosamente vía Cloud Function.');
        } else {
          // La Cloud Function reportó un error 200 con status: 'error'
          throw Exception(responseData['message'] ?? 'Error desconocido al restablecer contraseña vía Cloud Function.');
        }
      } else {
        // La Cloud Function devolvió un código de error (ej. 400, 500)
        final String errorMessage = responseData['message'] ?? 'Error desconocido del servidor.';
        final String errorCode = responseData['errorCode'] ?? 'no_code'; // Captura el errorCode si lo hay
        print('Error de la Cloud Function (HTTP ${response.statusCode}): ${errorMessage} [Code: ${errorCode}]');
        throw Exception('Error al restablecer la contraseña: ${errorMessage}');
      }
    } on FirebaseAuthException catch (e) {
      print("Error Firebase en Cloud Function (capturado en Flutter): ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Error general al restablecer contraseña vía Cloud Function (Flutter): $e");
      throw Exception("Error inesperado al restablecer la contraseña. Intenta nuevamente.");
    }
  }

  // * Función para actualizar la contraseña de un usuario LOGUEADO
  // Esta función es la que usarías en tu pantalla de Perfil.dart
  Future<void> updatePasswordForLoggedInUser(User user, String newPassword) async {
    try {
      await user.updatePassword(newPassword);
      print("Contraseña del usuario logueado actualizada exitosamente.");
    } on FirebaseAuthException catch (e) {
      print("Error al actualizar contraseña de usuario logueado: ${e.code} - ${e.message}");
      if (e.code == 'requires-recent-login') {
        throw Exception('Por seguridad, debes re-autenticarte para cambiar la contraseña.');
      } else if (e.code == 'weak-password') {
        throw Exception('La nueva contraseña es demasiado débil.');
      }
      rethrow;
    } catch (e) {
      print("Error general al actualizar contraseña de usuario logueado: $e");
      throw Exception("Ocurrió un error inesperado al actualizar la contraseña.");
    }
  }

  Future<String?> getUserTypeFromUsers(String uid) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['userType'];
      }
      return null;
    } catch (e) {
      print("Error al obtener tipo de usuario desde 'users': $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}