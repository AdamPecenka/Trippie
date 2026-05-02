import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/flight_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';

class TripHubScreen extends ConsumerWidget {
  const TripHubScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);
    final trip = tripsAsync.whenOrNull(
      data: (trips) => trips.where((t) => t.id == tripId).firstOrNull,
    );

    final activitiesAsync = ref.watch(tripActivitiesProvider(tripId));
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final accommodationAsync = ref.watch(tripAccommodationProvider(tripId));
    final flightsAsync = ref.watch(tripFlightsProvider(tripId));

    final activityCount = activitiesAsync.whenOrNull(data: (l) => l.length) ?? 0;
    final memberCount = membersAsync.whenOrNull(data: (l) => l.length) ?? 0;
    final hasAccommodation = accommodationAsync.whenOrNull(data: (a) => a != null) ?? false;
    final mapPins = activitiesAsync.whenOrNull(
          data: (l) => l.where((a) => a.place != null).length,
        ) ?? 0;
    final flights = flightsAsync.whenOrNull(data: (l) => l) ?? [];
    final hasOutbound = flights.any((f) => f.isOutbound);
    final hasReturn = flights.any((f) => !f.isOutbound);
    final hasFlights = flights.isNotEmpty;

    // completion score (out of 10)
    int score = 0;
    if (activityCount > 0) score += 3;
    if (activityCount >= 3) score += 1;
    if (hasAccommodation) score += 2;
    if (memberCount > 1) score += 2;
    if (mapPins > 0) score += 1;
    if (trip?.startDate != null) score += 1;
    final percent = (score / 10.0).clamp(0.0, 1.0);

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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: trip == null
                    ? const SizedBox.shrink()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(trip.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateRange(trip),
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

              // ── Progress bar ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Trip is ${(percent * 100).round()}% ready ${percent >= 0.7 ? '🎉' : ''}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          '$score/10',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: const Color(0xFF7B68EE),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: percent),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (_, value, __) => LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor: Theme.of(context).cardColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percent >= 0.7
                                ? Colors.green.shade400
                                : const Color(0xFF7B68EE),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Module cards ─────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    24, 0, 24,
                    MediaQuery.of(context).padding.bottom + 100,
                  ),
                  children: [
                    _ModuleCard(
                      icon: '🗓',
                      title: 'Activities',
                      subtitle: activityCount > 0
                          ? '$activityCount ${activityCount == 1 ? 'activity' : 'activities'} planned'
                          : '+ Add when ready',
                      subtitleColor: activityCount > 0 ? null : const Color(0xFF7B68EE),
                      done: activityCount > 0,
                      onTap: () => context.pop(), // back to activities screen
                    ),
                    const SizedBox(height: 12),
                    _ModuleCard(
                      icon: '✈️',
                      title: 'Flights',
                      subtitle: hasFlights
                          ? '${hasOutbound ? 'Outbound' : ''}${hasOutbound && hasReturn ? ' + ' : ''}${hasReturn ? 'Return' : ''} added'
                          : '+ Add when ready',
                      subtitleColor: hasFlights ? null : const Color(0xFF7B68EE),
                      done: hasOutbound && hasReturn,
                      onTap: () => context.push('/home/trip/$tripId/flights'),
                    ),
                    const SizedBox(height: 12),
                    _ModuleCard(
                      icon: '🏨',
                      title: 'Accommodation',
                      subtitle: hasAccommodation
                          ? 'Accommodation added'
                          : '+ Still looking...',
                      subtitleColor: hasAccommodation ? null : AppColors.textSecondary,
                      done: hasAccommodation,
                      onTap: () => context.push('/home/trip/$tripId/accommodation'),
                    ),
                    const SizedBox(height: 12),
                    _ModuleCard(
                      icon: '👥',
                      title: 'Members',
                      subtitle: memberCount > 0
                          ? '$memberCount ${memberCount == 1 ? 'person' : 'people'} joined'
                          : '+ Invite friends',
                      subtitleColor: memberCount > 1 ? null : const Color(0xFF7B68EE),
                      done: memberCount > 1,
                      onTap: () => context.push('/home/trip/$tripId/members'),
                    ),
                    const SizedBox(height: 12),
                    _ModuleCard(
                      icon: '🗺',
                      title: 'Map',
                      subtitle: mapPins > 0
                          ? '$mapPins ${mapPins == 1 ? 'pin' : 'pins'} on map'
                          : '+ Add activities to see map',
                      subtitleColor: mapPins > 0 ? null : AppColors.textSecondary,
                      done: mapPins > 0,
                      onTap: () => context.push('/map'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateRange(TripDto trip) {
    final s = trip.startDate;
    final e = trip.endDate;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${s.day}. ${months[s.month]} – ${e.day}. ${months[e.month]} ${e.year}';
  }
}

// ── Module card ────────────────────────────────────────────────────
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
    this.subtitleColor,
  });

  final String icon;
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // done indicator
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: done
                      ? Colors.green.shade50
                      : Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                        ? Colors.green.shade300
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: done
                      ? Icon(Icons.check,
                          size: 18, color: Colors.green.shade500)
                      : Text(icon,
                          style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: subtitleColor ?? AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status badge ───────────────────────────────────────────────────
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}