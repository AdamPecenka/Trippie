import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/app/router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_member_dto.dart';
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
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.menu),
                      onSelected: (value) {
                        switch (value) {
                          case 'info':
                            context.push('/home/trip/$tripId/hub');
                            break;
                          case 'members':
                            context.push('/home/trip/$tripId/members');
                            break;
                          case 'status':
                            // TODO: change status
                            break;
                          case 'leave':
                            // TODO: leave trip
                            break;
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'info',
                          child: Text('Trip information'),
                        ),
                        const PopupMenuItem(
                          value: 'status',
                          child: Text('Change state of trip'),
                        ),
                        const PopupMenuItem(
                          value: 'leave',
                          child: Text('Leave trip',
                              style: TextStyle(color: Colors.redAccent)),
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
                trip: trip,
              )),
      ],
    );
  }
}

// ── Collapsible day section ────────────────────────────────────────
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
      final weekday = const [
        '', 'Monday', 'Tuesday', 'Wednesday',
        'Thursday', 'Friday', 'Saturday', 'Sunday'
      ][d.weekday];
      return '$weekday ${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.';
    } catch (_) {
      return widget.day;
    }
  }

  // ── Overlap detection ─────────────────────────────────────────────
  Set<String> get _overlappingIds {
    final ids = <String>{};
    final activities = widget.activities
        .where((a) => a.startTime != null)
        .toList();

    for (int i = 0; i < activities.length; i++) {
      for (int j = i + 1; j < activities.length; j++) {
        final a = activities[i];
        final b = activities[j];
        final aStart = _toMinutes(a.startTime!);
        final aEnd = a.endTime != null ? _toMinutes(a.endTime!) : aStart + 60;
        final bStart = _toMinutes(b.startTime!);
        final bEnd = b.endTime != null ? _toMinutes(b.endTime!) : bStart + 60;

        if (aStart < bEnd && aEnd > bStart) {
          ids.add(a.id);
          ids.add(b.id);
        }
      }
    }
    return ids;
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
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

// ── Activity tile ──────────────────────────────────────────────────
class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({
    required this.activity,
    required this.tripId,
    required this.trip,
    required this.isOverlapping,
  });

  final ActivityDto activity;
  final String tripId;
  final TripDto? trip;
  final bool isOverlapping;

  String get _timeRange {
    if (activity.startTime == null) return '';
    final start = activity.startTime!.substring(0, 5);
    if (activity.endTime == null) return start;
    final end = activity.endTime!.substring(0, 5);
    return '$start – $end';
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
          child: _ActivityBottomSheet(
            activity: activity,
            tripId: tripId,
            canEdit: canEdit,
            canDelete: canDelete,
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
        FabAction(
          label: 'Add activity',
          onTap: () => context.push(AppRoutes.createActivity.replaceFirst(':tripId', tripId)),
        ),
        FabAction(
          label: 'Invite friends',
          onTap: () => context.push(AppRoutes.invite.replaceFirst(':tripId', tripId)),
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // current user
    final currentUserId = ref.watch(authProvider).whenOrNull(
      data: (user) => user?.id,
    );

    // member role
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final currentMember = membersAsync.whenOrNull(
      data: (members) => members.where((m) => m.userId == currentUserId).firstOrNull,
    );
    final isManager = currentMember?.tripRole == 'TRIP_MANAGER';
    final isOwner = activity.createdBy == currentUserId;
    final status = trip?.status;

    // permission matrix
    final bool canEdit;
    final bool canDelete;
    if (status == TripStatus.finished) {
      canEdit = false;
      canDelete = false;
    } else if (status == TripStatus.active) {
      canEdit = isManager;
      canDelete = isManager;
    } else {
      // planning
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
            child: Text(
              activity.startTime!.substring(0, 5),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        Material(
          color: isOverlapping
              ? const Color(0xFFFFF3E0) // svetlo oranžová
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          elevation: 1,
          child: InkWell(
            onTap: () => _showBottomSheet(context, ref, canEdit, canDelete),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: isOverlapping
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(
                          color: Colors.orange.shade400,
                          width: 4,
                        ),
                      ),
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
                          Text(
                            activity.name ?? 'Activity',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_timeRange.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _timeRange,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isOverlapping
                                        ? Colors.orange.shade700
                                        : AppColors.textSecondary,
                                    fontWeight: isOverlapping
                                        ? FontWeight.w600
                                        : FontWeight.normal,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isOverlapping)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Icon(Icons.warning_amber_rounded,
                                size: 16, color: Colors.orange.shade600),
                          ),
                        // creator badge
                        if (isOwner)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7B68EE).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'mine',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF7B68EE),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

// ── Activity bottom sheet ──────────────────────────────────────────
class _ActivityBottomSheet extends ConsumerStatefulWidget {
  const _ActivityBottomSheet({
    required this.activity,
    required this.tripId,
    required this.canEdit,
    required this.canDelete,
    required this.onDeleted,
    required this.onEdit,
    required this.onViewOnMap,
  });

  final ActivityDto activity;
  final String tripId;
  final bool canEdit;
  final bool canDelete;
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

          // edit + delete — len ak má povolenie
          if (widget.canEdit || widget.canDelete)
          Row(
            children: [
              if (widget.canEdit) ...[
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
                if (widget.canDelete) const SizedBox(width: 12),
              ],
              if (widget.canDelete)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleting ? null : _confirmDelete,
                    icon: _deleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
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