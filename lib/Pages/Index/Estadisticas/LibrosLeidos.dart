import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LibrosLeidos extends StatefulWidget {
  final List<String> libros;

  const LibrosLeidos({super.key, required this.libros});

  @override
  State<LibrosLeidos> createState() => _LibrosLeidosState();
}

class _LibrosLeidosState extends State<LibrosLeidos> {
  static const List<Color> pieColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final libros = widget.libros;
    // Count occurrences of each book
    final Map<String, int> librosCounts = {};
    for (final libro in libros) {
      librosCounts[libro] = (librosCounts[libro] ?? 0) + 1;
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "Libros Leídos: ${libros.length}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (libros.isEmpty)
          const Text("No hay libros para mostrar")
        else
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: _getSections(librosCounts),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: _buildLegend(librosCounts),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getSections(Map<String, int> librosCounts) {
    int index = 0;
    return librosCounts.entries.map((entry) {
      final color = pieColors[index % pieColors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend(Map<String, int> librosCounts) {
    int index = 0;
    return librosCounts.entries.map((entry) {
      final color = pieColors[index % pieColors.length];
      index++;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.key,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('${entry.value}'),
          ],
        ),
      );
    }).toList();
  }
}
