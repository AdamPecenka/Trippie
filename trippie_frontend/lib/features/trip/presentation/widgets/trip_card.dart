import 'package:flutter/material.dart';
import 'package:trippie_frontend/shared/models/trip_enums.dart';
import 'package:trippie_frontend/features/trip/presentation/widgets/trip_state_badge.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.tripId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.onTap,
  });

  final String tripId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final TripStatus status;
  final VoidCallback onTap;

  String _formatDateRange() {
    final start =
        '${startDate.day}. ${_monthName(startDate.month)} ${startDate.year}';
    final end =
        '${endDate.day}. ${_monthName(endDate.month)} ${endDate.year}';
    return '$start - $end';
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateRange(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              TripStateBadge(status: status),
            ],
          ),
        ),
      ),
    );
  }
}