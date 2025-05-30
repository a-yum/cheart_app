import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:cheart/components/month_year_picker_dialog.dart';
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

  // ────────────────────────── UI ────────────────────────── //
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
          _buildHeader(),
          _buildAvatarPicker(displayName),
          const SizedBox(height: 16),
          _buildFormFields(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ───────────────────────── Handlers ───────────────────────── //
  Future<void> _pickAndCropImage() async {
    try {
      final newPath = await ImageHandler.pickAndCropImage();
      if (!mounted || newPath == null) return; // user cancelled

      if (_originalImagePath != null && _originalImagePath != newPath) {
        await ImageHandler.deleteImage(_originalImagePath!);
      }

      setState(() => _imagePath = newPath);
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

    final petWithImage = pet.copyWith(petProfileImagePath: _imagePath);

    try {
      final provider = context.read<PetProfileProvider>();
      final savedPet = await provider.savePetProfile(petWithImage);
      widget.onSave(savedPet);
      if (!mounted) return;
      Navigator.pop(context, savedPet);
    } catch (e) {
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context)!,
        CustomSnackBar.error(message: 'Failed to save pet profile: $e'),
      );
    }
  }

  Future<void> _showMonthYearPicker() async {
    final result = await showDialog<(int?, int?)>(
      context: context,
      builder: (_) => MonthYearPickerDialog(
        initialMonth: _controller.selectedMonth,
        initialYear: _controller.selectedYear,
      ),
    );

    if (result != null) {
      final (month, year) = result;
      setState(() {
        _controller.selectedMonth = month;
        _controller.selectedYear = year;
      });
    }
  }

  // ────────────────────── UI Sub-widgets ────────────────────── //
  Widget _buildHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.initialPet == null ? 'Add New Pet' : 'Edit Pet',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );

  Widget _buildAvatarPicker(String displayName) => Center(
        child: InkWell(
          onTap: _pickAndCropImage,
          child: PetProfileAvatar(
            petName: displayName,
            imagePath: _imagePath,
            size: 100.0,
          ),
        ),
      );

  Widget _buildFormFields() => Flexible(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _controller.nameController,
                  label: 'Pet Name*',
                  icon: Icons.pets,
                  validator: (v) => Validators.required(v, 'pet\'s name'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _controller.breedController,
                  label: 'Breed*',
                  icon: Icons.category,
                  validator: (v) => Validators.required(v, 'pet\'s breed'),
                ),
                const SizedBox(height: 16),
                _buildBirthDatePicker(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _controller.vetEmailController,
                  label: 'Vet Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildActionButtons() => Padding(
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
      );

  // Helper for text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
  }) => TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: validator,
        keyboardType: keyboardType,
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
}