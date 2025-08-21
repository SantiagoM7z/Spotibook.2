import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Estadisticas/Calificaciones.dart';
import 'package:spotibook2/Pages/Index/Estadisticas/Lecturas.dart';
import 'package:spotibook2/Pages/Index/Estadisticas/LibrosLeidos.dart';
import 'package:spotibook2/Pages/Index/Estadisticas/LibrosLeidosCategoria.dart';
import 'package:spotibook2/Pages/Index/Estadisticas/lib/consts.dart';

class Estadisticas extends StatelessWidget {
  const Estadisticas({super.key});

  @override
  Widget build(BuildContext context) {
    final librosPorCategoria = getLibrosPorCategoria();
    final calificacionesData = getCalificacionesData();
    final librosPorAutor = getLibrosPorAutor();
    final lecturasPorMes = getLecturasPorMesRaw().map(
      (key, value) => MapEntry(key, ValueNotifier<int>(value)),
    );
    // we will be implementing this page for statistics
    // You can use the data above to create your statistics widgets

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Estadísticas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text('📚 Mis Libros Leídos por Categoría',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
                height: 250,
                child: LibrosLeidosCategoria(
                    librosPorCategoria: librosPorCategoria)),
            const SizedBox(height: 24),
            const Text('✍️ Cantidad de mis Libros Leídos (Autor)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
                height: 250,
                child: LibrosLeidosAutor(librosPorAutor: librosPorAutor)),
            const SizedBox(height: 24),
            const Text('⭐ Calificaciones Recibidas por mis Libros (Autor)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
                height: 250,
                child: Calificaciones(calificaciones: calificacionesData)),
            const SizedBox(height: 24),
            const Text('📈 Mis Lecturas Este Mes',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
                height: 250, child: Lecturas(lecturasPorMes: lecturasPorMes)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
