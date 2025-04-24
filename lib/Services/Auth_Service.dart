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

  // * Inicio de sesión
  Future<User?> signInWithEmailOrUsername(String signInWithEmailOrUsername, String password) async {
    try {
      User? user;

      // Verifica si el input es un correo electrónico válido
      if (signInWithEmailOrUsername.contains('@')) {
        // Si es un correo, intenta iniciar sesión con el correo
        user = await _signInWithEmail(signInWithEmailOrUsername, password);
      } else {
        // Si no es un correo, intenta iniciar sesión con nombre de usuario
        user = await _signInWithUsername(signInWithEmailOrUsername, password);
      }

      return user;
    } catch (e) {
      print("Error al Iniciar Sesión: $e");
      return null;
    }
  }

  // Método de inicio de sesión por correo electrónico
  Future<User?> _signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error al Iniciar Sesión con Correo: $e");
      return null;
    }
  }

  // Método de inicio de sesión por nombre de usuario
  Future<User?> _signInWithUsername(String username, String password) async {
    try {
      // Consulta en Firestore para obtener el correo asociado con el nombre de usuario
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')  // Asegúrate de que la colección de usuarios se llame 'users'
          .where('username', isEqualTo: username)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final String email = snapshot.docs.first['email'];  // Obtén el correo del usuario
        return await _signInWithEmail(email, password);  // Usa el correo para iniciar sesión
      }
    } catch (e) {
      print("Error al Iniciar Sesión con Nombre de Usuario: $e");
    }
    return null;
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtener el usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
