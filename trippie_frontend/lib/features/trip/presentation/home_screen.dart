import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/app/router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/presentation/widgets/trip_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).when(
          data: (data) => data,
          loading: () => null,
          error: (_, __) => null,
        );
    final tripsAsync = ref.watch(tripsProvider);

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
          child: tripsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Error: $e')),
            data: (trips) => _TripsList(
              firstName: user?.firstname ?? '',
              trips: trips,
            ),
          ),
        ),
      ),
    );
  }
}

class _TripsList extends ConsumerWidget {
  const _TripsList({
    required this.firstName,
    required this.trips,
  });

  final String firstName;
  final List<TripDto> trips;

  List<TripDto> get _upcoming => trips
    .where((t) => t.tripStatus == 'PLANNING' || t.tripStatus == 'ACTIVE')
    .toList()
  ..sort((a, b) {
    // ACTIVE before PLANNING
    if (a.tripStatus == 'ACTIVE' && b.tripStatus != 'ACTIVE') return -1;
    if (a.tripStatus != 'ACTIVE' && b.tripStatus == 'ACTIVE') return 1;
    return a.startDate.compareTo(b.startDate);
  });

  List<TripDto> get _history => trips
      .where((t) => t.tripStatus == 'FINISHED')
      .toList()
    ..sort((a, b) => b.startDate.compareTo(a.startDate));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(tripsProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          Text(
            'Hello, $firstName 👋',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          if (trips.isEmpty) ...[
            const SizedBox(height: 200),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No trips yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Let's change that.\nCreate a trip and invite your friends.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            if (_upcoming.isNotEmpty) ...[
              Text(
                'Your upcoming trips:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ..._upcoming.map(
                (trip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TripCard(
                    trip: trip,
                    onTap: () => context.push(
                      AppRoutes.tripDetail.replaceFirst(':tripId', trip.id),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (_history.isNotEmpty) ...[
              Text(
                'History of trips:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ..._history.map(
                (trip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TripCard(
                    trip: trip,
                    onTap: () => context.push(
                      AppRoutes.tripDetail.replaceFirst(':tripId', trip.id),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}