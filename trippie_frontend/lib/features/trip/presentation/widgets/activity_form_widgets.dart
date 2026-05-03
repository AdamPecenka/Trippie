import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/map/data/place_suggestion_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';

// ── Helpers (shared between add/edit screens) ─────────────────────

String formatTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

TimeOfDay parseTime(String timeStr) {
  final parts = timeStr.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

bool timesOverlap(TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
  final s1 = start1.hour * 60 + start1.minute;
  final e1 = end1.hour * 60 + end1.minute;
  final s2 = start2.hour * 60 + start2.minute;
  final e2 = end2.hour * 60 + end2.minute;
  return s1 < e2 && e1 > s2;
}

Future<void> showCupertinoTimePicker({
  required BuildContext context,
  required TimeOfDay initial,
  required ValueChanged<TimeOfDay> onChanged,
}) async {
  var selected = DateTime(2000, 1, 1, initial.hour, initial.minute);
  await showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: 280,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text('Select time', style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: selected,
                onDateTimeChanged: (dt) {
                  selected = dt;
                  onChanged(TimeOfDay(hour: dt.hour, minute: dt.minute));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Widgets ───────────────────────────────────────────────────────

class ActivitySearchField extends StatelessWidget {
  const ActivitySearchField({
    super.key,
    required this.controller,
    required this.loading,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool loading;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search for a place',
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: loading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : const Icon(Icons.search),
      ),
    );
  }
}

class ActivitySuggestionsList extends StatelessWidget {
  const ActivitySuggestionsList({super.key, required this.suggestions, required this.onTap});

  final List<PlaceSuggestionDto> suggestions;
  final ValueChanged<PlaceSuggestionDto> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Column(
        children: suggestions.map((s) => ListTile(
          leading: const Icon(Icons.place_outlined),
          title: Text(s.displayName, style: Theme.of(context).textTheme.bodyMedium),
          onTap: () => onTap(s),
        )).toList(),
      ),
    );
  }
}

class SelectedPlaceChip extends StatelessWidget {
  const SelectedPlaceChip({super.key, required this.place, required this.onClear});

  final PlaceDto place;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.place, color: Color(0xFF7B68EE)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: Theme.of(context).textTheme.titleSmall),
                  if (place.address != null)
                    Text(place.address!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClear),
          ],
        ),
      ),
    );
  }
}

class ActivityDayPicker extends StatelessWidget {
  const ActivityDayPicker({super.key, required this.selectedDay, required this.onTap});

  final DateTime? selectedDay;
  final VoidCallback onTap;

  String _formatDay(DateTime d) {
    const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[d.weekday]}, ${d.day}. ${months[d.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDay != null ? _formatDay(selectedDay!) : 'Select a day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selectedDay == null ? AppColors.textSecondary : null,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class ActivityTimeTile extends StatelessWidget {
  const ActivityTimeTile({super.key, required this.label, required this.value, required this.onTap});

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value == null ? AppColors.textSecondary : null,
              ),
            ),
            const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class ActivityErrorBanner extends StatelessWidget {
  const ActivityErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Text(message, style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
        ],
      ),
    );
  }
}

class ActivityWarningBanner extends StatelessWidget {
  const ActivityWarningBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
          ),
        ],
      ),
    );
  }
}