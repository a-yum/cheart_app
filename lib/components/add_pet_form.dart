import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cheart/factories/pet_profile_factory.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/utils/validators.dart';
import 'package:cheart/utils/date_utils.dart';

class AddPetForm extends StatefulWidget {
  final Function(PetProfileModel) onSave;

  const AddPetForm({super.key, required this.onSave});

  @override
  State<AddPetForm> createState() => _AddPetFormState();
}

class _AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _vetEmailController = TextEditingController();
  int? _selectedMonth;
  int? _selectedYear;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _vetEmailController.dispose();
    super.dispose();
  }

  void _showMonthYearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Birth Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month Dropdown
              DropdownButtonFormField<int>(
                value: _selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(12, (index) {
                  final month = index + 1;
                  return DropdownMenuItem(
                      value: month,
                      child: Text(DateFormat('MMMM')
                          .format(DateTime(2024, month))));
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Year Dropdown
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(30, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value;
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final newPet = PetProfileFactory.create(
        petName: _nameController.text,
        petBreed: _breedController.text,
        birthMonth: _selectedMonth,
        birthYear: _selectedYear,
        vetEmail: _vetEmailController.text.isEmpty
            ? null
            : _vetEmailController.text,
      );
      widget.onSave(newPet);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ToDo: Test Screen Sizes
    return Container(
      width: MediaQuery.of(context).size.width > 600
          ? MediaQuery.of(context).size.width * 0.6
          : MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: 600,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title section with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Pet',
                style: TextStyle(
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
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet Name Input
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Pet Name*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (value) => Validators.required(value, 'pet\'s name'),
                    ),
                    const SizedBox(height: 16),
                    // Breed Input
                    TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: 'Breed*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: (value) => Validators.required(value, 'pet\'s breed'),
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
                              _selectedMonth == null || _selectedYear == null
                                  ? 'Select Date'
                                  : formatMonthYear(_selectedMonth, _selectedYear),
                              style: TextStyle(
                                color: _selectedMonth == null || _selectedYear == null
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
                      controller: _vetEmailController,
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
}