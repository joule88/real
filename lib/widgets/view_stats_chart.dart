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

  static const Color primaryChartColor = Color(0xFFDAF365);
  static const Color secondaryChartColor = Color(0xFFB8D93A);
  static const Color activeChipColor = Color(0xFFDAF365);
  static const Color inactiveChipColor = Colors.white;
  static const Color activeChipTextColor = Color(0xFF121212);
  static const Color inactiveChipTextColor = Color(0xFF333333);

  List<FlSpot> _createLineSpots(Map<String, int> data) {
    List<FlSpot> spots = [];
    int i = 0;
    data.forEach((label, value) {
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
      i++;
    });
    return spots;
  }

  Widget _bottomTitlesWidget(double value, TitleMeta meta, Map<String, int> data) {
    final labels = data.keys.toList();
    final int index = value.toInt();

    int interval = (labels.length / 7).ceil();
    if (interval < 1) interval = 1;

    if (index % interval == 0 && index < labels.length) {
      final String text = labels[index];
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.w500),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> currentActiveData =
        _selectedPeriod == 'daily' ? widget.dailyChartData : widget.monthlyChartData;

    final spots = _createLineSpots(currentActiveData);
    final double maxYValue = currentActiveData.values.fold(0.0, (max, v) => v > max ? v.toDouble() : max);

    if (currentActiveData.isEmpty || spots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            // ENGLISH TRANSLATION
            "View data for this period is not yet available.",
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
              // ENGLISH TRANSLATION
              label: Text('Daily', style: GoogleFonts.poppins(fontSize: 13, color: _selectedPeriod == 'daily' ? activeChipTextColor : inactiveChipTextColor, fontWeight: FontWeight.w600)),
              selected: _selectedPeriod == 'daily',
              onSelected: (selected) {
                if (selected) setState(() => _selectedPeriod = 'daily');
              },
              backgroundColor: _selectedPeriod == 'daily' ? activeChipColor : inactiveChipColor,
              selectedColor: activeChipColor,
              checkmarkColor: activeChipTextColor,
              elevation: 1.5,
              pressElevation: 3,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
            ),
            const SizedBox(width: 10),
            FilterChip(
              // ENGLISH TRANSLATION
              label: Text('Monthly', style: GoogleFonts.poppins(fontSize: 13, color: _selectedPeriod == 'monthly' ? activeChipTextColor : inactiveChipTextColor, fontWeight: FontWeight.w600)),
              selected: _selectedPeriod == 'monthly',
              onSelected: (selected) {
                if (selected) setState(() => _selectedPeriod = 'monthly');
              },
              backgroundColor: _selectedPeriod == 'monthly' ? activeChipColor : inactiveChipColor,
              selectedColor: activeChipColor,
              checkmarkColor: activeChipTextColor,
              elevation: 1.5,
              pressElevation: 3,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        SizedBox(
          height: 280,
          child: LineChart(
            LineChartData(
              maxY: maxYValue > 0 ? maxYValue * 1.25 : 10,
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  );
                },
                horizontalInterval: maxYValue > 10 ? (maxYValue / 5).roundToDouble() : (maxYValue > 0 ? (maxYValue/2).clamp(1, maxYValue) : 2),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => _bottomTitlesWidget(value, meta, currentActiveData),
                    reservedSize: 30,
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max || (value == 0 && maxYValue > 0)) return const SizedBox.shrink();
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
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  gradient: const LinearGradient(
                    colors: [
                      primaryChartColor,
                      secondaryChartColor,
                    ],
                  ),
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        primaryChartColor.withOpacity(0.3),
                        primaryChartColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((spotIndex) {
                    return TouchedSpotIndicatorData(
                      const FlLine(
                        color: secondaryChartColor,
                        strokeWidth: 2,
                        dashArray: [3, 3],
                      ),
                      FlDotData(
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeColor: primaryChartColor,
                          );
                        },
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.grey[850]!.withOpacity(0.9),
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final flSpot = barSpot;
                      final labels = currentActiveData.keys.toList();
                      String title = (flSpot.x.toInt() >= 0 && flSpot.x.toInt() < labels.length)
                          ? labels[flSpot.x.toInt()]
                          : '';
                      return LineTooltipItem(
                        '$title\n',
                        GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: flSpot.y.round().toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            // ENGLISH TRANSLATION
                            text: ' views',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                        textAlign: TextAlign.left,
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}