import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // * Guardar los datos base de CUALQUIER usuario en la colección 'users'
  Future<void> saveUser(
    User user,
    String username,
    String userType,
    String? profilePictureUrl,
  ) async {
    try {
      Map<String, dynamic> userModel = {
        'uid': user.uid,
        'email': user.email,
        'username': username,
        'userType': userType,
        'profilePictureUrl': profilePictureUrl,
        'verificado': false, // Asumiendo estado de verificación inicial
        'creadoEn': FieldValue.serverTimestamp(),
      };

      await _db.collection('users').doc(user.uid).set(userModel);
      print("Usuario base ${user.uid} (${userType}) guardado con éxito en Firestore.");
    } catch (e) {
      print("Error al guardar el usuario base en Firestore: $e");
      rethrow;
    }
  }

  // * Guardar la información extendida de la editorial en la colección 'editoriales'
  Future<void> saveEditorialExtended(
    User user,
    String nombreLegal,
    String rfc,
    String direccion,
    String telefono,
    String username,
    String? profilePictureUrl,
  ) async {
    try {
      await saveUser(user, username, 'Editorial', profilePictureUrl); // Asegurarse de que el usuario base exista

      Map<String, dynamic> editorialExtendedModel = {
        'uid': user.uid,
        'email': user.email,
        'nombreLegal': nombreLegal,
        'rfc': rfc,
        'direccion': direccion,
        'telefono': telefono,
      };

      await _db.collection('editoriales').doc(user.uid).set(editorialExtendedModel);
      print("Información extendida de editorial ${user.uid} guardada con éxito en Firestore.");
    } catch (e) {
      print("Error al guardar la información extendida de la editorial en Firestore: $e");
      rethrow;
    }
  }

  // * Obtener el tipo de usuario (buscando principalmente en la colección 'users')
  Future<String?> getUserType(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userDoc.exists && userData != null && userData.containsKey('userType')) {
        return userData['userType'];
      }
      return null;
    } catch (e) {
      print("Error al obtener tipo de usuario desde 'users': $e");
      return null;
    }
  }

  // * Método para obtener datos del usuario por UID (ahora busca principalmente en 'users')
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userDoc.exists && userData != null) {
        return userData;
      }
      return null;
    } catch (e) {
      print("Error al obtener datos del usuario por UID: $e");
      return null;
    }
  }

  // * Método para obtener datos EXTENDIDOS de la editorial
  Future<Map<String, dynamic>?> getEditorialExtendedData(String uid) async {
    try {
      DocumentSnapshot editorialDoc = await _db.collection('editoriales').doc(uid).get();
      final editorialData = editorialDoc.data() as Map<String, dynamic>?;

      if (editorialDoc.exists && editorialData != null) {
        return editorialData;
      }
      return null;
    } catch (e) {
      print("Error al obtener datos extendidos de la editorial por UID: $e");
      return null;
    }
  }

  // * LÓGICA PARA OBTENER TODAS LAS ETIQUETAS (incluyendo ID y nombre)
  // Asumo que 'etiquetas' y 'tags' son lo mismo, si no, renómbralas apropiadamente
  Future<List<Map<String, dynamic>>> loadTags() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('etiquetas').get(); // Asumiendo 'etiquetas' es la colección principal para las etiquetas
      print("Etiquetas obtenidas correctamente.");
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        'nombre': doc['nombre'] as String
      }).toList();
    } catch (e) {
      print("Error al obtener etiquetas: $e");
      return [];
    }
  }

  // * Nuevo método para guardar solicitudes de publicación de libros (usado en AgregarA)
  // Estos libros van a la colección 'solicitudes_publicacion' con URLs de la carpeta 'Revisión' de Dropbox
  Future<void> saveBookRequest({
    required String titulo,
    required String autor,
    required String editorial,
    required String sinopsis,
    required List<String> etiquetas, // IDs de las etiquetas
    String? portadaUrlRevision, // URL de la portada en la carpeta 'Revisión' de Dropbox
    String? archivoUrlRevision, // URL del archivo en la carpeta 'Revisión' de Dropbox
  }) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Usuario no autenticado. No se puede guardar la solicitud de libro.");
      }

      await _db.collection('solicitudes_publicacion').add({
        'uidAutor': currentUser.uid,
        'titulo': titulo,
        'autor': autor,
        'editorial': editorial,
        'sinopsis': sinopsis,
        'etiquetas': etiquetas,
        'portadaUrlRevision': portadaUrlRevision, // Almacena la URL de Revisión
        'archivoUrlRevision': archivoUrlRevision, // Almacena la URL de Revisión
        'estado': 'pendiente',
        'fechaSolicitud': FieldValue.serverTimestamp(),
      });
      print("Solicitud de publicación de libro guardada con éxito en Firestore (para revisión).");
    } catch (e) {
      print("Error al guardar la solicitud de publicación del libro en Firestore: $e");
      rethrow;
    }
  }

  // * Método para actualizar solicitudes de publicación de libros existentes (usado en AgregarA)
  // Actualiza los datos de un libro en la colección 'solicitudes_publicacion'
  Future<void> updateBookRequest(String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection('solicitudes_publicacion').doc(docId).update(data);
      print("Solicitud de publicación de libro $docId actualizada con éxito en Firestore.");
    } catch (e) {
      print("Error al actualizar solicitud de publicación de libro $docId en Firestore: $e");
      rethrow;
    }
  }

  // *** MÉTODOS ESPECÍFICOS PARA AgregarE (Colección 'libros_en_revision') ***
  // Estos libros van a la colección 'libros_en_revision' con URLs de la carpeta 'Revisión' de Dropbox
  Future<void> saveBookForReview({
    required String titulo,
    required String autor,
    required String editorial,
    required String sinopsis,
    required List<String> etiquetas,
    String? portadaUrlRevision, // URL de la portada en la carpeta 'Revisión' de Dropbox
    String? archivoUrlRevision, // URL del archivo en la carpeta 'Revisión' de Dropbox
  }) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Usuario no autenticado. No se puede guardar el libro para revisión.");
      }

      await _db.collection('libros_en_revision').add({
        'uidEditorial': currentUser.uid,
        'titulo': titulo,
        'autor': autor,
        'editorial': editorial,
        'sinopsis': sinopsis,
        'etiquetas': etiquetas,
        'portadaUrlRevision': portadaUrlRevision, // Almacena la URL de Revisión
        'archivoUrlRevision': archivoUrlRevision, // Almacena la URL de Revisión
        'estado': 'pendiente',
        'fechaEnvio': FieldValue.serverTimestamp(),
      });
      print('Libro guardado en Firestore para revisión (Editoriales).');
    } catch (e) {
      print('Error al guardar libro en Firestore para revisión (Editoriales): $e');
      throw Exception('Error al guardar libro en Firestore para revisión (Editoriales): $e');
    }
  }

  // * Método para actualizar libros existentes en 'libros_en_revision' (usado en AgregarE)
  // Actualiza los datos de un libro en la colección 'libros_en_revision'
  Future<void> updateBookForReview(String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection('libros_en_revision').doc(docId).update(data);
      print("Libro en revisión $docId actualizado con éxito en Firestore (Editoriales).");
    } catch (e) {
      print("Error al actualizar libro en revisión $docId en Firestore: $e");
      rethrow;
    }
  }

  // --- Métodos para la nueva colección 'libros' (libros publicados/aprobados) ---
  // Este método sería llamado por un proceso de administración, NO por AgregarA o AgregarE
  // Se encarga de guardar los libros YA APROBADOS con las URLs de la carpeta 'Publicaciones'
  Future<void> publishBook({
    required String titulo,
    required String autor,
    required String uidOrigin, // UID del autor o editorial que lo subió originalmente
    required String editorial,
    required String sinopsis,
    required List<String> etiquetas,
    required String portadaUrlPublica, // URL final de la portada desde 'Publicaciones'
    required String archivoUrlPublico, // URL final del archivo desde 'Publicaciones'
    required String idSolicitudOriginal, // ID del documento en solicitudes_publicacion o libros_en_revision
  }) async {
    try {
      await _db.collection('libros').add({
        'titulo': titulo,
        'autor': autor,
        'uidOrigin': uidOrigin,
        'editorial': editorial,
        'sinopsis': sinopsis,
        'etiquetas': etiquetas,
        'portadaUrlPublica': portadaUrlPublica,
        'archivoUrlPublico': archivoUrlPublico,
        'fechaPublicacion': FieldValue.serverTimestamp(),
        'visualizaciones': 0,
        'calificacionPromedio': 0.0,
        'idSolicitudOriginal': idSolicitudOriginal, // Para referencia si es necesario
      });
      print("Libro '$titulo' publicado con éxito en la colección 'libros'.");
    } catch (e) {
      print("Error al publicar el libro en Firestore: $e");
      rethrow;
    }
  }

  /// Obtiene todos los libros publicados en el catálogo (colección 'libros').
  Future<List<Map<String, dynamic>>> getAllBooks() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('libros').orderBy('fechaPublicacion', descending: true).get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print("Error al obtener todos los libros publicados: $e");
      return [];
    }
  }

  /// Busca libros publicados por título, autor o editorial.
  Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    if (query.isEmpty) {
      return [];
    }
    String queryLower = query.toLowerCase();
    try {
      List<Map<String, dynamic>> allBooks = await getAllBooks();
      return allBooks.where((book) {
        final title = (book['titulo'] as String? ?? '').toLowerCase();
        final author = (book['autor'] as String? ?? '').toLowerCase();
        final editorial = (book['editorial'] as String? ?? '').toLowerCase();
        return title.contains(queryLower) ||
               author.contains(queryLower) ||
               editorial.contains(queryLower);
      }).toList();

    } catch (e) {
      print("Error al buscar libros publicados: $e");
      return [];
    }
  }

  // * Obtiene los libros que un AUTOR/EDITORIAL ha enviado para revisión.
  Future<List<Map<String, dynamic>>> getMySubmittedBooks(String uid, String userType) async {
    try {
      QuerySnapshot querySnapshot;
      if (userType == 'Autor') {
        querySnapshot = await _db.collection('solicitudes_publicacion')
            .where('uidAutor', isEqualTo: uid)
            .orderBy('fechaSolicitud', descending: true)
            .get();
      } else if (userType == 'Editorial') {
        querySnapshot = await _db.collection('libros_en_revision')
            .where('uidEditorial', isEqualTo: uid)
            .orderBy('fechaEnvio', descending: true)
            .get();
      } else {
        return [];
      }

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print("Error al obtener libros enviados para revisión por $userType $uid: $e");
      return [];
    }
  }

  // --- Métodos para interacciones del usuario con libros (añadir a biblioteca, etc.) ---
  // Estos métodos interactúan con la colección 'libros' (los publicados)
  /// Añade un libro a una categoría específica de la biblioteca de un usuario.
  Future<void> addBookToUserLibrary(String uid, String bookId, String category) async {
    try {
      await _db.collection('users').doc(uid).update({
        category: FieldValue.arrayUnion([bookId]),
      });
      print("Libro $bookId añadido a la categoría '$category' del usuario $uid.");
    } catch (e) {
      print("Error al añadir libro $bookId a la biblioteca del usuario $uid en $category: $e");
      rethrow;
    }
  }

  /// Elimina un libro de una categoría específica de la biblioteca de un usuario.
  Future<void> removeBookFromUserLibrary(String uid, String bookId, String category) async {
    try {
      await _db.collection('users').doc(uid).update({
        category: FieldValue.arrayRemove([bookId]),
      });
      print("Libro $bookId eliminado de la categoría '$category' del usuario $uid.");
    } catch (e) {
      print("Error al eliminar libro $bookId de la biblioteca del usuario $uid en $category: $e");
      rethrow;
    }
  }

  // ╔══════════════════════════════════════════════════════════════════════════════╗
  // ║                            CÓDIGO AGREGADO/MODIFICADO                          ║
  // ╚══════════════════════════════════════════════════════════════════════════════╝
  /// Obtiene los detalles completos de los libros de la biblioteca de un usuario para una categoría específica.
  /// Los IDs de los libros se leen del documento del usuario, y luego se obtienen los detalles de la colección 'libros'.
  Future<List<Map<String, dynamic>>> getUserLibraryBooks(String uid, String category) async {
    try {
      // 1. Obtener el documento del usuario para obtener los IDs de los libros en la categoría.
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        // Si el documento del usuario no existe, no hay libros en su biblioteca.
        return [];
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      // 2. Verificar si el usuario tiene la categoría especificada o si está vacía.
      if (userData == null || !userData.containsKey(category)) {
        return [];
      }

      // 3. Extraer la lista de IDs de libros para la categoría dada.
      List<String> bookIds = List<String>.from(userData[category] ?? []);

      if (bookIds.isEmpty) {
        // Si no hay IDs de libros, regresar una lista vacía.
        return [];
      }

      // 4. Obtener los documentos completos de los libros desde la colección 'libros'
      // usando los IDs obtenidos del documento del usuario.
      QuerySnapshot booksSnapshot = await _db.collection('libros')
          .where(FieldPath.documentId, whereIn: bookIds)
          .get();

      // 5. Mapear los documentos de los libros a un formato de mapa (id + datos) y devolver la lista.
      return booksSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();

    } catch (e) {
      print("Error al obtener libros de la biblioteca ($category) para $uid: $e");
      return []; // En caso de error, devuelve una lista vacía.
    }
  }
}