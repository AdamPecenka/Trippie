import 'package:flutter/material.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/shared/models/trip_enums.dart';

class TripStateBadge extends StatelessWidget {
  const TripStateBadge({super.key, required this.status});

  final TripStatus status;

  Color _backgroundColor() {
    switch (status) {
      case TripStatus.planning:
        return AppColors.statusPlanning;
      case TripStatus.active:
        return AppColors.statusActive;
      case TripStatus.finished:
        return AppColors.statusFinished;
    }
  }

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}