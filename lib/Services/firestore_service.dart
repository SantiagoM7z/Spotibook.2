import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // * Guardar los datos del usuario en Firestore
  Future<void> saveUser(User user, String username, String userType) async {
    try {
      Map<String, dynamic> userModel = {
        'uid': user.uid,
        'email': user.email,
        'username': username, // Añadido el campo 'username'
        'userType': userType, // Añadido el campo 'userType'
      };

      await _db.collection('users').doc(user.uid).set(userModel);
    } catch (e) {
      print("Error al guardar el usuario en Firestore: $e");
    }
  }

  // Obtener un usuario por su UID
  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error al obtener el usuario de Firestore: $e");
      return null;
    }
  }
}
