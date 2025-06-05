import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/components/common/bottom_navbar.dart';
import 'package:cheart/components/common/info_modal.dart';
import 'package:cheart/components/session/post_session_modal.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/providers/respiratory_rate_provider.dart';
import 'package:cheart/themes/cheart_theme.dart';

class RespiratoryRateScreen extends StatelessWidget {
  const RespiratoryRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPet = context.watch<PetProfileProvider>().selectedPetProfile;
    final respiratoryProvider = context.watch<RespiratoryRateProvider>();

    // Setup the callback when the widget builds
    _setupSessionCallback(context, respiratoryProvider, selectedPet);

    return Scaffold(
      backgroundColor: CHeartTheme.secondaryBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;
          final heartSize = isMobile ? constraints.maxWidth * 1.0 : 300;

          return Column(
            children: [
              // === SafeArea ===
              SafeArea(
                top: true,
                bottom: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: CHeartTheme.secondaryBackgroundColor,
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Tracking ${selectedPet?.petName ?? 'your pet'}',
                          style: CHeartTheme.titleText.copyWith(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Timer: ${respiratoryProvider.timeRemaining}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // === Heart Tracker ===
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Reserve 10% margin top and bottom inside this section
                    final maxHeartSize = constraints.biggest.shortestSide * 1.0;

                    return Align(
                      alignment: const Alignment(0, -0.7),
                      child: GestureDetector(
                        onTap: () {
                          if (!respiratoryProvider.isTracking) {
                            respiratoryProvider.startTracking();
                          } else {
                            respiratoryProvider.incrementBreathCount();
                          }
                        },
                        child: SizedBox(
                          width: maxHeartSize,
                          height: maxHeartSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: maxHeartSize,
                                color: CHeartTheme.heartTrackerColor,
                              ),
                              Text(
                                !respiratoryProvider.isTracking
                                    ? 'Tap to begin'
                                    : 'Breaths: ${respiratoryProvider.breathCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // === Bottom 'Container' ===
              LayoutBuilder(
                builder: (context, constraints) {
                  final double totalHeight =
                      MediaQuery.of(context).size.height;
                  final double bottomSectionHeight = totalHeight * 0.15;

                  return SizedBox(
                    height: bottomSectionHeight,
                    child: Column(
                      children: [
                        // === Background ===
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                // === Top Half ===
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: _ActionButton(
                                              icon: Icons.arrow_back,
                                              label: 'Back',
                                              onPressed: () {
                                                respiratoryProvider
                                                    .resetCurrentSession();
                                                Navigator.pushReplacementNamed(
                                                    context, '/pet');
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _ActionButton(
                                              icon: Icons.refresh,
                                              label: 'Reset',
                                              onPressed: () {
                                                respiratoryProvider
                                                    .resetCurrentSession();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // === Bottom Half ===
                                Expanded(
                                  child: Center(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => const InfoModal(),
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            'Learn More',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(Icons.info_outline, size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }

  void _setupSessionCallback(
    BuildContext context,
    RespiratoryRateProvider respiratoryProvider,
    PetProfileModel? selectedPet,
  ) {
    respiratoryProvider.onSessionComplete = () {
      if (selectedPet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pet selected')),
        );
        return;
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => PostSessionModal(
            petName: selectedPet.petName,
            petId: selectedPet.id ?? -1,
            breathsPerMinute: respiratoryProvider.breathsPerMinute,
          ),
        );
      }
    };
  }
}

// === Reusable Action Button Widget ===
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 400 ? 18.0 : 22.0;
    final fontSize = screenWidth < 400 ? 12.0 : 14.0;
    final paddingVertical = screenWidth < 400 ? 10.0 : 14.0;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: CHeartTheme.buttonColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: paddingVertical),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: Icon(icon, size: iconSize, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(fontSize: fontSize),
      ),
      onPressed: onPressed,
    );
  }
}
