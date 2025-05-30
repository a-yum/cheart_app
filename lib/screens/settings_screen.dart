import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cheart/components/bottom_navbar.dart';
import 'package:cheart/components/confirm_discard_dialog.dart';
import 'package:cheart/components/editable_pet_settings_form.dart';
import 'package:cheart/components/danger_zone_section.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/themes/cheart_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hasUnsavedChanges = false;

  void _handleChangesMade() => setState(() => _hasUnsavedChanges = true);
  void _handleSaveComplete() => setState(() => _hasUnsavedChanges = false);


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetProfileProvider>();
    final selectedPet = provider.selectedPetProfile;
    debugPrint('⚙️ selectedPetProfile = $selectedPet');

    // Early return fallback
    if (selectedPet == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: CHeartTheme.primaryColor,
        ),
        body: const Center(child: Text('No pet profile selected.')),
        bottomNavigationBar: const BottomNavbar(currentIndex: 4),
      );
    }

    return PopScope(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: CHeartTheme.primaryColor,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Editable form
                Expanded(
                  child: EditablePetSettingsForm(
                    pet: selectedPet,
                    onChangeMade: _handleChangesMade,
                    onSaved: _handleSaveComplete,
                  ),
                ),
                const SizedBox(height: 24),
                // Delete button
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DangerZoneSection(
                    pet: selectedPet,
                    onPetDeleted: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavbar(currentIndex: 4),
      ),
    );
  }
}
