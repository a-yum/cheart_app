import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:cheart/components/pet_profile_avatar.dart';
import 'package:cheart/components/month_year_picker_dialog.dart';
import 'package:cheart/controllers/pet_form_controller.dart';
import 'package:cheart/exceptions/image_handler_exception.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/themes/cheart_theme.dart';
import 'package:cheart/utils/date_utils.dart';
import 'package:cheart/utils/image_handler.dart';
import 'package:cheart/utils/validators.dart';

class EditablePetSettingsForm extends StatefulWidget {
  final PetProfileModel pet;
  final VoidCallback onChangeMade;
  final VoidCallback onSaved;

  const EditablePetSettingsForm({
    Key? key,
    required this.pet,
    required this.onChangeMade,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<EditablePetSettingsForm> createState() => _EditablePetSettingsFormState();
}

class _EditablePetSettingsFormState extends State<EditablePetSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final PetFormController _controller;
  String? _imagePath;
  String? _originalImagePath;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = PetFormController(initialPet: widget.pet);
    _imagePath = widget.pet.petProfileImagePath;
    _originalImagePath = _imagePath;

    // Track text changes
    _controller.nameController.addListener(_onChangeMade);
    _controller.breedController.addListener(_onChangeMade);
    _controller.vetEmailController.addListener(_onChangeMade);
  }

  @override
  void dispose() {
    _controller.nameController.removeListener(_onChangeMade);
    _controller.breedController.removeListener(_onChangeMade);
    _controller.vetEmailController.removeListener(_onChangeMade);
    _controller.dispose();
    super.dispose();
  }

  // ────────────────────────── UI ────────────────────────── //
  @override
  Widget build(BuildContext context) {
    final displayName = _controller.nameController.text.isNotEmpty
        ? _controller.nameController.text
        : widget.pet.petName;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAvatarSection(displayName),
            const SizedBox(height: 16),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildBreedField(),
            const SizedBox(height: 16),
            _buildBirthDatePicker(),
            const SizedBox(height: 16),
            _buildVetEmailField(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Handlers ───────────────────────── //
  void _onChangeMade() {
    if (!_hasChanges) {
      _hasChanges = true;
      widget.onChangeMade();
    }
  }

  Future<void> _pickAndCropImage() async {
    try {
      final newPath = await ImageHandler.pickAndCropImage();
      if (!mounted || newPath == null) return;

      if (_originalImagePath != null && _originalImagePath != newPath) {
        await ImageHandler.deleteImage(_originalImagePath!);
      }

      setState(() {
        _imagePath = newPath;
        _onChangeMade();
      });
    } on ImageHandlerException catch (e) {
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context)!,
        CustomSnackBar.error(message: e.message),
      );
    }
  }

  Future<void> _showMonthYearPicker() async {
    final result = await showDialog<Map<String, int>?>(
      context: context,
      builder: (_) => const MonthYearPickerDialog(),
    );

    if (result != null) {
      setState(() {
        _controller.selectedMonth = result['month'];
        _controller.selectedYear = result['year'];
        _onChangeMade();
      });
    }
  }

  Future<void> _handleSave() async {
    final updated = _controller.validateAndCreate(_formKey);
    if (updated == null) return;

    final petWithImage = updated.copyWith(
      id: widget.pet.id,
      petProfileImagePath: _imagePath,
    );

    try {
      final provider = context.read<PetProfileProvider>();
      await provider.updatePetProfile(petWithImage);
      widget.onSaved();
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context)!,
        const CustomSnackBar.success(message: 'Pet profile updated'),
      );
    } catch (e) {
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context)!,
        CustomSnackBar.error(message: 'Failed to update pet: $e'),
      );
    }
  }

  // ────────────────────── UI Sub‑widgets ────────────────────── //
  Widget _buildAvatarSection(String displayName) => Center(
        child: InkWell(
          onTap: _pickAndCropImage,
          child: PetProfileAvatar(
            petName: displayName,
            imagePath: _imagePath,
            isEditable: true,
            size: 100,
          ),
        ),
      );

  Widget _buildNameField() => TextFormField(
        controller: _controller.nameController,
        decoration: const InputDecoration(
          labelText: 'Pet Name*',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.pets),
        ),
        validator: (v) => Validators.required(v, 'pet\'s name'),
      );

  Widget _buildBreedField() => TextFormField(
        controller: _controller.breedController,
        decoration: const InputDecoration(
          labelText: 'Breed*',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.category),
        ),
        validator: (v) => Validators.required(v, 'pet\'s breed'),
      );

  Widget _buildBirthDatePicker() => InkWell(
        onTap: _showMonthYearPicker,
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
                _controller.selectedMonth == null || _controller.selectedYear == null
                    ? 'Select Date'
                    : formatMonthYear(_controller.selectedMonth, _controller.selectedYear),
                style: TextStyle(
                  color: _controller.selectedMonth == null || _controller.selectedYear == null
                      ? Colors.grey.shade600
                      : Colors.black,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      );

  Widget _buildVetEmailField() => TextFormField(
        controller: _controller.vetEmailController,
        decoration: const InputDecoration(
          labelText: 'Vet Email',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.email),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: Validators.email,
      );

  Widget _buildSaveButton() => ElevatedButton(
        onPressed: _hasChanges ? _handleSave : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: CHeartTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: const Text('Save Changes'),
      );
}
