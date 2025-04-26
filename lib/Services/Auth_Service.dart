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

      if (signInWithEmailOrUsername.contains('@')) {
        user = await _signInWithEmail(signInWithEmailOrUsername, password);
      } else {
        user = await _signInWithUsername(signInWithEmailOrUsername, password);
      }

      return user;
    } catch (e) {
      print("Error al Iniciar Sesión: $e");
      return null;
    }
  }

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

  Future<User?> _signInWithUsername(String username, String password) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final String email = snapshot.docs.first['email'];
        return await _signInWithEmail(email, password);
      }
    } catch (e) {
      print("Error al Iniciar Sesión con Nombre de Usuario: $e");
    }
    return null;
  }

  // Método para obtener el tipo de usuario desde la colección "users"
  Future<String?> getUserTypeFromUsers(String uid) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['userType'];  // Asumiendo que el campo 'userType' existe en la colección "users"
      }
      return null;
    } catch (e) {
      print("Error al obtener tipo de usuario desde 'users': $e");
      return null;
    }
  }

  // Método para obtener el tipo de usuario desde la colección "editoriales"
  Future<String?> getUserTypeFromEditoriales(String uid) async {
    try {
      final DocumentSnapshot editorialDoc = await FirebaseFirestore.instance.collection('editoriales').doc(uid).get();
      if (editorialDoc.exists) {
        return "Editorial";  // Si el usuario está en la colección 'editoriales', lo clasificamos como Editorial
      }
      return null;
    } catch (e) {
      print("Error al obtener tipo de usuario desde 'editoriales': $e");
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
