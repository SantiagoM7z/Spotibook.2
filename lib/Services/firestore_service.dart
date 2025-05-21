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
        'username': username,
        'userType': userType,
      };

      await _db.collection('users').doc(user.uid).set(userModel);
    } catch (e) {
      print("Error al guardar el usuario en Firestore: $e");
    }
  }

  // * Guardar la información de la editorial en Firestore
  Future<void> saveEditorial(User user, String nombreLegal, String rfc, String direccion, String telefono, String username) async {
    try {
      Map<String, dynamic> editorialModel = {
        'uid': user.uid,
        'email': user.email,
        'nombreLegal': nombreLegal,
        'rfc': rfc,
        'direccion': direccion,
        'telefono': telefono,
        'username': username,
        'userType': 'Editorial',
      };

      await _db.collection('editoriales').doc(user.uid).set(editorialModel);
    } catch (e) {
      print("Error al guardar la editorial en Firestore: $e");
    }
  }

  Future<String?> getUserType(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();

      if (doc.exists) {
        return doc['userType'];
      }
      return null;
    } catch (e) {
      print("Error al obtener tipo de usuario desde 'users': $e");
      return null;
    }
  }
  // * Guardar la información del libro en Firestore
  Future<void> saveBook({
    required String titulo,
    required String autor,
    required String editorial,
    required String sinopsis,
    required List<String> etiquetas,
    required String portadaUrl,
    required String archivoUrl,
    bool solicitud = true,
  }) async {
    try {
      await _db.collection('libros').add({
        'titulo': titulo,
        'autor': autor,
        'editorial': editorial,
        'sinopsis': sinopsis,
        'etiquetas': etiquetas,
        'portadaUrl': portadaUrl,
        'archivoUrl': archivoUrl,
        'fechaSubida': FieldValue.serverTimestamp(),
        'estado': 'pendiente',
        'solicitud': solicitud,
      });
    } catch (e) {
      print("Error al guardar el libro en Firestore: $e");
      rethrow;
    }
  }

  // * Cargar etiquetas
  Future<List<Map<String, dynamic>>> loadTags() async {
    try {
      final querySnapshot = await _db.collection('etiquetas').get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        'nombre': doc['nombre'] ?? ''
      }).toList();
    } catch (e) {
      print("Error al cargar etiquetas: $e");
      return [];
    }
  }
}
