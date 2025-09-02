import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EstadisticasService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  EstadisticasService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  Future<String?> getCurrentUsername() async {
    final user = auth.currentUser;
    if (user == null) return null;
    final userDoc = await firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return null;
    return userDoc.data()?['username'] as String?;
  }

  Future<List<Map<String, dynamic>>> getLibrosByCurrentUser() async {
    final username = await getCurrentUsername();
    if (username == null) return [];
    final query = await firestore
        .collection('libros')
        .where('autor', isEqualTo: username)
        .get();
    return query.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>> getEstadisticas() async {
    final libros = await getLibrosByCurrentUser();
    int visualizaciones = 0;
    int likes = 0;
    int comentarios = 0;
    int compartidos = 0;
    double calificacionPromedio = 0;
    int librosCount = libros.length;
    Map<String, int> librosPorCategoria = {};
    List<double> calificaciones = [];

    for (final libro in libros) {
      visualizaciones += (libro['visualizaciones'] ?? 0) as int;
      likes += (libro['likes'] ?? 0) as int;
      comentarios += (libro['comentarios'] ?? 0) as int;
      compartidos += (libro['compartidos'] ?? 0) as int;
      if (libro['calificacionPromedio'] != null) {
        calificaciones.add((libro['calificacionPromedio'] as num).toDouble());
      }
      if (libro['etiquetas'] != null && libro['etiquetas'] is List) {
        for (final cat in (libro['etiquetas'] as List)) {
          librosPorCategoria[cat] = (librosPorCategoria[cat] ?? 0) + 1;
        }
      }
    }
    if (calificaciones.isNotEmpty) {
      calificacionPromedio =
          calificaciones.reduce((a, b) => a + b) / calificaciones.length;
    }
    return {
      'visualizaciones': visualizaciones,
      'likes': likes,
      'comentarios': comentarios,
      'compartidos': compartidos,
      'calificacionPromedio': calificacionPromedio,
      'librosCount': librosCount,
      'librosPorCategoria': librosPorCategoria,
    };
  }

  Future<Map<String, int>> getLibrosLeidosByAutor() async {
    final user = auth.currentUser;
    if (user == null) return {};

    try {
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return {};

      final userData = userDoc.data();
      final librosLeidosRaw = userData?['libros_leidos'];

      print('Debug - libros_leidos raw data: $librosLeidosRaw');
      print('Debug - libros_leidos type: ${librosLeidosRaw.runtimeType}');

      // libros_leidos should be an array of strings
      if (librosLeidosRaw == null || librosLeidosRaw is! List) {
        print('Debug - libros_leidos is not a list or is null');
        return {};
      }

      final librosLeidosIds = librosLeidosRaw.cast<String>();

      if (librosLeidosIds.isEmpty) {
        print('Debug - libros_leidos list is empty');
        return {};
      }

      print('Debug - Book IDs to fetch: $librosLeidosIds');

      Map<String, int> librosPorAutor = {};

      // Get book details for each book in libros_leidos
      for (final libroId in librosLeidosIds) {
        try {
          print('Debug - Fetching book with ID: $libroId');
          final libroDoc =
              await firestore.collection('libros').doc(libroId).get();
          if (libroDoc.exists) {
            final libroData = libroDoc.data();
            final autor = libroData?['autor'] as String? ?? 'Autor desconocido';
            print('Debug - Found book by author: $autor');
            librosPorAutor[autor] = (librosPorAutor[autor] ?? 0) + 1;
          } else {
            print('Debug - Book document $libroId does not exist');
          }
        } catch (e) {
          // Skip this book if there's an error
          print('Error fetching book $libroId: $e');
          continue;
        }
      }

      print('Debug - Final result: $librosPorAutor');
      return librosPorAutor;
    } catch (e) {
      print('Error in getLibrosLeidosByAutor: $e');
      return {};
    }
  }

  Future<List<String>> getLibrosLeidosIds() async {
    final user = auth.currentUser;
    if (user == null) return [];

    try {
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data();
      final librosLeidosRaw = userData?['libros_leidos'];

      // libros_leidos should be an array of strings
      if (librosLeidosRaw == null || librosLeidosRaw is! List) {
        return [];
      }

      final librosLeidosIds = librosLeidosRaw.cast<String>();
      return librosLeidosIds;
    } catch (e) {
      print('Error in getLibrosLeidosIds: $e');
      return [];
    }
  }
}
