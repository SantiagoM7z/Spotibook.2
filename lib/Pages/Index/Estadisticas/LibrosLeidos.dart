import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LibrosLeidosAutor extends StatefulWidget {
  final Map<String, int> librosPorAutor;

  const LibrosLeidosAutor({super.key, required this.librosPorAutor});

  @override
  State<LibrosLeidosAutor> createState() => _LibrosLeidosAutorState();
}

class _LibrosLeidosAutorState extends State<LibrosLeidosAutor> {
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
    final librosPorAutor = widget.librosPorAutor;
    final total = librosPorAutor.values.isNotEmpty
        ? librosPorAutor.values.reduce((a, b) => a + b)
        : 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: PieChart(
            PieChartData(
              sections:
                  librosPorAutor.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final autor = entry.value.key;
                final cantidad = entry.value.value;
                final percent = (cantidad / total) * 100;

                return PieChartSectionData(
                  value: cantidad.toDouble(),
                  title: '$autor\n${percent.toStringAsFixed(1)}%',
                  color: pieColors[index % pieColors.length],
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  titlePositionPercentageOffset: 0.6,
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          children: librosPorAutor.keys.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final autor = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: pieColors[index % pieColors.length],
                ),
                const SizedBox(width: 4),
                Text(autor),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
