// lib/widgets/view_stats_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewStatsChart extends StatefulWidget {
  final Map<String, int> dailyChartData;
  final Map<String, int> monthlyChartData;

  const ViewStatsChart({
    super.key,
    required this.dailyChartData,
    required this.monthlyChartData,
  });

  @override
  State<ViewStatsChart> createState() => _ViewStatsChartState();
}

class _ViewStatsChartState extends State<ViewStatsChart> {
  String _selectedPeriod = 'daily';

  List<BarChartGroupData> _createBarGroups(Map<String, int> data) {
    List<BarChartGroupData> barGroups = [];
    int i = 0;
    data.forEach((label, value) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: Theme.of(context).colorScheme.secondary,
              width: 18,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
      i++;
    });
    return barGroups;
  }

  Widget _bottomTitlesWidget(double value, TitleMeta meta, Map<String, int> data) {
    final labels = data.keys.toList();
    final String text = (value.toInt() >= 0 && value.toInt() < labels.length)
        ? labels[value.toInt()]
        : '';
    bool rotate = labels.length > 7 && _selectedPeriod == 'daily';

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: rotate ? 12 : 8,
      angle: rotate ? -0.785 : 0,
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[700]),
        textAlign: rotate ? TextAlign.right : TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> currentActiveData =
        _selectedPeriod == 'daily' ? widget.dailyChartData : widget.monthlyChartData;

    final barGroups = _createBarGroups(currentActiveData);
    final double maxYValue = currentActiveData.values.fold(0.0, (max, v) => v > max ? v.toDouble() : max);

    if (currentActiveData.isEmpty && barGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            "Data tampilan untuk periode ini belum tersedia.",
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilterChip(
              label: Text('Harian', style: GoogleFonts.poppins(fontSize: 13, color: _selectedPeriod == 'daily' ? Colors.white : Theme.of(context).primaryColorDark)),
              selected: _selectedPeriod == 'daily',
              onSelected: (selected) {
                if (selected) setState(() => _selectedPeriod = 'daily');
              },
              backgroundColor: _selectedPeriod == 'daily' ? Theme.of(context).primaryColorDark : Colors.grey[200],
              selectedColor: Theme.of(context).primaryColorDark,
              checkmarkColor: Colors.white,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
               shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _selectedPeriod == 'daily' ? Theme.of(context).primaryColorDark : Colors.grey[400]!,
                  width: 1
                )
              ),
            ),
            const SizedBox(width: 10),
            FilterChip(
              label: Text('Bulanan', style: GoogleFonts.poppins(fontSize: 13, color: _selectedPeriod == 'monthly' ? Colors.white : Theme.of(context).primaryColorDark)),
              selected: _selectedPeriod == 'monthly',
              onSelected: (selected) {
                if (selected) setState(() => _selectedPeriod = 'monthly');
              },
              backgroundColor: _selectedPeriod == 'monthly' ? Theme.of(context).primaryColorDark : Colors.grey[200],
              selectedColor: Theme.of(context).primaryColorDark,
              checkmarkColor: Colors.white,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _selectedPeriod == 'monthly' ? Theme.of(context).primaryColorDark : Colors.grey[400]!,
                  width: 1
                )
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        SizedBox(
          height: 280,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxYValue > 0 ? maxYValue * 1.25 : 10,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  // **PERUBAHAN DI SINI**
                  // Menggunakan (BarChartGroupData) untuk signature callback
                  getTooltipColor: (BarChartGroupData group) {
                    return Colors.black87;
                  },
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final labels = currentActiveData.keys.toList();
                    String title = (groupIndex >= 0 && groupIndex < labels.length)
                        ? labels[groupIndex]
                        : '';
                    return BarTooltipItem(
                      '$title\n',
                      GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: rod.toY.round().toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: ' dilihat',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => _bottomTitlesWidget(value, meta, currentActiveData),
                    reservedSize: currentActiveData.keys.length > 7 && _selectedPeriod == 'daily' ? 45 : 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max || (value == 0 && maxYValue > 0)) return Container();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child: Text(meta.formattedValue, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[700])),
                      );
                    },
                    interval: maxYValue > 10 ? (maxYValue / 5).roundToDouble() : (maxYValue > 0 ? (maxYValue/2).clamp(1, maxYValue) : 2),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(
                    color: Color(0xffeef0f2),
                    strokeWidth: 1,
                  );
                },
                horizontalInterval: maxYValue > 10 ? (maxYValue / 5).roundToDouble() : (maxYValue > 0 ? (maxYValue/2).clamp(1, maxYValue) : 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}