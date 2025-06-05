import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:cheart/models/graph_models.dart';
import 'package:cheart/screens/graph_screen_constants.dart';
import 'package:cheart/themes/cheart_theme.dart';


class LineGraph extends StatelessWidget {
  // The active time filter to determine which data set is shown.
  final TimeFilter filter;

  // Hourly data for `TimeFilter.hourly`
  final List<HourlyPoint>? hourlyPoints;

  // Daily data for `TimeFilter.daily`, `TimeFilter.weekly`, `TimeFilter.monthly`
  final List<DailyStat>? dailyStats;

  final double minY;
  final double maxY;

  const LineGraph({
    super.key,
    required this.filter,
    this.hourlyPoints,
    this.dailyStats,
    this.minY = 0,
    this.maxY = 60,
  }) : assert(
         (filter == TimeFilter.hourly && hourlyPoints != null) ||
         (filter != TimeFilter.hourly && dailyStats != null),
         'Provide hourlyPoints for hourly filter, dailyStats otherwise'
       );

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.onBackground;
    final titleStyle = GraphScreenConstants.getCardTitleStyle(context);
    final valueStyle = GraphScreenConstants.getCardValueStyle(context);
    final spots = _buildSpots();
    final bounds = _calculateXAxisBounds(spots);
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: LineChart(
        LineChartData(
          minX: bounds['minX'],
          maxX: bounds['maxX'],
          minY: minY,
          maxY: maxY,
          gridData: _buildGridData(bgColor),
          titlesData: _buildTitlesData(context, bounds['minX'], bounds['maxX']),
          lineTouchData: _buildTouchData(valueStyle, dayStart),
          lineBarsData: [_buildLineBarData(spots)],
        ),
      ),
    );
  }

  // Converts either hourly or daily data to FlSpot points for chart rendering.
  List<FlSpot> _buildSpots() {
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);

    if (filter == TimeFilter.hourly) {
      return hourlyPoints!.map((p) {
        final hoursSinceMidnight =
            p.time.difference(dayStart).inMilliseconds / 3600000;
        return FlSpot(hoursSinceMidnight, p.bpm);
      }).toList();
    } else {
      return dailyStats!
          .map((d) => FlSpot(d.date.day.toDouble(), d.avgBpm))
          .toList();
    }
  }

  // Calculates x-axis min and max for hourly view.
  Map<String, double?> _calculateXAxisBounds(List<FlSpot> spots) {
    if (filter != TimeFilter.hourly) return {'minX': null, 'maxX': null};
    if (spots.isEmpty) return {'minX': 0, 'maxX': 24};

    final first = spots.first.x.floorToDouble();
    final last = spots.last.x.ceilToDouble();
    return {
      'minX': (first - 1).clamp(0.0, 23.0),
      'maxX': (last + 1).clamp(1.0, 24.0),
    };
  }

  // Renders horizontal grid lines with styling.
  FlGridData _buildGridData(Color bgColor) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: false,
      horizontalInterval: 5,
      getDrawingHorizontalLine: (_) => FlLine(
        color: bgColor.withOpacity(0.3),
        strokeWidth: 1,
      ),
    );
  }

  // Configures bottom and left axis titles.
  FlTitlesData _buildTitlesData(
      BuildContext context, double? minX, double? maxX) {
    final titleStyle = GraphScreenConstants.getCardTitleStyle(context);
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            if (filter == TimeFilter.hourly) {
              final hour = value.toInt();
              if (hour < (minX ?? 0) || hour > (maxX ?? 24)) {
                return const SizedBox.shrink();
              }
              final labelTime = dayStart.add(Duration(hours: hour));
              return SideTitleWidget(
                meta: meta,
                angle: 0,
                child: Text(DateFormat.j().format(labelTime), style: titleStyle),
              );
            } else if (filter == TimeFilter.weekly) {
              final idx = value.toInt().clamp(0, dailyStats!.length - 1);
              final date = dailyStats![idx].date;
              return SideTitleWidget(
                meta: meta,
                angle: 0,
                child: Text(DateFormat.E().format(date), style: titleStyle),
              );
            } else {
              final day = value.toInt();
              final lastDay = dailyStats!.last.date.day;
              if (day % 5 == 1 || day == lastDay) {
                return SideTitleWidget(
                  meta: meta,
                  angle: 0,
                  child: Text(day.toString(), style: titleStyle),
                );
              }
              return const SizedBox.shrink();
            }
          },
        ),
      ),
      leftTitles: AxisTitles(
        axisNameWidget: const RotatedBox(
          quarterTurns: 0,
          child: Text('BPM'),
        ),
        axisNameSize: 16,
        sideTitles: SideTitles(
          showTitles: true,
          interval: 10,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return SideTitleWidget(
              meta: meta,
              angle: 0,
              child: Text(value.toInt().toString(),
                  style: GraphScreenConstants.getCardTitleStyle(context)),
            );
          },
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false, reservedSize: 16),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  // Tooltip logic that changes format based on time filter.
  LineTouchData _buildTouchData(TextStyle valueStyle, DateTime dayStart) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => CHeartTheme.primaryColor.withOpacity(0.8),
        getTooltipItems: (spots) => spots.map((spot) {
          if (filter == TimeFilter.hourly) {
            final time = dayStart.add(Duration(hours: spot.x.toInt()));
            return LineTooltipItem(
              '${DateFormat.Hm().format(time)}\n${spot.y.toStringAsFixed(0)} bpm',
              valueStyle,
            );
          } else if (filter == TimeFilter.monthly) {
            final dayIndex = spot.x.toInt();
            final date = dailyStats![dayIndex - 1].date;
            return LineTooltipItem(
              '${DateFormat.MMMd().format(date)} – ${spot.y.toStringAsFixed(0)} bpm',
              valueStyle,
            );
          } else {
            return LineTooltipItem(
              'Avg ${spot.y.toStringAsFixed(0)} bpm',
              valueStyle,
            );
          }
        }).toList(),
      ),
    );
  }

  // Draws the actual line chart with dot styling.
  LineChartBarData _buildLineBarData(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: CHeartTheme.primaryColor,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 4,
          color: CHeartTheme.accentColor,
          strokeWidth: 0,
        ),
      ),
    );
  }
}
