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
      final librosLeidos = userData?['libros_leidos'] as List<dynamic>?;

      if (librosLeidos == null || librosLeidos.isEmpty) return {};

      Map<String, int> librosPorAutor = {};

      // Get book details for each book in libros_leidos
      for (final libroId in librosLeidos) {
        try {
          final libroDoc = await firestore
              .collection('libros')
              .doc(libroId.toString())
              .get();
          if (libroDoc.exists) {
            final libroData = libroDoc.data();
            final autor = libroData?['autor'] as String? ?? 'Autor desconocido';
            librosPorAutor[autor] = (librosPorAutor[autor] ?? 0) + 1;
          }
        } catch (e) {
          // Skip this book if there's an error
          continue;
        }
      }

      return librosPorAutor;
    } catch (e) {
      return {};
    }
  }
}
