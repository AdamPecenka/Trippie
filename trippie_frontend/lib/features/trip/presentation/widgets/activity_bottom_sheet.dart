import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_repository.dart';

class ActivityBottomSheet extends ConsumerStatefulWidget {
  const ActivityBottomSheet({
    super.key,
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
  ConsumerState<ActivityBottomSheet> createState() => _ActivityBottomSheetState();
}

class _ActivityBottomSheetState extends ConsumerState<ActivityBottomSheet> {
  bool _deleting = false;

  String get _timeRange {
    if (widget.activity.startTime == null) return '';
    final start = widget.activity.startTime!.substring(0, 5);
    if (widget.activity.endTime == null) return start;
    return '$start – ${widget.activity.endTime!.substring(0, 5)}';
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete activity'),
        content: Text('Are you sure you want to delete "${widget.activity.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(activityRepositoryProvider).deleteActivity(widget.tripId, widget.activity.id);
      widget.onDeleted();
    } on Exception catch (e) {
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
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          Text(widget.activity.name ?? 'Activity', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),

          if (_timeRange.isNotEmpty)
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(_timeRange, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ],
            ),

          if (widget.activity.place != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.place_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.activity.place!.address ?? widget.activity.place!.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],

          if (widget.activity.notes != null && widget.activity.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sticky_note_2_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(widget.activity.notes!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

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

          if (widget.canEdit || widget.canDelete)
            Row(
              children: [
                if (widget.canEdit) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: const StadiumBorder()),
                    ),
                  ),
                  if (widget.canDelete) const SizedBox(width: 12),
                ],
                if (widget.canDelete)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deleting ? null : _confirmDelete,
                      icon: _deleting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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