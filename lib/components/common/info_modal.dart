import 'package:flutter/material.dart';

import 'package:cheart/themes/cheart_theme.dart';

class InfoModal extends StatelessWidget {
  const InfoModal({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // === Title ===
            Text(
              'Getting Started',
              style: CHeartTheme.titleText.copyWith(fontSize: isSmallScreen ? 16 : 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            // === Content ===
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === Section 1: Pet should be at rest ===
                    Text(
                      "Pet should be at rest or sleeping",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Ensure your pet has been resting or sleeping for at least 15–30 minutes before tracking. "
                      "Avoid measuring after recent activity, play, or excitement.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),

                    // === Section 2: How the tracker works ===
                    Text(
                      "How the tracker works",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Once you tap the heart to begin, the tracker runs for 30 seconds. Tap the heart every time your dog completes "
                      "a full breath (inhale + exhale). At the end of the session, the breathing rate per minute will be calculated.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),

                    // === Section 3: What counts as a breath ===
                    Text(
                      "One tap = One breath",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Each tap should represent a full respiratory cycle: one inhale and one exhale. "
                      "Your pet's abdomen will expand on inhale and contract on exhale.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),

                    // === Section 4: Abnormal breathing ===
                    Text(
                      "Abnormal breathing",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Consult your veterinarian for what is considered a normal breathing rate for your pet."
                      "If your pet is experiencing any respiratory distress, please seek veterinary care immediately.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // === Close Button ===
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CHeartTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
