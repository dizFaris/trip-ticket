import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/earnings_entry_model.dart';

class SimpleBarChart extends StatefulWidget {
  final List<EarningsEntry> data;

  const SimpleBarChart({super.key, required this.data});

  @override
  SimpleBarChartState createState() => SimpleBarChartState();
}

class SimpleBarChartState extends State<SimpleBarChart> {
  int touchedIndex = -1;

  Color get barColor => AppColors.primaryGreen;
  Color get touchedBarColor => Colors.greenAccent;
  Color get barBackgroundColor => Colors.greenAccent.withAlpha(76);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        child: BarChart(
          BarChartData(
            maxY: _getMaxY(),
            barTouchData: BarTouchData(
              touchCallback: (event, response) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.spot == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex = response.spot!.touchedBarGroupIndex;
                });
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final label = widget.data[group.x.toInt()].label;
                  final value =
                      rod.toY - (touchedIndex == group.x.toInt() ? 1 : 0);
                  return BarTooltipItem(
                    '$label\n${value.toStringAsFixed(1)} €',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= widget.data.length) {
                      return const SizedBox.shrink();
                    }
                    final label = widget.data[index].label;
                    return SideTitleWidget(
                      meta: meta,
                      space: 8,
                      child: Text(
                        label,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withAlpha(76),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
            ),
            barGroups: _makeBarGroups(),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (widget.data.isEmpty) return 10;
    final maxVal = widget.data
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    return maxVal + 5;
  }

  List<BarChartGroupData> _makeBarGroups() {
    return List.generate(widget.data.length, (index) {
      final isTouched = index == touchedIndex;
      final value = widget.data[index].value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: isTouched ? value + 1 : value,
            color: isTouched ? touchedBarColor : barColor,
            width: 20,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: barBackgroundColor,
            ),
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    });
  }
}
