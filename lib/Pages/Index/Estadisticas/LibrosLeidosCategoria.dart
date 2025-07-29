import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LibrosLeidosCategoria extends StatefulWidget {
  final Map<String, dynamic> librosPorCategoria;

  const LibrosLeidosCategoria({
    super.key,
    required this.librosPorCategoria,
  });

  @override
  State<LibrosLeidosCategoria> createState() => _LibrosLeidosCategoriaState();
}

class _LibrosLeidosCategoriaState extends State<LibrosLeidosCategoria> {
  @override
  Widget build(BuildContext context) {
    final librosPorCategoria = widget.librosPorCategoria;

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = librosPorCategoria.keys.elementAt(group.x);
              final value = rod.toY.toInt();
              return BarTooltipItem(
                '$label\n$value libros',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        barGroups: librosPorCategoria.entries
            .toList()
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value.toDouble(),
                    color: Colors.blue,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            )
            .toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= librosPorCategoria.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    librosPorCategoria.keys.elementAt(index),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
