import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/components/dialogs/confirm_discard_dialog.dart';

class DangerZoneSection extends StatelessWidget {
  final PetProfileModel pet;
  final VoidCallback onPetDeleted;

  const DangerZoneSection({
    Key? key,
    required this.pet,
    required this.onPetDeleted,
  }) : super(key: key);

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDiscardDialog(
        title: 'Delete Pet Profile?',
        message: 'This action is permanent and cannot be undone.',
        confirmText: 'Delete',
        isDestructive: true,
      ),
    );

    if (confirmed == true) {
      try {
        final provider =
            Provider.of<PetProfileProvider>(context, listen: false);
        await provider.deletePetProfile(pet.id!);
        onPetDeleted();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete pet: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () => _confirmAndDelete(context),
        icon: const Icon(Icons.delete),
        label: const Text('Delete Pet Profile'),
      ),
    );
  }
}
