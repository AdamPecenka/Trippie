import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/presentation/widgets/trip_card.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);
    final activitiesAsync = ref.watch(tripActivitiesProvider(tripId));

    final trip = tripsAsync.whenOrNull(
      data: (trips) => trips.where((t) => t.id == tripId).firstOrNull,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppGradients.backgroundDark
              : AppGradients.background,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    const Icon(Icons.menu),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: trip == null
                    ? const SizedBox.shrink()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDate(trip.startDate)} – ${_formatDate(trip.endDate)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          _StatusBadge(status: trip.status),
                        ],
                      ),
              ),

              // ── Activities ──────────────────────────────────────
              Expanded(
                child: activitiesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (activities) => _ActivitiesList(
                    activities: activities,
                    trip: trip,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}. ${_month(d.month)} ${d.year}';

  String _month(int m) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];
}

// ── Activities list grouped by day ────────────────────────────────
class _ActivitiesList extends StatelessWidget {
  const _ActivitiesList({required this.activities, required this.trip});

  final List<ActivityDto> activities;
  final TripDto? trip;

  Map<String, List<ActivityDto>> get _byDay {
    final map = <String, List<ActivityDto>>{};
    for (final a in activities) {
      final key = a.activityDate ?? 'Unknown';
      map.putIfAbsent(key, () => []).add(a);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Text(
          'No activities yet',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final days = _byDay.keys.toList()..sort();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        24, 0, 24,
        MediaQuery.of(context).padding.bottom + 100,
      ),
      children: [
        Text('Activities:',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...days.map((day) => _DaySection(
              day: day,
              activities: _byDay[day]!,
            )),
      ],
    );
  }
}

// ── Collapsible day section ────────────────────────────────────────
class _DaySection extends StatefulWidget {
  const _DaySection({required this.day, required this.activities});

  final String day;
  final List<ActivityDto> activities;

  @override
  State<_DaySection> createState() => _DaySectionState();
}

class _DaySectionState extends State<_DaySection> {
  bool _expanded = true;

  String get _dayLabel {
    try {
      final d = DateTime.parse(widget.day);
      final weekday = const [
        '', 'Monday', 'Tuesday', 'Wednesday',
        'Thursday', 'Friday', 'Saturday', 'Sunday'
      ][d.weekday];
      return '$weekday ${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.';
    } catch (_) {
      return widget.day;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Text(_dayLabel,
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Icon(_expanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          ...widget.activities.map((a) => _ActivityTile(activity: a)),
          const SizedBox(height: 8),
        ] else
          const Divider(height: 1),
      ],
    );
  }
}

// ── Activity tile ──────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final ActivityDto activity;

  String get _timeRange {
    if (activity.startTime == null) return '';
    final start = activity.startTime!.substring(0, 5);
    if (activity.endTime == null) return start;
    final end = activity.endTime!.substring(0, 5);
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activity.startTime != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              activity.startTime!.substring(0, 5),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(  // ✅ Column, nie children priamo v Padding
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name ?? 'Activity',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_timeRange.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _timeRange,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Status badge (rovnaký ako v trip_card) ─────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TripStatus status;

  Color get _color {
    switch (status) {
      case TripStatus.active:   return AppColors.statusActive;
      case TripStatus.planning: return AppColors.statusPlanning;
      case TripStatus.finished: return AppColors.statusFinished;
    }
  }

  String get _label {
    switch (status) {
      case TripStatus.active:   return 'ACTIVE';
      case TripStatus.planning: return 'PLANNING';
      case TripStatus.finished: return 'FINISHED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}