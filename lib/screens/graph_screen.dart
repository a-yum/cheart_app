import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:cheart/components/common/bar_graph.dart';
import 'package:cheart/components/common/bottom_navbar.dart';
import 'package:cheart/components/common/line_graph.dart';
import 'package:cheart/components/common/stat_card.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/providers/respiratory_history_provider.dart';
import 'package:cheart/screens/graph_screen_constants.dart';
import 'package:cheart/services/csv_export_service.dart';
import 'package:cheart/themes/cheart_theme.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({Key? key}) : super(key: key);

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {  // toDo: need graphs to update automatically after sessions.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respiratory Rate'),
        backgroundColor: CHeartTheme.primaryColor,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildContent(context)),
          if (_shouldShowOverlay(context)) _buildOverlay(context),
        ],
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
    );
  }

  Widget _buildContent(BuildContext context) {
    final petProv = context.watch<PetProfileProvider>();
    final historyProv = context.watch<RespiratoryHistoryProvider>();
    final chartTitle = _getChartTitle(historyProv);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(petProv),
          const SizedBox(height: 20),
          _buildStatsSection(historyProv),
          const SizedBox(height: 25),
          _buildFilterAndTitleSection(historyProv, chartTitle),
          const SizedBox(height: GraphScreenConstants.cardSpacing),
          _buildChartSection(historyProv),
          const SizedBox(height: 24),
          _buildEmailButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(PetProfileProvider petProv) {
    final name = petProv.selectedPetProfile?.petName ?? '';
    return Text(
      '$name’s History',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: CHeartTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildStatsSection(RespiratoryHistoryProvider historyProv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats section header
        Text(
          'Average Breaths per Minute',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (ctx, constraints) {
            final cardSize = constraints.maxWidth / 3;
            return SizedBox(
              height: cardSize,
              child: Row(
                children: [
                  _buildStatCard('Recent', historyProv.mostRecentBpm?.toStringAsFixed(0)),
                  const SizedBox(width: GraphScreenConstants.cardSpacing),
                  _buildStatCard('Average', historyProv.overallAvgBpm.toStringAsFixed(1)),
                  const SizedBox(width: GraphScreenConstants.cardSpacing),
                  _buildStatCard(
                    'Range',
                    historyProv.minBpm != null && historyProv.maxBpm != null
                        ? '${historyProv.minBpm}-${historyProv.maxBpm}'
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String? value) {
    return Expanded(
      child: StatCard(
        title: title,
        value: value ?? '-',
        unit: 'BPM',
      ),
    );
  }

  Widget _buildFilterAndTitleSection(RespiratoryHistoryProvider historyProv, String chartTitle) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
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
        Text(
          chartTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: CHeartTheme.primaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildChartSection(RespiratoryHistoryProvider historyProv) {
    if (historyProv.selectedFilter == TimeFilter.hourly && historyProv.hourlyPoints.isEmpty) {
      return _buildPlaceholder('No readings yet today');
    }
    if (historyProv.selectedFilter == TimeFilter.weekly) {
      return _wrapChart(
        BarGraph(data: historyProv.dailyStats),
      );
    }
    return _wrapChart(
      LineGraph(
        filter: historyProv.selectedFilter,
        hourlyPoints: historyProv.selectedFilter == TimeFilter.hourly ? historyProv.hourlyPoints : null,
        dailyStats: historyProv.selectedFilter == TimeFilter.hourly ? null : historyProv.dailyStats,
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _wrapChart(Widget chart) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: const Offset(-16, 0),
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: chart,
        ),
      ),
    );
  }

  bool _shouldShowOverlay(BuildContext context) {
    final petProv = context.watch<PetProfileProvider>();
    final historyProv = context.watch<RespiratoryHistoryProvider>();
    return petProv.selectedPetProfile == null || !historyProv.hasSessions;
  }

  Widget _buildOverlay(BuildContext context) {
    final petProv = context.watch<PetProfileProvider>();
    final noProfile = petProv.selectedPetProfile == null;
    return Positioned.fill(
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
  }

  String _getChartTitle(RespiratoryHistoryProvider historyProv) {
    if (historyProv.selectedFilter == TimeFilter.hourly) {
      return DateFormat('EEE, MMM d').format(DateTime.now());
    } else if (historyProv.selectedFilter == TimeFilter.weekly) {
      return 'Last 7 Days';
    }
    return DateFormat.MMMM().format(DateTime.now());
  }

  Widget _buildEmailButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _isExporting ? null : () => _onEmailToVetPressed(context),
        icon: _isExporting
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.email),
        label: const Text('Email to Vet (CSV)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: CHeartTheme.primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _onEmailToVetPressed(BuildContext context) async {
    // 1. Synchronously grab what we need
    final pet = context.read<PetProfileProvider>().selectedPetProfile;
    if (pet == null || pet.vetEmail == null || pet.vetEmail!.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No Vet Email'),
          content: const Text('Please add your vet’s email address in Settings first.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      );
      return;
    }

    // grab CSV service up front
    final csvService = context.read<CsvExportService>();
    final vetEmail = pet.vetEmail!;
    final petName = pet.petName;

    // 2. Enter loading state
    setState(() => _isExporting = true);

    try {
      // CSV export
      final file = await csvService.exportToCsv(pet);
      if (!mounted) return;

      // 3. Send the email
      final email = Email(
        body: 'Attached: respiratory data (CSV) for $petName',
        subject: 'CHeart CSV Export: $petName',
        recipients: [vetEmail],
        attachmentPaths: [file.path],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
