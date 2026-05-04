// lib/features/trip/presentation/trip_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/flight_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';
import 'package:trippie_frontend/features/trip/presentation/add_accommodation_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/widgets/trip_state_badge.dart';

class TripHubScreen extends ConsumerWidget {
  const TripHubScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripsProvider).whenOrNull(
          data: (trips) => trips.where((t) => t.id == tripId).firstOrNull,
        );

    // Real data providers — these automatically update when data changes
    final flightsAsync = ref.watch(tripFlightsProvider(tripId));
    final accommodationAsync = ref.watch(tripAccommodationProvider(tripId));
    final membersAsync = ref.watch(tripMembersProvider(tripId));

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
            children: [
              // ── Header (same style as TripDetailScreen) ───────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    if (trip != null) TripStateBadge(status: trip.status),
                  ],
                ),
              ),

              // Trip name + dates
              if (trip != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip.name,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${_fmt(trip.startDate)} – ${_fmt(trip.endDate)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Module cards ──────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    20, 4, 20,
                    MediaQuery.of(context).padding.bottom + 24,
                  ),
                  children: [
                    _SectionLabel(label: 'BOOKINGS'),
                    const SizedBox(height: 10),

                    // Flights card — driven by tripFlightsProvider
                    flightsAsync.when(
                      loading: () => _ModuleCard(
                        emoji: '✈️',
                        title: 'Flights',
                        subtitle: 'Loading...',
                        isDone: false,
                        isPartial: false,
                        onTap: () => context.push('/home/trip/$tripId/flights'),
                      ),
                      error: (_, __) => _ModuleCard(
                        emoji: '✈️',
                        title: 'Flights',
                        subtitle: 'Add your flights',
                        isDone: false,
                        isPartial: false,
                        onTap: () => context.push('/home/trip/$tripId/flights'),
                      ),
                      data: (flights) {
                        final hasOut = flights.any(
                            (f) => f.travelDirection.toUpperCase() == 'OUTBOUND');
                        final hasRet = flights.any(
                            (f) => f.travelDirection.toUpperCase() == 'RETURN');
                        final done = hasOut && hasRet;
                        final partial = hasOut || hasRet;
                        return _ModuleCard(
                          emoji: '✈️',
                          title: 'Flights',
                          subtitle: done
                              ? 'Both flights confirmed'
                              : partial
                                  ? hasOut
                                      ? 'Outbound ✓  ·  Return missing'
                                      : 'Return ✓  ·  Outbound missing'
                                  : 'Add your flights',
                          isDone: done,
                          isPartial: partial && !done,
                          onTap: () =>
                              context.push('/home/trip/$tripId/flights'),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // Accommodation card — driven by tripAccommodationProvider
                    accommodationAsync.when(
                      loading: () => _ModuleCard(
                        emoji: '🏨',
                        title: 'Accommodation',
                        subtitle: 'Loading...',
                        isDone: false,
                        isPartial: false,
                        onTap: () => _openAccommodation(context, ref, null),
                      ),
                      error: (_, __) => _ModuleCard(
                        emoji: '🏨',
                        title: 'Accommodation',
                        subtitle: 'Add your place to stay',
                        isDone: false,
                        isPartial: false,
                        onTap: () => _openAccommodation(context, ref, null),
                      ),
                      data: (accommodation) => _ModuleCard(
                        emoji: '🏨',
                        title: 'Accommodation',
                        subtitle: accommodation != null
                            ? accommodation.placeName
                            : 'Add your place to stay',
                        isDone: accommodation != null,
                        isPartial: false,
                        onTap: () =>
                            _openAccommodation(context, ref, accommodation),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.inputBorder),
                    const SizedBox(height: 20),

                    _SectionLabel(label: 'CREW'),
                    const SizedBox(height: 10),

                    // Members card — driven by tripMembersProvider
                    membersAsync.when(
                      loading: () => _ModuleCard(
                        emoji: '👥',
                        title: 'Members',
                        subtitle: 'Loading...',
                        isDone: false,
                        isPartial: false,
                        onTap: () =>
                            context.push('/home/trip/$tripId/members'),
                      ),
                      error: (_, __) => _ModuleCard(
                        emoji: '👥',
                        title: 'Members',
                        subtitle: 'View members',
                        isDone: false,
                        isPartial: false,
                        onTap: () =>
                            context.push('/home/trip/$tripId/members'),
                      ),
                      data: (members) {
                        final count = members.length;
                        return _ModuleCard(
                          emoji: '👥',
                          title: 'Members',
                          subtitle: count > 1
                              ? '$count members'
                              : 'Solo — invite your friends!',
                          isDone: count > 1,
                          isPartial: false,
                          onTap: () =>
                              context.push('/home/trip/$tripId/members'),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.inputBorder),
                    const SizedBox(height: 20),

                    _SectionLabel(label: 'PLANS'),
                    const SizedBox(height: 10),

                    _ModuleCard(
                      emoji: '📍',
                      title: 'Activities',
                      subtitle: 'Back to the itinerary',
                      isDone: false,
                      isPartial: false,
                      onTap: () => context.pop(),
                    ),
                    const SizedBox(height: 10),
                    _ModuleCard(
                      emoji: '🗺️',
                      title: 'Map',
                      subtitle: 'Coming soon',
                      isDone: false,
                      isPartial: false,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Map — coming soon 🗺️')),
                        );
                      },
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

  void _openAccommodation(
    BuildContext context,
    WidgetRef ref,
    dynamic existing,
  ) {
    final trip = ref.read(tripsProvider).whenOrNull(
          data: (trips) => trips.where((t) => t.id == tripId).firstOrNull,
        );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddAccommodationScreen(
          tripId: tripId,
          existing: existing,
          onSaved: (_) => ref.invalidate(tripAccommodationProvider(tripId)),
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day}. ${m[d.month]} ${d.year}';
  }
}

// ── Module card ───────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.isPartial,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isPartial;
  final VoidCallback onTap;

  Color get _statusColor {
    if (isDone) return const Color(0xFF4CAF50);
    if (isPartial) return const Color(0xFFFFB300);
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            )),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Checkmark when done, else chevron
              if (isDone)
                const Icon(Icons.check_circle,
                    color: Color(0xFF4CAF50), size: 22)
              else if (isPartial)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Partial',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFB300))),
                )
              else
                Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
    );
  }
}