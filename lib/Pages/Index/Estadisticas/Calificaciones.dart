import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Calificaciones extends StatelessWidget {
  final Map<String, int> calificaciones;

  const Calificaciones({Key? key, required this.calificaciones})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = calificaciones.values.fold(0, (a, b) => a + b);
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.cyan,
      Colors.teal,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: PieChart(
            PieChartData(
              sections: List.generate(calificaciones.length, (index) {
                final entry = calificaciones.entries.elementAt(index);
                final autor = entry.key;
                final value = entry.value;
                final percent = total == 0 ? 0 : (value / total) * 100;

                return PieChartSectionData(
                  value: value.toDouble(),
                  title: '$autor\n${percent.toStringAsFixed(1)}%',
                  color: colors[index % colors.length],
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  titlePositionPercentageOffset: 0.6,
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          children: calificaciones.keys.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: colors[index % colors.length],
                ),
                const SizedBox(width: 4),
                Text(label),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
