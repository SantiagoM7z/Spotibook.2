import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Lecturas extends StatefulWidget {
  final Map<String, ValueNotifier<int>> lecturasPorMes;

  const Lecturas({super.key, required this.lecturasPorMes});

  @override
  State<Lecturas> createState() => _LecturasState();
}

class _LecturasState extends State<Lecturas> {
  @override
  Widget build(BuildContext context) {
    final lecturasPorMes = widget.lecturasPorMes;

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: lecturasPorMes.entries
                .toList()
                .asMap()
                .entries
                .map((entry) => FlSpot(
                    entry.key.toDouble(), entry.value.value.value.toDouble()))
                .toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= lecturasPorMes.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    lecturasPorMes.keys.elementAt(index),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final month = lecturasPorMes.keys.elementAt(index);
                final value = spot.y.toInt();
                return LineTooltipItem(
                  '$month\n$value libros',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
