import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/app/router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/shared/providers/connectivity_provider.dart';
import 'package:trippie_frontend/shared/providers/fab_provider.dart';
import 'package:trippie_frontend/features/trip/presentation/widgets/activity_bottom_sheet.dart';
import 'package:trippie_frontend/features/trip/presentation/widgets/trip_state_badge.dart';

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
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.menu),
                      onSelected: (value) {
                        if (value == 'info') context.push('/home/trip/$tripId/hub');
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'info', child: Text('Trip information')),
                        const PopupMenuItem(value: 'status', child: Text('Change state of trip')),
                        const PopupMenuItem(
                          value: 'leave',
                          child: Text('Leave trip', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
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
                                Text(trip.name, style: Theme.of(context).textTheme.headlineMedium),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDate(trip.startDate)} – ${_formatDate(trip.endDate)}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          TripStateBadge(status: trip.status),
                        ],
                      ),
              ),

              Expanded(
                child: activitiesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
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

  String _formatDate(DateTime d) => '${d.day}. ${_month(d.month)} ${d.year}';

  String _month(int m) => const [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ][m];
}

class _ActivitiesList extends StatelessWidget {
  const _ActivitiesList({required this.activities, required this.trip, required this.tripId});

  final List<ActivityDto> activities;
  final TripDto? trip;
  final String tripId;

  @override
  Widget build(BuildContext context) {
    final byDay = <String, List<ActivityDto>>{};
    for (final a in activities) {
      byDay.putIfAbsent(a.activityDate ?? 'Unknown', () => []).add(a);
    }
    final sortedDays = byDay.keys.toList()..sort();

    return ListView(
      padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 100),
      children: [
        Text('Activities:', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (activities.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Text('No activities yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ),
          )
        else
          ...sortedDays.map((day) => _DaySection(
                day: day,
                activities: byDay[day]!,
                tripId: tripId,
                trip: trip,
              )),
      ],
    );
  }
}

class _DaySection extends StatefulWidget {
  const _DaySection({required this.day, required this.activities, required this.tripId, required this.trip});

  final String day;
  final List<ActivityDto> activities;
  final String tripId;
  final TripDto? trip;

  @override
  State<_DaySection> createState() => _DaySectionState();
}

class _DaySectionState extends State<_DaySection> {
  bool _expanded = true;

  String get _dayLabel {
    try {
      final d = DateTime.parse(widget.day);
      final weekday = const ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d.weekday];
      return '$weekday ${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.';
    } catch (_) {
      return widget.day;
    }
  }

  Set<String> get _overlappingIds {
    final ids = <String>{};
    final activities = widget.activities.where((a) => a.startTime != null).toList();
    for (int i = 0; i < activities.length; i++) {
      for (int j = i + 1; j < activities.length; j++) {
        final a = activities[i];
        final b = activities[j];
        final aStart = _toMin(a.startTime!);
        final aEnd = a.endTime != null ? _toMin(a.endTime!) : aStart + 60;
        final bStart = _toMin(b.startTime!);
        final bEnd = b.endTime != null ? _toMin(b.endTime!) : bStart + 60;
        if (aStart < bEnd && aEnd > bStart) {
          ids.add(a.id);
          ids.add(b.id);
        }
      }
    }
    return ids;
  }

  int _toMin(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  @override
  Widget build(BuildContext context) {
    final overlapping = _overlappingIds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Text(_dayLabel, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          ...widget.activities.map((a) => _ActivityTile(
                activity: a,
                tripId: widget.tripId,
                trip: widget.trip,
                isOverlapping: overlapping.contains(a.id),
              )),
          const SizedBox(height: 8),
        ] else
          const Divider(height: 1),
      ],
    );
  }
}

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({required this.activity, required this.tripId, required this.trip, required this.isOverlapping});

  final ActivityDto activity;
  final String tripId;
  final TripDto? trip;
  final bool isOverlapping;

  String get _timeRange {
    if (activity.startTime == null) return '';
    final start = activity.startTime!.substring(0, 5);
    if (activity.endTime == null) return start;
    return '$start – ${activity.endTime!.substring(0, 5)}';
  }

  void _showBottomSheet(BuildContext context, WidgetRef ref, bool canEdit, bool canDelete) {
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
          child: ActivityBottomSheet(
            activity: activity,
            tripId: tripId,
            canEdit: canEdit,
            canDelete: canDelete,
            onDeleted: () {
              Navigator.of(ctx).pop();
              final isOnline = ref.read(isOnlineProvider);
              if (isOnline) {
                ref.invalidate(tripActivitiesProvider(tripId));
              }
            },
            onEdit: () {
              Navigator.of(ctx).pop();
              context.push('/home/trip/$tripId/activity/${activity.id}/edit');
            },
            onViewOnMap: () {
              Navigator.of(ctx).pop();
              context.go('/map', extra: {
                'lat': activity.place?.latitude,
                'lng': activity.place?.longitude,
                'name': activity.place?.name ?? activity.name,
              });
            },
          ),
        ),
      ),
    ).whenComplete(() {
      ref.read(fabProvider.notifier).setActions([
        FabAction(label: 'Add activity', onTap: () => context.push(AppRoutes.createActivity.replaceFirst(':tripId', tripId))),
        FabAction(label: 'Invite friends', onTap: () => context.push(AppRoutes.invite.replaceFirst(':tripId', tripId))),
      ]);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authProvider).whenOrNull(data: (user) => user?.id);
    final currentMember = ref.watch(tripMembersProvider(tripId)).whenOrNull(
          data: (members) => members.where((m) => m.userId == currentUserId).firstOrNull,
        );
    final isManager = currentMember?.tripRole == 'TRIP_MANAGER';
    final isOwner = activity.createdBy == currentUserId;
    final status = trip?.status;

    final bool canEdit;
    final bool canDelete;
    if (status == TripStatus.finished) {
      canEdit = false;
      canDelete = false;
    } else if (status == TripStatus.active) {
      canEdit = isManager;
      canDelete = isManager;
    } else {
      canEdit = isOwner || isManager;
      canDelete = isOwner || isManager;
    }

    debugPrint('🎯 activity: ${activity.name}, createdBy: ${activity.createdBy}, currentUserId: $currentUserId, isOwner: $isOwner, canEdit: $canEdit, canDelete: $canDelete');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activity.startTime != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(activity.startTime!.substring(0, 5),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ),
        Material(
          color: isOverlapping ? const Color(0xFFFFF3E0) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          elevation: 1,
          child: InkWell(
            onTap: () => _showBottomSheet(context, ref, canEdit, canDelete),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: isOverlapping
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border(left: BorderSide(color: Colors.orange.shade400, width: 4)),
                    )
                  : null,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activity.name ?? 'Activity', style: Theme.of(context).textTheme.titleMedium),
                            if (_timeRange.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(_timeRange,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: isOverlapping ? Colors.orange.shade700 : AppColors.textSecondary,
                                        fontWeight: isOverlapping ? FontWeight.w600 : FontWeight.normal,
                                      )),
                            ],
                            if (activity.place != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      activity.place!.address ?? activity.place!.name,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isOverlapping)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade600),
                            ),
                          if (isOwner)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7B68EE).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('mine',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF7B68EE), fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ],
                  ),
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