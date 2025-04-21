import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/providers/respiratory_rate_provider.dart';
import 'package:cheart/utils/respiratory_constants.dart';

class PostSessionModal extends StatefulWidget {
  final void Function(String status)? onSave;
  final String petName;
  final int petId;
  final int breathsPerMinute;

  const PostSessionModal({
    super.key,
    required this.petName,
    required this.petId,
    required this.breathsPerMinute,
    this.onSave,
  });

  @override
  State<PostSessionModal> createState() => _PostSessionModalState();
}

class _PostSessionModalState extends State<PostSessionModal> {
  PetState? _selectedStatus;

  Future<void> _handleSave() async {
    if (_selectedStatus == null) return;

    try {
      final success = await context.read<RespiratoryRateProvider>()
        .saveSession(
          petId: widget.petId,
          petState: _selectedStatus!,
        );
      
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session saved successfully'),
            backgroundColor: Colors.green, // toDo: color
          ),
        );
        Navigator.pop(context);
      } else { // toDo: handle more better
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save session'),
            backgroundColor: Colors.red, // toDo: color
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving session: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBpmHigh = widget.breathsPerMinute >= RespiratoryConstants.highBpmThreshold;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // === Header ===
            Text(
              "${widget.petName}s Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // === Banner or nah ===
            if (isBpmHigh)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Breathing Rate is ${widget.breathsPerMinute} BPM!",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // === Message ===
                    Text(
                      RespiratoryConstants.highBpmWarningMessage(widget.petName),
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Text(
                    "Breathing Rate: ${widget.breathsPerMinute} BPM",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // === Status Selector ===
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.petName}’s status:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                RadioListTile<PetState>(
                  title: const Text(
                    'Sleeping',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: PetState.sleeping,
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
                RadioListTile<PetState>(
                  title: const Text(
                    'At Rest',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: PetState.resting,
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // === Buttons ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _selectedStatus == null ? null : _handleSave,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
