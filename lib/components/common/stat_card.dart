import 'package:flutter/material.dart';
import 'package:cheart/screens/graph_screen_constants.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color? unitColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.unitColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = constraints.maxWidth;
        final padding = GraphScreenConstants.getResponsivePadding(cardSize);

        return Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                // 1/3: Title
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // 2/3: Value
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // 3/3: Unit
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      unit,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: unitColor ?? Colors.grey[600],
                            fontSize: 12,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
