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
        'verificado': false,
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

  // * Obtener el tipo de usuario
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

  // * Método para obtener datos del usuario por UID
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

  // * Lógica para obtener todas las etiquetas
  Future<List<Map<String, dynamic>>> loadTags() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('etiquetas').get();
      print("Etiquetas obtenidas correctamente. Cantidad: ${querySnapshot.docs.length}");

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final String nombre = data?['nombre'] as String? ?? 'Nombre no especificado';

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

  // * Nuevo método para guardar solicitudes de publicación de libros
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
        'fechaSolicitud': FieldValue.serverTimestamp(), // *** CAMBIO: Asegurado que se use fechaSolicitud ***
      });
      print("Solicitud de publicación de libro guardada con éxito en Firestore (para revisión).");
    } catch (e) {
      print("Error al guardar la solicitud de publicación del libro en Firestore: $e");
      rethrow;
    }
  }

  // * Método para actualizar solicitudes de publicación de libros existentes
  Future<void> updateBookRequest(String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection('solicitudes_publicacion').doc(docId).update(data);
      print("Solicitud de publicación de libro $docId actualizada con éxito en Firestore.");
    } catch (e) {
      print("Error al actualizar solicitud de publicación de libro $docId en Firestore: $e");
      rethrow;
    }
  }

  // * Metodos especificos para AgregarE (Editoriales - se asume que también usan 'solicitudes_publicacion')
  // Decidí unificar 'libros_en_revision' con 'solicitudes_publicacion' para simplificar el flujo
  // Si tienes una razón específica para mantener 'libros_en_revision' separado, házmelo saber.
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

      await _db.collection('solicitudes_publicacion').add({ // *** CAMBIO: Usando solicitudes_publicacion ***
        'uidEditorial': currentUser.uid, // Campo para identificar al que lo sube (editorial)
        'titulo': titulo,
        'autor': autor,
        'editorial': editorial,
        'sinopsis': sinopsis,
        'etiquetas': etiquetas,
        'portadaUrlRevision': portadaUrlRevision,
        'archivoUrlRevision': archivoUrlRevision,
        'estado': 'pendiente',
        'fechaSolicitud': FieldValue.serverTimestamp(), // *** CAMBIO: Usando fechaSolicitud ***
      });
      print('Libro guardado en Firestore para revisión (Editoriales).');
    } catch (e) {
      print('Error al guardar libro en Firestore para revisión (Editoriales): $e');
      throw Exception('Error al guardar libro en Firestore para revisión (Editoriales): $e');
    }
  }

  // * Método para actualizar libros existentes en 'solicitudes_publicacion' (unificado)
  Future<void> updateBookForReview(String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection('solicitudes_publicacion').doc(docId).update(data); // *** CAMBIO: Unificado a solicitudes_publicacion ***
      print("Libro en revisión $docId actualizado con éxito en Firestore (Editoriales).");
    } catch (e) {
      print("Error al actualizar libro en revisión $docId en Firestore: $e");
      rethrow;
    }
  }

  // --- Métodos para la nueva colección 'libros' (libros publicados/aprobados) ---
  // *** NUEVO MÉTODO PARA PUBLICAR LIBRO ***
  Future<void> publishBook(Map<String, dynamic> bookData) async {
    try {
      // Eliminar campos que solo son para revisión si están presentes y no deben ir a 'libros'
      bookData.remove('portadaUrlRevision');
      bookData.remove('archivoUrlRevision');
      bookData.remove('fechaEnvio'); // Si se usaba en solicitudes_publicacion para editoriales
      bookData.remove('uidAutor'); // Si se usaba para autores en solicitudes_publicacion
      bookData.remove('uidEditorial'); // Si se usaba para editoriales en solicitudes_publicacion

      // Renombrar 'fechaSolicitud' a 'fechaPublicacion' y quitar 'estado' de la colección 'libros'
      // Ya que en 'libros' todos están publicados.
      bookData['fechaPublicacion'] = FieldValue.serverTimestamp();
      bookData['visualizaciones'] = 0; // Inicializar visualizaciones
      bookData['calificacionPromedio'] = 0.0; // Inicializar calificación

      // Asegurarse de que los campos de URL finales sean correctos
      // Estos ya deberían venir pre-procesados en bookData desde AoD.dart
      // (ej. 'portadaUrl' y 'archivoUrl')
      // Si aún vienen como 'portadaUrlRevision' y 'archivoUrlRevision', renombrarlos aquí
      if (bookData.containsKey('portadaUrlRevision') && !bookData.containsKey('portadaUrl')) {
        bookData['portadaUrl'] = bookData['portadaUrlRevision'];
        bookData.remove('portadaUrlRevision');
      }
      if (bookData.containsKey('archivoUrlRevision') && !bookData.containsKey('archivoUrl')) {
        bookData['archivoUrl'] = bookData['archivoUrlRevision'];
        bookData.remove('archivoUrlRevision');
      }


      // Eliminar el campo 'estado' ya que en la colección 'libros' todos están publicados
      bookData.remove('estado');


      await _db.collection('libros').add(bookData);
      print("Libro '${bookData['titulo'] ?? 'Desconocido'}' publicado con éxito en la colección 'libros'.");
    } catch (e) {
      print("Error al publicar el libro en Firestore: $e");
      rethrow;
    }
  }

  // *** NUEVO MÉTODO PARA ACTUALIZAR EL ESTADO DE LA SOLICITUD DE PUBLICACIÓN ***
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
  // Se asume que todas las solicitudes (sean de Autor o Editorial) van a 'solicitudes_publicacion'
  // y se diferencian por el campo 'uidAutor' o 'uidEditorial'.
  Future<List<Map<String, dynamic>>> getMySubmittedBooks(String uid, String userType) async {
    try {
      QuerySnapshot querySnapshot;
      if (userType == 'Autor') {
        querySnapshot = await _db.collection('solicitudes_publicacion')
            .where('uidAutor', isEqualTo: uid)
            .orderBy('fechaSolicitud', descending: true)
            .get();
      } else if (userType == 'Editorial') {
        querySnapshot = await _db.collection('solicitudes_publicacion') // *** CAMBIO: Usando solicitudes_publicacion ***
            .where('uidEditorial', isEqualTo: uid)
            .orderBy('fechaSolicitud', descending: true) // *** CAMBIO: Usando fechaSolicitud ***
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
  // ║                            MÉTODOS PARA FOROS (HILOS/POSTS)                    ║
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