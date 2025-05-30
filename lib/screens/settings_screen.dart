// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/components/bottom_navbar.dart';
import 'package:cheart/themes/cheart_theme.dart';
import 'package:cheart/config/cheart_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _email;

  @override
  void initState() {
    super.initState();
    final pet = context.read<PetProfileProvider>().selectedPetProfile;
    _email = pet?.vetEmail ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: CHeartTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Vet Email field
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(
                  labelText: 'Vet Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please enter an email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(v)) {
                    return 'Invalid email';
                  }
                  return null;
                },
                onSaved: (v) => _email = v!.trim(),
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CHeartTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  try {
                    // Await the updateVetEmail Future
                    await context
                        .read<PetProfileProvider>()
                        .updateVetEmail(_email);

                    // Only show SnackBar if still mounted
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vet email saved')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Save failed: $e')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation bar (preserve existing navbar)
      bottomNavigationBar: const BottomNavbar(currentIndex: 4),
    );
  }
}
