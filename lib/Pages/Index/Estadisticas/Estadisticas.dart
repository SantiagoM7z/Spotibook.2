import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Estadisticas/LibrosLeidosCategoria.dart';
import 'package:spotibook2/Pages/Index/Estadisticas/LibrosLeidos.dart';
import 'package:spotibook2/Pages/Index/Estadisticas/lib/consts.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Estadisticas extends StatefulWidget {
  const Estadisticas({super.key});

  @override
  State<Estadisticas> createState() => _EstadisticasState();
}

class _EstadisticasState extends State<Estadisticas> {
  late Future<Map<String, dynamic>> _estadisticasFuture;
  late Future<List<String>> _librosLeidosFuture;
  final EstadisticasService _service = EstadisticasService();

  @override
  void initState() {
    super.initState();
    _estadisticasFuture = _service.getEstadisticas();
    _librosLeidosFuture = _service.getLibrosLeidosIds();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        color:
            const Color(0xffF9FAFB), // Light gray background like in the image
        child: FutureBuilder<Map<String, dynamic>>(
          future: _estadisticasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: SpinKitFadingCircle(color: Color(0xff2E4D4D)));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No hay datos para mostrar.'));
            }
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Header section
                  const Text(
                    'Métricas clave',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff1a1a1a),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Metrics grid
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Visualizaciones',
                              data['visualizaciones'] ?? 0,
                              '',
                              '',
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              'Me gusta',
                              data['likes'] ?? 0,
                              '',
                              '',
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Comentarios',
                              data['comentarios'] ?? 0,
                              '',
                              '',
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              'Veces compartido',
                              data['compartidos'] ?? 0,
                              '',
                              '',
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Calificación promedio',
                              (data['calificacionPromedio'] ?? 0.0)
                                  .toStringAsFixed(1),
                              '',
                              '',
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              'Total de libros',
                              data['librosCount'] ?? 0,
                              '',
                              '',
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Chart showing book metrics trend
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xffE5E7EB), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tendencia de interacciones',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff111827),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: CustomPaint(
                            size: const Size(double.infinity, 150),
                            painter: _MetricsChartPainter(
                              visualizaciones: data['visualizaciones'] ?? 0,
                              likes: data['likes'] ?? 0,
                              comentarios: data['comentarios'] ?? 0,
                              compartidos: data['compartidos'] ?? 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Inicio',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff6B7280),
                              ),
                            ),
                            Text(
                              'Actual',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('📚 Libros por Categoría',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LibrosLeidosCategoria(
                        librosPorCategoria: (data['librosPorCategoria'] ?? {})
                            as Map<String, int>),
                  ),
                  const SizedBox(height: 32),
                  // Libros Leidos section
                  const Text('📖 Libros Leídos',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  FutureBuilder<List<String>>(
                    future: _librosLeidosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xffE5E7EB), width: 1),
                          ),
                          child: const Center(
                            child: Text(
                              'No hay libros leídos para mostrar',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff6B7280),
                              ),
                            ),
                          ),
                        );
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xffE5E7EB), width: 1),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 300,
                          child: LibrosLeidos(
                            libros: snapshot.data!,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, dynamic value, String change,
      String percentage, Color changeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff6B7280),
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xff111827),
            ),
          ),
          if (change.isNotEmpty) const SizedBox(height: 6),
          if (change.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 16,
                  color: changeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: changeColor,
                  ),
                ),
                if (percentage.isNotEmpty) const SizedBox(width: 4),
                if (percentage.isNotEmpty)
                  Text(
                    percentage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff6B7280),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MetricsChartPainter extends CustomPainter {
  final int visualizaciones;
  final int likes;
  final int comentarios;
  final int compartidos;

  _MetricsChartPainter({
    required this.visualizaciones,
    required this.likes,
    required this.comentarios,
    required this.compartidos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff3B82F6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xff3B82F6).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Calculate total interactions for scaling
    final total = visualizaciones + likes + comentarios + compartidos;
    if (total == 0) {
      // Draw a flat line if no data
      final flatY = size.height * 0.5;
      canvas.drawLine(
        Offset(0, flatY),
        Offset(size.width, flatY),
        paint,
      );
      return;
    }

    // Create data points based on your actual metrics
    // Simulating growth trend using your actual data proportions
    final points = <Offset>[];
    final metrics = [
      compartidos.toDouble(), // Start with smallest usually
      comentarios.toDouble(),
      likes.toDouble(),
      visualizaciones.toDouble(), // Usually the highest
    ];

    // Normalize and create ascending trend
    final maxMetric = metrics.reduce((a, b) => a > b ? a : b);
    for (int i = 0; i < metrics.length; i++) {
      final x = (size.width / (metrics.length - 1)) * i;
      final normalizedValue = maxMetric > 0 ? metrics[i] / maxMetric : 0;
      final y = size.height -
          (size.height * 0.2) -
          (normalizedValue * size.height * 0.6);
      points.add(Offset(x, y));
    }

    // Create smooth curve path
    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      // Create smooth curves between points
      for (int i = 1; i < points.length; i++) {
        final prevPoint = points[i - 1];
        final currentPoint = points[i];
        final controlPointX = (prevPoint.dx + currentPoint.dx) / 2;

        path.quadraticBezierTo(
          controlPointX,
          prevPoint.dy,
          currentPoint.dx,
          currentPoint.dy,
        );
      }
    }

    // Create filled area path
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Draw filled area first
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = const Color(0xff3B82F6)
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final point in points) {
      // White border
      canvas.drawCircle(point, 5, pointBorderPaint);
      // Blue center
      canvas.drawCircle(point, 3, pointPaint);
    }

    // Add value labels for the highest point
    if (points.isNotEmpty) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );

      // Find the highest point
      var highestPoint = points[0];
      var highestValue = metrics[0];
      for (int i = 1; i < points.length; i++) {
        if (metrics[i] > highestValue) {
          highestValue = metrics[i];
          highestPoint = points[i];
        }
      }

      // Draw the highest value label
      textPainter.text = TextSpan(
        text: highestValue.toInt().toString(),
        style: const TextStyle(
          color: Color(0xff374151),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();

      // Position label above the point
      final labelX = highestPoint.dx - (textPainter.width / 2);
      final labelY = highestPoint.dy - 25;
      textPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
