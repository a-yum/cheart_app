import 'dart:io';

import 'package:flutter/material.dart';

// A circular avatar that displays a pet's image if available,
// otherwise falls back to showing a pet's initials.
// Includes accessibility labels and customizable styling.
class PetProfileAvatar extends StatelessWidget {
  final String petName;
  final String? imagePath;
  final double size; // diameter of the circle
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const PetProfileAvatar({
    Key? key,
    required this.petName,
    this.imagePath,
    this.size = 80.0,
    this.backgroundColor,
    this.textStyle,
  }) : super(key: key);

  // Extract up to two initials from the pet's name
  String _getInitials() {
    final name = petName.trim();
    if (name.isEmpty) return '';

    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';

    // take first letter of first part
    var initials = parts[0][0].toUpperCase();

    // if there's a second word, take its first letter too
    if (parts.length > 1 && parts[1].isNotEmpty) {
      initials += parts[1][0].toUpperCase();
    }

    return initials;
  }

  // Build the fallback UI showing initials
  Widget _buildFallback(BuildContext context) {
    final initials = _getInitials();
    final bgColor = backgroundColor ??
        Theme.of(context).colorScheme.primary.withOpacity(0.1);
    final style = textStyle ??
        Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provide an accessibility label for screen readers
    final semanticsLabel = imagePath != null && petName.trim().isNotEmpty
        ? 'Profile image for $petName'
        : 'No profile image${petName.trim().isNotEmpty ? ', initials ${_getInitials()}' : ''}';

    return Semantics(
      label: semanticsLabel,
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: imagePath != null
              ? Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                  // If loading fails, show initials fallback
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallback(context),
                )
              : _buildFallback(context),
        ),
      ),
    );
  }
}
