import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/flight_dto.dart';
import 'package:trippie_frontend/features/trip/data/flight_repository.dart';

class FlightsScreen extends ConsumerWidget {
  const FlightsScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flightsAsync = ref.watch(tripFlightsProvider(tripId));

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
              // header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/home/trip/$tripId/flights/add'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add flight'),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text('Flights',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),

              Expanded(
                child: flightsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Error: $e')),
                  data: (flights) {
                    if (flights.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('✈️',
                                style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text('No flights yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium),
                            const SizedBox(height: 4),
                            Text('Add your outbound and return flights.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AppColors.textSecondary)),
                          ],
                        ),
                      );
                    }

                    final outbound = flights
                        .where((f) => f.isOutbound)
                        .toList();
                    final returnFlights = flights
                        .where((f) => !f.isOutbound)
                        .toList();

                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        24, 0, 24,
                        MediaQuery.of(context).padding.bottom + 100,
                      ),
                      children: [
                        if (outbound.isNotEmpty) ...[
                          _SectionLabel('Outbound'),
                          const SizedBox(height: 8),
                          ...outbound.map((f) => _FlightCard(
                                flight: f,
                                tripId: tripId,
                                onDeleted: () =>
                                    ref.invalidate(tripFlightsProvider(tripId)),
                              )),
                          const SizedBox(height: 16),
                        ],
                        if (returnFlights.isNotEmpty) ...[
                          _SectionLabel('Return'),
                          const SizedBox(height: 8),
                          ...returnFlights.map((f) => _FlightCard(
                                flight: f,
                                tripId: tripId,
                                onDeleted: () =>
                                    ref.invalidate(tripFlightsProvider(tripId)),
                              )),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ));
  }
}

// ── Flight card ───────────────────────────────────────────────────
class _FlightCard extends ConsumerWidget {
  const _FlightCard({
    required this.flight,
    required this.tripId,
    required this.onDeleted,
  });

  final FlightDto flight;
  final String tripId;
  final VoidCallback onDeleted;

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day}.${dt.month}. ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete flight'),
        content: Text(
            'Remove flight ${flight.routeLabel}${flight.flightNumber != null ? ' (${flight.flightNumber})' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(flightRepositoryProvider).deleteFlight(tripId, flight.id);
      onDeleted();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      flight.routeLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (flight.flightNumber != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B68EE).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          flight.flightNumber!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7B68EE),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${flight.departureCityName} → ${flight.arrivalCityName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (flight.departureTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDateTime(flight.departureTime)} → ${_formatDateTime(flight.arrivalTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 20, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }
}