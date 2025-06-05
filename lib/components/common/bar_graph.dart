import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:cheart/models/graph_models.dart';
import 'package:cheart/screens/graph_screen_constants.dart';
import 'package:cheart/themes/cheart_theme.dart';

class BarGraph extends StatelessWidget {
  final List<DailyStat> data;
  final double maxY;

  const BarGraph({
    super.key,
    required this.data,
    this.maxY = 60,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.onBackground;
    final titleStyle = GraphScreenConstants.getCardTitleStyle(context);
    final valueStyle = GraphScreenConstants.getCardValueStyle(context);

    final avgValue = data.isNotEmpty
        ? data.map((d) => d.avgBpm).reduce((a, b) => a + b) / data.length
        : 0.0;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (_) => FlLine(
              color: bgColor.withOpacity(0.3),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          titlesData: _buildTitlesData(context, data),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: avgValue,
                color: CHeartTheme.primaryColor.withOpacity(0.7),
                strokeWidth: 2,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 8),
                  style: titleStyle,
                  labelResolver: (_) => 'Avg ${avgValue.toStringAsFixed(1)}',
                ),
              ),
            ],
          ),
          barTouchData: _buildBarTouchData(data, valueStyle),
          barGroups: _buildBarGroups(data),
        ),
      ),
    );
  }

  // Builds the X and Y axis titles and labels.
  FlTitlesData _buildTitlesData(BuildContext context, List<DailyStat> data) {
    final titleStyle = GraphScreenConstants.getCardTitleStyle(context);

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 36,
          getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= data.length) {
              return const SizedBox.shrink();
            }
            final weekday = data[idx].date;
            return SideTitleWidget(
              meta: meta,
              angle: 0,
              child: Text(
                DateFormat.E().format(weekday),
                style: titleStyle,
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        axisNameWidget: RotatedBox(
          quarterTurns: 0,
          child: Text(
            'BPM',
            style: titleStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        axisNameSize: 24,
        sideTitles: SideTitles(
          showTitles: true,
          interval: 10,
          reservedSize: 48,
          getTitlesWidget: (value, meta) {
            return SideTitleWidget(
              meta: meta,
              angle: 0,
              child: Text(
                value.toInt().toString(),
                style: titleStyle,
              ),
            );
          },
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  // Creates the tooltip behavior when a bar is tapped.
  BarTouchData _buildBarTouchData(List<DailyStat> data, TextStyle valueStyle) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => CHeartTheme.primaryColor.withOpacity(0.8),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final stat = data[groupIndex];
          return BarTooltipItem(
            'Avg ${stat.avgBpm.toStringAsFixed(0)} BPM\n'
            'Range: ${stat.minBpm}-${stat.maxBpm}',
            valueStyle,
          );
        },
      ),
    );
  }

  // Converts [DailyStat] data into chart bar groups.
  List<BarChartGroupData> _buildBarGroups(List<DailyStat> data) {
    return data.asMap().entries.map((entry) {
      final idx = entry.key;
      final stat = entry.value;
      return BarChartGroupData(
        x: idx,
        barRods: [
          BarChartRodData(
            toY: stat.avgBpm,
            width: 16, // toDo: make this dynamic
            color: CHeartTheme.primaryColor,
          ),
        ],
      );
    }).toList();
  }
}
