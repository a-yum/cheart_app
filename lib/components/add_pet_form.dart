import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:cheart/components/pet_profile_avatar.dart';
import 'package:cheart/controllers/pet_form_controller.dart';
import 'package:cheart/exceptions/image_handler_exception.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/utils/date_utils.dart';
import 'package:cheart/utils/image_handler.dart';
import 'package:cheart/utils/validators.dart';

class AddPetForm extends StatefulWidget {
  final Function(PetProfileModel) onSave;
  final PetProfileModel? initialPet;

  const AddPetForm({
    Key? key,
    required this.onSave,
    this.initialPet,
  }) : super(key: key);

  @override
  State<AddPetForm> createState() => _AddPetFormState();
}

class _AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();
  late final PetFormController _controller;
  String? _imagePath;
  String? _originalImagePath;

  @override
  void initState() {
    super.initState();
    _controller = PetFormController(initialPet: widget.initialPet);
    _imagePath = widget.initialPet?.petProfileImagePath;
    _originalImagePath = _imagePath;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final dialogWidth = maxWidth > 600 ? maxWidth * 0.6 : maxWidth * 0.9;

    final displayName = _controller.nameController.text.isNotEmpty
        ? _controller.nameController.text
        : widget.initialPet?.petName ?? '';

    return Container(
      width: dialogWidth,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: 600,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.initialPet == null ? 'Add New Pet' : 'Edit Pet',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          // Avatar picker
          Center(
            child: InkWell(
              onTap: _pickAndCropImage,
              child: PetProfileAvatar(
                petName: displayName,
                imagePath: _imagePath,
                size: 100.0,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Form fields
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet Name Input
                    TextFormField(
                      controller: _controller.nameController,
                      decoration: const InputDecoration(
                        labelText: 'Pet Name*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (value) =>
                          Validators.required(value, 'pet\'s name'),
                    ),
                    const SizedBox(height: 16),

                    // Breed Input
                    TextFormField(
                      controller: _controller.breedController,
                      decoration: const InputDecoration(
                        labelText: 'Breed*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: (value) =>
                          Validators.required(value, 'pet\'s breed'),
                    ),
                    const SizedBox(height: 16),

                    // Birth Date Picker
                    InkWell(
                      onTap: () => _showMonthYearPicker(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Birth Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _controller.selectedMonth == null ||
                                      _controller.selectedYear == null
                                  ? 'Select Date'
                                  : formatMonthYear(
                                      _controller.selectedMonth,
                                      _controller.selectedYear),
                              style: TextStyle(
                                color: _controller.selectedMonth == null ||
                                        _controller.selectedYear == null
                                    ? Colors.grey.shade600
                                    : Colors.black,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Vet Email Input
                    TextFormField(
                      controller: _controller.vetEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Vet Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleSave,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndCropImage() async {
    try {
      final newPath = await ImageHandler.pickAndCropImage();
      if (!mounted || newPath == null) return; // user cancelled

      if (_originalImagePath != null && _originalImagePath != newPath) {
        await ImageHandler.deleteImage(_originalImagePath!);
      }

      setState(() {
        _imagePath = newPath;
      });
    } on ImageHandlerException catch (e) {
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context)!,
        CustomSnackBar.error(message: e.message),
      );
    }
  }

  Future<void> _handleSave() async {
    final pet = _controller.validateAndCreate(_formKey);
    if (pet == null) return;

    final petWithImage = pet.copyWith(
      petProfileImagePath: _imagePath,
    );

    try {
      final provider =
          Provider.of<PetProfileProvider>(context, listen: false);
      final savedPet = await provider.savePetProfile(petWithImage);

      if (!mounted) return;
      Navigator.pop(context, savedPet);
    } catch (e) {
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context)!,
        CustomSnackBar.error(message: "Failed to save pet profile: $e"),
      );
    }
  }

  void _showMonthYearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Birth Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month dropdown
            DropdownButtonFormField<int>(
              value: _controller.selectedMonth,
              decoration: const InputDecoration(
                labelText: 'Month',
                border: OutlineInputBorder(),
              ),
              items: List.generate(12, (idx) {
                final month = idx + 1;
                return DropdownMenuItem(
                  value: month,
                  child: Text(
                    DateFormat('MMMM').format(
                      DateTime(DateTime.now().year, month),
                    ),
                  ),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _controller.selectedMonth = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Year dropdown
            DropdownButtonFormField<int>(
              value: _controller.selectedYear,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
              items: List.generate(30, (idx) {
                final year = DateTime.now().year - idx;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _controller.selectedYear = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
