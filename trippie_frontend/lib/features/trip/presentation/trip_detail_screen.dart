import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/app/router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';
import 'package:trippie_frontend/shared/providers/fab_provider.dart';

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
                    tripId: tripId,
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
  const _ActivitiesList({
    required this.activities,
    required this.trip,
    required this.tripId,
  });

  final List<ActivityDto> activities;
  final TripDto? trip;
  final String tripId;

  @override
  Widget build(BuildContext context) {
    final byDay = <String, List<ActivityDto>>{};
    for (final a in activities) {
      final key = a.activityDate ?? 'Unknown';
      byDay.putIfAbsent(key, () => []).add(a);
    }
    final sortedDays = byDay.keys.toList()..sort();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        24, 0, 24,
        MediaQuery.of(context).padding.bottom + 100,
      ),
      children: [
        Text('Activities:',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (activities.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Text(
                'No activities yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          )
        else
          ...sortedDays.map((day) => _DaySection(
                day: day,
                activities: byDay[day]!,
                tripId: tripId,
              )),
      ],
    );
  }
}

// ── Collapsible day section ────────────────────────────────────────
class _DaySection extends StatefulWidget {
  const _DaySection({required this.day, required this.activities, required this.tripId});

  final String day;
  final List<ActivityDto> activities;
  final String tripId;

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
          ...widget.activities.map((a) => _ActivityTile(activity: a, tripId: widget.tripId)),
          const SizedBox(height: 8),
        ] else
          const Divider(height: 1),
      ],
    );
  }
}

// ── Activity tile ──────────────────────────────────────────────────
class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({required this.activity, required this.tripId});

  final ActivityDto activity;
  final String tripId;

  String get _timeRange {
    if (activity.startTime == null) return '';
    final start = activity.startTime!.substring(0, 5);
    if (activity.endTime == null) return start;
    final end = activity.endTime!.substring(0, 5);
    return '$start – $end';
  }

  void _showBottomSheet(BuildContext context, WidgetRef ref) {
    ref.read(fabProvider.notifier).clear();

    final navbarHeight = 64.0 + MediaQuery.of(context).viewPadding.bottom;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: false,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, navbarHeight + 46),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            child: _ActivityBottomSheet(
              activity: activity,
              tripId: tripId,
              onDeleted: () {
                Navigator.of(ctx).pop();
                ref.invalidate(tripActivitiesProvider(tripId));
              },
              onEdit: () {
                Navigator.of(ctx).pop();
                context.push('/home/trip/$tripId/activity/${activity.id}/edit');
              },
              onViewOnMap: () {
                Navigator.of(ctx).pop();
                context.go(
                  '/map',
                  extra: {
                    'lat': activity.place?.latitude,
                    'lng': activity.place?.longitude,
                    'name': activity.place?.name ?? activity.name,
                  },
                );
              },
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      ref.read(fabProvider.notifier).setActions([
        FabAction(
          label: 'Add activity',
          onTap: () => context.push(
            AppRoutes.createActivity.replaceFirst(':tripId', tripId),
          ),
        ),
        FabAction(
          label: 'Invite friends',
          onTap: () => context.push(
            AppRoutes.invite.replaceFirst(':tripId', tripId),
          ),
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          elevation: 1,
          child: InkWell(
            onTap: () => _showBottomSheet(context, ref),
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
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
                    if (activity.place != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              activity.place!.address ?? activity.place!.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Activity bottom sheet ──────────────────────────────────────────
class _ActivityBottomSheet extends ConsumerStatefulWidget {
  const _ActivityBottomSheet({
    required this.activity,
    required this.tripId,
    required this.onDeleted,
    required this.onEdit,
    required this.onViewOnMap,
  });

  final ActivityDto activity;
  final String tripId;
  final VoidCallback onDeleted;
  final VoidCallback onEdit;
  final VoidCallback onViewOnMap;

  @override
  ConsumerState<_ActivityBottomSheet> createState() =>
      _ActivityBottomSheetState();
}

class _ActivityBottomSheetState extends ConsumerState<_ActivityBottomSheet> {
  bool _deleting = false;

  String get _timeRange {
    if (widget.activity.startTime == null) return '';
    final start = widget.activity.startTime!.substring(0, 5);
    if (widget.activity.endTime == null) return start;
    final end = widget.activity.endTime!.substring(0, 5);
    return '$start – $end';
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete activity'),
        content: Text(
            'Are you sure you want to delete "${widget.activity.name}"?'),
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

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref
          .read(activityRepositoryProvider)
          .deleteActivity(widget.tripId, widget.activity.id);
      widget.onDeleted();
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardBackground
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // name
          Text(
            widget.activity.name ?? 'Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),

          // time
          if (_timeRange.isNotEmpty)
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(_timeRange,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        )),
              ],
            ),

          // place
          if (widget.activity.place != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.place_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.activity.place!.address ??
                        widget.activity.place!.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ],

          // notes
          if (widget.activity.notes != null &&
              widget.activity.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sticky_note_2_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.activity.notes!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // view on map — len ak má place s koordinátmi
          if (widget.activity.place != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onViewOnMap,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('View on map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B68EE),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // edit + delete
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _deleting ? null : _confirmDelete,
                  icon: _deleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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