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
  Future<List<Map<String, dynamic>>> loadTags() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('etiquetas').get();
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
  Future<void> saveBookRequest({
    required String titulo,
    required String autor,
    required String editorial,
    required String sinopsis,
    required List<String> etiquetas,
    String? portadaUrlRevision,
    String? archivoUrlRevision,
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
        'portadaUrlRevision': portadaUrlRevision,
        'archivoUrlRevision': archivoUrlRevision,
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
  Future<void> saveBookForReview({
    required String titulo,
    required String autor,
    required String editorial,
    required String sinopsis,
    required List<String> etiquetas,
    String? portadaUrlRevision,
    String? archivoUrlRevision,
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
        'portadaUrlRevision': portadaUrlRevision,
        'archivoUrlRevision': archivoUrlRevision,
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
  Future<void> publishBook({
    required String titulo,
    required String autor,
    required String uidOrigin,
    required String editorial,
    required String sinopsis,
    required List<String> etiquetas,
    required String portadaUrlPublica,
    required String archivoUrlPublico,
    required String idSolicitudOriginal,
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
        'idSolicitudOriginal': idSolicitudOriginal,
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
      return querySnapshot.docs.map((doc) {
        // Garantizar que data es un Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>?;
        return {
          'id': doc.id,
          ...(data ?? {}),
        };
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

      return querySnapshot.docs.map((doc) {
        // Garantizar que data es un Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>?;
        return {
          'id': doc.id,
          ...(data ?? {}),
        };
      }).toList();
    } catch (e) {
      print("Error al obtener libros enviados para revisión por $userType $uid: $e");
      return [];
    }
  }

  // --- Métodos para interacciones del usuario con libros (añadir a biblioteca, etc.) ---
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

  /// Obtiene los detalles completos de los libros de la biblioteca de un usuario para una categoría específica.
  Future<List<Map<String, dynamic>>> getUserLibraryBooks(String uid, String category) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return [];
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null || !userData.containsKey(category)) {
        return [];
      }

      List<String> bookIds = List<String>.from(userData[category] ?? []);

      if (bookIds.isEmpty) {
        return [];
      }

      QuerySnapshot booksSnapshot = await _db.collection('libros')
          .where(FieldPath.documentId, whereIn: bookIds)
          .get();

      return booksSnapshot.docs.map((doc) {
        // Garantizar que data es un Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>?;
        return {
          'id': doc.id,
          ...(data ?? {}),
        };
      }).toList();
    } catch (e) {
      print("Error al obtener libros de la biblioteca ($category) para $uid: $e");
      return [];
    }
  }

  // ╔══════════════════════════════════════════════════════════════════════════════╗
  // ║                            MÉTODOS PARA FOROS (HILOS/POSTS)                   ║
  // ╚══════════════════════════════════════════════════════════════════════════════╝

  /// Obtiene todos los FOROS principales de la colección 'foros_de_la_comunidad'.
  Stream<List<Map<String, dynamic>>> getAllForums() {
    return _db.collection('foros_de_la_comunidad')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Obtener los datos como Map<String, dynamic> directamente.
        // Si doc.data() es null, se usará un mapa vacío.
        final data = doc.data() as Map<String, dynamic>?;
        return {
          'id': doc.id,
          ...(data ?? {}), // Usar el operador de propagación nulo-consciente
        };
      }).toList();
    });
  }

  /// Obtiene todos los HILOS/POSTS de la subcolección 'hilos' de CUALQUIER foro.
  /// Requiere un índice de grupo de colecciones para 'hilos' en Firestore.
  Stream<List<Map<String, dynamic>>> getThreadsCollectionGroup() {
    return _db.collectionGroup('hilos')
        .orderBy('fechacreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Obtener los datos como Map<String, dynamic> directamente.
        // Si doc.data() es null, se usará un mapa vacío.
        final data = doc.data() as Map<String, dynamic>?;
        // Parsear la ruta para obtener el forumId de forma explícita
        final pathSegments = doc.reference.path.split('/');
        final forumId = pathSegments.length >= 2 ? pathSegments[1] : null; // Asumiendo estructura "coleccion/documento/subcoleccion/documento"

        return {
          'id': doc.id, // ID del hilo
          'forumId': forumId, // Usar el forumId extraído
          ...(data ?? {}), // Usar el operador de propagación nulo-consciente
        };
      }).toList();
    });
  }

  /// Obtiene los detalles de un hilo/post específico dentro de un foro específico.
  Future<Map<String, dynamic>?> getThreadDetails(String forumId, String threadId) async {
    try {
      DocumentSnapshot doc = await _db.collection('foros_de_la_comunidad')
          .doc(forumId)
          .collection('hilos')
          .doc(threadId)
          .get();

      if (doc.exists) {
        // Si doc.exists es true, doc.data() no será null y será de tipo Map<String, dynamic>.
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'forumId': forumId,
          ...data,
        };
      }
      return null;
    } catch (e) {
      print("Error al obtener detalles del hilo $threadId en foro $forumId: $e");
      return null;
    }
  }

  /// Crea un nuevo foro principal en la colección 'foros_de_la_comunidad'.
  Future<String?> createForum({
    required String nombreForo,
    required String creadorForoName,
    required String creadorForoUid,
  }) async {
    try {
      DocumentReference docRef = await _db.collection('foros_de_la_comunidad').add({
        'nombre_foro': nombreForo,
        'creador_foro_name': creadorForoName,
        'creador_foro_uid': creadorForoUid,
        'fecha_creacion_foro': FieldValue.serverTimestamp(),
        'miembros_foro': [creadorForoUid],
      });
      print("Foro principal creado con ID: ${docRef.id}.");
      return docRef.id;
    } catch (e) {
      print("Error al crear foro principal: $e");
      return null;
    }
  }

  /// Crea un nuevo hilo/post dentro de la subcolección 'hilos' de un foro específico.
  Future<String?> createThread({
    required String forumId,
    required String titulo,
    required String contenido,
    required String autorpostname,
    required String uidcreador,
  }) async {
    try {
      DocumentReference docRef = await _db
          .collection('foros_de_la_comunidad')
          .doc(forumId)
          .collection('hilos')
          .add({
        'titulo': titulo,
        'contenido': contenido,
        'autorpostname': autorpostname,
        'uidcreador': uidcreador,
        'fechacreacion': FieldValue.serverTimestamp(),
      });
      print("Hilo/Post creado con ID: ${docRef.id} en foro $forumId.");
      return docRef.id;
    } catch (e) {
      print("Error al crear hilo/post en foro $forumId: $e");
      return null;
    }
  }

  /// Añade un comentario a la subcolección 'comentarios' de un hilo/post específico dentro de un foro.
  Future<void> addCommentToThread({
    required String forumId,
    required String threadId,
    required String texto,
    required String autorcomentarioname,
    required String uidcomentario,
  }) async {
    try {
      await _db
          .collection('foros_de_la_comunidad')
          .doc(forumId)
          .collection('hilos')
          .doc(threadId)
          .collection('comentarios')
          .add({
        'texto': texto,
        'autorcomentarioname': autorcomentarioname,
        'uidcomentario': uidcomentario,
        'publicacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error al enviar comentario al hilo $threadId en foro $forumId: $e");
    }
  }

  /// Obtiene los comentarios en tiempo real de un hilo/post específico dentro de un foro.
  Stream<List<Map<String, dynamic>>> getCommentsForThread(String forumId, String threadId) {
    return _db
        .collection('foros_de_la_comunidad')
        .doc(forumId)
        .collection('hilos')
        .doc(threadId)
        .collection('comentarios')
        .orderBy('publicacion', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          // Obtener los datos como Map<String, dynamic> directamente, o un mapa vacío si es null
          final data = doc.data() as Map<String, dynamic>?;
          return data ?? {}; // Retornar el mapa, o un mapa vacío si es nulo
        }).toList());
  }
}