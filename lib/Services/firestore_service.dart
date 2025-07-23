import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
        'verificado': false,
        'creadoEn': FieldValue.serverTimestamp(),
      };
      await _db.collection('users').doc(user.uid).set(userModel);
      print("Usuario base ${user.uid} ($userType) guardado con éxito en Firestore.");
    } catch (e) {
      print("Error al guardar el usuario base en Firestore: $e");
      rethrow;
    }
  }

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
      // Se guarda la información base del usuario primero
      await saveUser(user, username, 'Editorial', profilePictureUrl);
      
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

  Future<String?> getUserType(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      // Usar '?? {}' para asegurar que 'userData' no sea nulo antes de acceder a 'userType'
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      if (userDoc.exists && userData.containsKey('userType')) {
        return userData['userType'];
      }
      return null;
    } catch (e) {
      print("Error al obtener tipo de usuario desde 'users': $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      // Usar '?? {}' para asegurar que 'userData' no sea nulo
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      if (userDoc.exists) { // userData ya no puede ser null aquí
        return userData;
      }
      return null;
    } catch (e) {
      print("Error al obtener datos del usuario por UID: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getEditorialExtendedData(String uid) async {
    try {
      DocumentSnapshot editorialDoc = await _db.collection('editoriales').doc(uid).get();
      // Usar '?? {}' para asegurar que 'editorialData' no sea nulo
      final editorialData = editorialDoc.data() as Map<String, dynamic>? ?? {};
      if (editorialDoc.exists) { // editorialData ya no puede ser null aquí
        return editorialData;
      }
      return null;
    } catch (e) {
      print("Error al obtener datos extendidos de la editorial por UID: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> loadTags() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('etiquetas').get();
      print("Etiquetas obtenidas correctamente. Cantidad: ${querySnapshot.docs.length}");
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {}; // Asegurar que data no es null
        final String nombre = data['nombre'] as String? ?? 'Nombre no especificado';
        final Map<String, dynamic> tagData = {
          'id': doc.id,
          'nombre': nombre,
        };
        print("Etiqueta cargada: $tagData");
        return tagData;
      }).toList();
    } catch (e) {
      print("Error al obtener etiquetas: $e");
      return [];
    }
  }

  // Función privada para manejar la lógica común de guardar solicitudes de libro
  Future<void> _saveBookSubmission({
    required String uidField, // 'uidAutor' o 'uidEditorial'
    required String titulo,
    required String autor,
    required String editorial,
    required String sinopsis,
    required List<String> etiquetas,
    String? portadaUrlRevision,
    String? archivoUrlRevision,
  }) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("Usuario no autenticado. No se puede guardar la solicitud de libro.");
    }
    await _db.collection('solicitudes_publicacion').add({
      uidField: currentUser.uid,
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
  }

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
      await _saveBookSubmission(
        uidField: 'uidAutor',
        titulo: titulo,
        autor: autor,
        editorial: editorial,
        sinopsis: sinopsis,
        etiquetas: etiquetas,
        portadaUrlRevision: portadaUrlRevision,
        archivoUrlRevision: archivoUrlRevision,
      );
      print("Solicitud de publicación de libro (Autor) guardada con éxito en Firestore para revisión.");
    } catch (e) {
      print("Error al guardar la solicitud de publicación del libro (Autor) en Firestore: $e");
      rethrow;
    }
  }

  Future<void> updateBookRequest(String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection('solicitudes_publicacion').doc(docId).update(data);
      print("Solicitud de publicación de libro $docId actualizada con éxito en Firestore.");
    } catch (e) {
      print("Error al actualizar solicitud de publicación de libro $docId en Firestore: $e");
      rethrow;
    }
  }

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
      await _saveBookSubmission(
        uidField: 'uidEditorial',
        titulo: titulo,
        autor: autor,
        editorial: editorial,
        sinopsis: sinopsis,
        etiquetas: etiquetas,
        portadaUrlRevision: portadaUrlRevision,
        archivoUrlRevision: archivoUrlRevision,
      );
      print('Libro guardado en Firestore para revisión (Editoriales).');
    } catch (e) {
      print('Error al guardar libro en Firestore para revisión (Editoriales): $e');
      rethrow; // Consistencia: rethrow también aquí
    }
  }

  Future<void> updateBookForReview(String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection('solicitudes_publicacion').doc(docId).update(data);
      print("Libro en revisión $docId actualizado con éxito en Firestore (Editoriales).");
    } catch (e) {
      print("Error al actualizar libro en revisión $docId en Firestore: $e");
      rethrow;
    }
  }

  Future<void> publishBook(Map<String, dynamic> bookData) async {
    try {
      if (bookData.containsKey('fechaSolicitud')) {
        bookData['fechaPublicacion'] = bookData['fechaSolicitud'];
        bookData.remove('fechaSolicitud');
      } else {
        bookData['fechaPublicacion'] = FieldValue.serverTimestamp();
      }

      // 2. Copiar URLs de revisión a URLs finales antes de eliminarlas.
      // Esto asegura que las URLs pasen a los campos correctos en 'libros'.
      if (bookData.containsKey('portadaUrlRevision')) {
        bookData['portadaUrl'] = bookData['portadaUrlRevision'];
      }
      if (bookData.containsKey('archivoUrlRevision')) {
        bookData['archivoUrl'] = bookData['archivoUrlRevision'];
      }

      // 3. Eliminar campos temporales o de revisión que no deben ir en la colección 'libros'
      bookData.remove('portadaUrlRevision');
      bookData.remove('archivoUrlRevision');
      bookData.remove('fechaEnvio'); // Revisa si este campo es realmente necesario
      bookData.remove('uidAutor');
      bookData.remove('uidEditorial');
      bookData.remove('estado'); // El estado 'publicado' no es necesario aquí

      // *** FIN DE LA SECCIÓN CRÍTICA DE URLs CORREGIDA ***

      // Inicializar campos predeterminados para el libro publicado
      bookData['visualizaciones'] = 0;
      bookData['calificacionPromedio'] = 0.0;

      await _db.collection('libros').add(bookData);
      print("Libro '${bookData['titulo'] ?? 'Desconocido'}' publicado con éxito en la colección 'libros'.");
    } catch (e) {
      print("Error al publicar el libro en Firestore: $e");
      rethrow;
    }
  }

  Future<void> updateBookRequestStatus(String documentId, String newStatus, {String? motivoRechazo}) async {
    try {
      Map<String, dynamic> updateData = {
        'estado': newStatus,
        'fechaActualizacionEstado': FieldValue.serverTimestamp(),
      };
      if (motivoRechazo != null && motivoRechazo.isNotEmpty) {
        updateData['motivoRechazo'] = motivoRechazo;
      }
      await _db.collection('solicitudes_publicacion').doc(documentId).update(updateData);
      print("Estado de la solicitud $documentId actualizado a '$newStatus'.");
    } catch (e) {
      print("Error al actualizar el estado de la solicitud $documentId en Firestore: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('libros').orderBy('fechaPublicacion', descending: true).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {}; // Asegurar que data no es null
        return {
          'id': doc.id,
          ...data, // Usar '...' para esparcir el mapa, si 'data' es vacío no añade nada
        };
      }).toList();
    } catch (e) {
      print("Error al obtener todos los libros publicados: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBooksByTag(String tag) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('libros')
          .where('etiquetas', arrayContains: tag)
          .orderBy('fechaPublicacion', descending: true)
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print("Error al obtener libros por etiqueta '$tag': $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    if (query.isEmpty) {
      return [];
    }
    String queryLower = query.toLowerCase();
    try {
      // Ojo: Esta implementación descarga todos los libros y filtra en memoria.
      // Para grandes volúmenes de datos, considera soluciones de búsqueda como Algolia.
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

  Future<List<Map<String, dynamic>>> getMySubmittedBooks(String uid, String userType) async {
    try {
      QuerySnapshot querySnapshot;
      if (userType == 'Autor') {
        querySnapshot = await _db.collection('solicitudes_publicacion')
            .where('uidAutor', isEqualTo: uid)
            .orderBy('fechaSolicitud', descending: true)
            .get();
      } else if (userType == 'Editorial') {
        querySnapshot = await _db.collection('solicitudes_publicacion')
            .where('uidEditorial', isEqualTo: uid)
            .orderBy('fechaSolicitud', descending: true)
            .get();
      } else {
        return [];
      }
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print("Error al obtener libros enviados para revisión por $userType $uid: $e");
      return [];
    }
  }

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

  Future<List<Map<String, dynamic>>> getUserLibraryBooks(String uid, String category) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return [];
      }
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      if (!userData.containsKey(category)) { // userData ya no puede ser null aquí
        return [];
      }
      List<String> bookIds = List<String>.from(userData[category] ?? []);
      if (bookIds.isEmpty) {
        return [];
      }
      // Firestore soporta hasta 10 cláusulas 'whereIn'.
      // Si bookIds puede ser muy grande, esto necesitaría paginación o un enfoque diferente.
      QuerySnapshot booksSnapshot = await _db.collection('libros')
          .where(FieldPath.documentId, whereIn: bookIds)
          .get();
      return booksSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print("Error al obtener libros de la biblioteca ($category) para $uid: $e");
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getAllForums() {
    return _db.collection('foros_de_la_comunidad')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getThreadsCollectionGroup() {
    return _db.collectionGroup('hilos')
        .orderBy('fechacreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final pathSegments = doc.reference.path.split('/');
        // Asegurarse de que el path sea lo suficientemente largo para obtener el forumId
        final forumId = pathSegments.length >= 2 ? pathSegments[1] : null;
        return {
          'id': doc.id,
          'forumId': forumId,
          ...data,
        };
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getThreadDetails(String forumId, String threadId) async {
    try {
      DocumentSnapshot doc = await _db.collection('foros_de_la_comunidad')
          .doc(forumId)
          .collection('hilos')
          .doc(threadId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {}; // Asegurar que data no es null
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
      rethrow; // Consistencia: rethrow aquí
    }
  }

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
      rethrow; // Consistencia: rethrow aquí
    }
  }

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
      print("Comentario añadido al hilo $threadId en foro $forumId.");
    } catch (e) {
      print("Error al enviar comentario al hilo $threadId en foro $forumId: $e");
      rethrow; // Consistencia: rethrow aquí
    }
  }

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
              final data = doc.data() as Map<String, dynamic>? ?? {}; // Asegurar que data no es null
              return data;
            }).toList());
  }
}