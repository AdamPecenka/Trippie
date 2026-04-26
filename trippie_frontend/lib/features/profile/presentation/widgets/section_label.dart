import 'package:flutter/material.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
        fontSize: 12,
      ),
    );
  }
}