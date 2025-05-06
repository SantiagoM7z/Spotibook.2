import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    } catch (e) {
      print("Error Durante el Registro: $e");
      return null;
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
    } catch (e) {
      print("Error al Iniciar Sesión con Correo: $e");
      throw Exception('Usuario no encontrado');
    }
  }

  // * Función para restablecer la contraseña
  Future<void> resetPassword(String email, String newPassword) async {
    try {
      // Realizar el restablecimiento de la contraseña con Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;

      // Si el usuario está autenticado, podemos proceder a cambiar la contraseña
      if (user != null) {
        await user.updatePassword(newPassword);  // Cambiar la contraseña
      } else {
        throw Exception("Usuario no autenticado");
      }
    } catch (error) {
      throw Exception("Error al restablecer la contraseña: $error");
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
