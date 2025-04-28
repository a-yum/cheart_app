import 'package:flutter/material.dart';

import 'package:cheart/components/bottom_navbar.dart';
import 'package:cheart/components/stat_card.dart';
import 'package:cheart/screens/graph_screen_constants.dart';
import 'package:cheart/themes/cheart_theme.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respiratory Rate'),
        backgroundColor: CHeartTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet History Header
              Text(
                "Rover's History", // TODO: Replace with actual pet name
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: CHeartTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),

              // Stats Section Title
              Text(
                'Average Breaths per Minute',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 12),

              // Stats Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardSize = constraints.maxWidth / 3;

                  return SizedBox(
                    height: cardSize,
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Overall',
                            value: '30',
                            unit: 'BPM',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            title: 'At Rest',
                            value: '25',
                            unit: 'BPM',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            title: 'Sleeping',
                            value: '20',
                            unit: 'BPM',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Time Filter Dropdown
              Row(
                children: [
                  const Text('View: '),
                  DropdownButton<TimeFilter>(
                    value: TimeFilter.daily,
                    items: TimeFilter.values.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // TODO: Implement filter change
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Graph Placeholder
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('Graph Placeholder'),
                ),
              ),
              const SizedBox(height: 24),

              // Email Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement email functionality
                  },
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
      bottomNavigationBar: const BottomNavbar(
        currentIndex: 3,
      ),
    );
  }
}
