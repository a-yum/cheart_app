import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthYearPickerDialog extends StatefulWidget {
  final int? initialMonth;
  final int? initialYear;

  const MonthYearPickerDialog({
    Key? key,
    this.initialMonth,
    this.initialYear,
  }) : super(key: key);

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  int? _selectedMonth;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _selectedYear = widget.initialYear;
  }

  // ────────────────────────── UI ────────────────────────── //
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Birth Date'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthDropdown(),
          const SizedBox(height: 16),
          _buildYearDropdown(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, (_selectedMonth, _selectedYear)),
          child: const Text('OK'),
        ),
      ],
    );
  }

  // ────────────────────── Sub‑widgets ────────────────────── //
  Widget _buildMonthDropdown() => DropdownButtonFormField<int>(
        value: _selectedMonth,
        decoration: const InputDecoration(
          labelText: 'Month',
          border: OutlineInputBorder(),
        ),
        items: List.generate(12, (i) {
          final month = i + 1;
          return DropdownMenuItem(
            value: month,
            child: Text(DateFormat('MMMM').format(DateTime(0, month))),
          );
        }),
        onChanged: (val) => setState(() => _selectedMonth = val),
      );

  Widget _buildYearDropdown() => DropdownButtonFormField<int>(
        value: _selectedYear,
        decoration: const InputDecoration(
          labelText: 'Year',
          border: OutlineInputBorder(),
        ),
        items: List.generate(30, (i) {
          final year = DateTime.now().year - i;
          return DropdownMenuItem(value: year, child: Text('$year'));
        }),
        onChanged: (val) => setState(() => _selectedYear = val),
      );
}
