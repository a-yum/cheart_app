import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:cheart/components/bar_graph.dart';
import 'package:cheart/components/bottom_navbar.dart';
import 'package:cheart/components/line_graph.dart';
import 'package:cheart/components/stat_card.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/providers/respiratory_history_provider.dart';
import 'package:cheart/screens/graph_screen_constants.dart';
import 'package:cheart/themes/cheart_theme.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petProv     = context.watch<PetProfileProvider>();
    final historyProv = context.watch<RespiratoryHistoryProvider>();

    // Determine overlay conditions
    final noProfile = petProv.selectedPetProfile == null;
    final noDataAll = !historyProv.hasSessions;
    final showFullOverlay = noProfile || noDataAll;

    // Overlay to prompt user to select pet or record session
    final fullOverlay = Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.8),
        child: Center(
          child: Text(
            noProfile
                ? 'Select a pet to view stats.'
                : 'Looks like there’s no data yet. Record a session to get started.',
            style: const TextStyle(color: Colors.black, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // Determine chart title based on selected filter
    String chartTitle;
    if (historyProv.selectedFilter == TimeFilter.hourly) {
      chartTitle = DateFormat('EEE, MMM d').format(DateTime.now());
    } else if (historyProv.selectedFilter == TimeFilter.weekly) {
      chartTitle = 'Last 7 Days';
    } else {
      chartTitle = DateFormat.MMMM().format(DateTime.now());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Respiratory Rate'),
        backgroundColor: CHeartTheme.primaryColor,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet profile header
                  Text(
                    '${petProv.selectedPetProfile?.petName}\'s History',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: CHeartTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Stats section header
                  Text(
                    'Average Breaths per Minute',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Stats cards: Recent / Avg / Range
                  LayoutBuilder(
                    builder: (ctx, constraints) {
                      final cardSize = constraints.maxWidth / 3;
                      return SizedBox(
                        height: cardSize,
                        child: Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Recent',
                                value: historyProv.mostRecentBpm != null
                                    ? historyProv.mostRecentBpm!.toStringAsFixed(0)
                                    : '-',
                                unit: 'BPM',
                              ),
                            ),
                            const SizedBox(width: GraphScreenConstants.cardSpacing),
                            Expanded(
                              child: StatCard(
                                title: 'Average',
                                value: historyProv.overallAvgBpm.toStringAsFixed(1),
                                unit: 'BPM',
                              ),
                            ),
                            const SizedBox(width: GraphScreenConstants.cardSpacing),
                            Expanded(
                              child: StatCard(
                                title: 'Range',
                                value: (historyProv.minBpm != null && historyProv.maxBpm != null)
                                    ? '${historyProv.minBpm}-${historyProv.maxBpm}'
                                    : '-',
                                unit: 'BPM',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),

                  // Time filter selector + chart title
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      // Filter dropdown
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('View: '),
                          DropdownButton<TimeFilter>(
                            value: historyProv.selectedFilter,
                            items: TimeFilter.values.map((filter) {
                              return DropdownMenuItem(
                                value: filter,
                                child: Text(filter.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (f) {
                              if (f != null) historyProv.setFilter(f);
                            },
                          ),
                        ],
                      ),

                      // Dynamic chart title
                      Text(
                        chartTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: CHeartTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: GraphScreenConstants.cardSpacing),

                  // Chart display based on filter and data availability
                  if (historyProv.selectedFilter == TimeFilter.hourly &&
                      historyProv.hourlyPoints.isEmpty)
                    // Placeholder for no hourly data
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'No readings yet today',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ),
                    )
                  else if (historyProv.selectedFilter == TimeFilter.weekly)
                    // Weekly bar chart
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: const Offset(-16, 0),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: BarGraph(data: historyProv.dailyStats),
                        ),
                      ),
                    )
                  else
                    // Monthly or hourly line chart with data
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: const Offset(-16, 0),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: LineGraph(
                            filter: historyProv.selectedFilter,
                            hourlyPoints: historyProv.selectedFilter == TimeFilter.hourly
                                ? historyProv.hourlyPoints
                                : null,
                            dailyStats: historyProv.selectedFilter == TimeFilter.hourly
                                ? null
                                : historyProv.dailyStats,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Email button
                  Center( // toDo: implment email functionality
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.email),
                      label: const Text('Email to Vet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CHeartTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Overlay to block UI if no profile or data
          if (showFullOverlay) fullOverlay,
        ],
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
    );
  }
}
