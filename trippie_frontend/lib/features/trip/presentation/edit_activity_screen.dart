import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';

class EditActivityScreen extends ConsumerStatefulWidget {
  const EditActivityScreen({
    super.key,
    required this.tripId,
    required this.activityId,
  });

  final String tripId;
  final String activityId;

  @override
  ConsumerState<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends ConsumerState<EditActivityScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();

  PlaceDto? _selectedPlace;
  DateTime? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<PlaceSuggestionDto> _suggestions = [];
  bool _searchLoading = false;
  bool _submitting = false;
  bool _initialized = false;
  String? _error;

  Timer? _debounce;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _notesController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Pre-fill from existing activity ──────────────────────────────

  void _initFromActivity(ActivityDto activity) {
    if (_initialized) return;
    _initialized = true;

    _nameController.text = activity.name ?? '';
    _notesController.text = activity.notes ?? '';

    if (activity.activityDate != null) {
      try {
        final date = DateTime.parse(activity.activityDate!);
        final days = _tripDays;
        // ak je dátum mimo tripu, nastav prvý deň tripu
        final isInRange = days.any(
          (d) => d.year == date.year && d.month == date.month && d.day == date.day,
        );
        _selectedDay = isInRange ? date : (days.isNotEmpty ? days.first : date);
      } catch (_) {}
    }

    if (activity.startTime != null) {
      final parts = activity.startTime!.split(':');
      if (parts.length >= 2) {
        _startTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    if (activity.endTime != null) {
      final parts = activity.endTime!.split(':');
      if (parts.length >= 2) {
        _endTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    if (activity.place != null) {
      _selectedPlace = activity.place;
      _searchController.text = activity.place!.name;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────

  List<DateTime> get _tripDays {
    final trip = ref
        .read(tripsProvider)
        .whenOrNull(
            data: (trips) =>
                trips.where((t) => t.id == widget.tripId).firstOrNull);
    if (trip == null) return [];
    final start =
        DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
    final end =
        DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);
    final days = <DateTime>[];
    var d = start;
    while (!d.isAfter(end)) {
      days.add(d);
      d = d.add(const Duration(days: 1));
    }
    return days;
  }

  String _formatDay(DateTime d) {
    const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${weekdays[d.weekday]}, ${d.day}. ${months[d.month]}';
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _toApiTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _toApiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty && !_submitting && !_hasInvalidTime;

  bool get _hasInvalidTime {
    if (_startTime == null || _endTime == null) return false;
    final start = _startTime!.hour * 60 + _startTime!.minute;
    final end = _endTime!.hour * 60 + _endTime!.minute;
    return end <= start;
  }

  // ── Place search ──────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _searchLoading = true);
      try {
        final results =
            await ref.read(activityRepositoryProvider).searchPlaces(query);
        setState(() => _suggestions = results);
      } catch (_) {
        setState(() => _suggestions = []);
      } finally {
        setState(() => _searchLoading = false);
      }
    });
  }

  Future<void> _onSuggestionTap(PlaceSuggestionDto suggestion) async {
    setState(() => _searchLoading = true);
    try {
      final place = await ref
          .read(activityRepositoryProvider)
          .resolvePlace(suggestion.googlePlaceId);
      setState(() {
        _selectedPlace = place;
        _suggestions = [];
        _searchController.text = place.name;
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = place.name;
        }
      });
    } catch (_) {
    } finally {
      setState(() => _searchLoading = false);
    }
  }

  void _clearPlace() {
    setState(() {
      _selectedPlace = null;
      _searchController.clear();
      _suggestions = [];
    });
  }

  // ── Day picker ────────────────────────────────────────────────────

  Future<void> _pickDay() async {
    final days = _tripDays;
    if (days.isEmpty) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? days.first,
      firstDate: days.first,
      lastDate: days.last,
      selectableDayPredicate: (day) => days.any(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day,
      ),
    );
    if (picked != null) setState(() => _selectedDay = picked);
  }

  // ── Time pickers ──────────────────────────────────────────────────

  Future<void> _pickStartTime() async {
    await _showTimePicker(
      initial: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
      onChanged: (t) => setState(() => _startTime = t),
    );
  }

  Future<void> _pickEndTime() async {
    await _showTimePicker(
      initial: _endTime ?? _startTime ?? const TimeOfDay(hour: 10, minute: 0),
      onChanged: (t) => setState(() => _endTime = t),
    );
  }

  Future<void> _showTimePicker({
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onChanged,
  }) async {
    var selected = DateTime(2000, 1, 1, initial.hour, initial.minute);
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: 280,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text('Select time',
                  style: Theme.of(context).textTheme.titleMedium),
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

  // ── Activity overlap validation ────────────────────────────────────

  bool get _hasOverlap => _getOverlappingActivity() != null;

  ActivityDto? _getOverlappingActivity() {
    if (_selectedDay == null || _startTime == null) return null;

    final activities = ref
        .read(tripActivitiesProvider(widget.tripId))
        .whenOrNull(data: (list) => list) ?? [];

    final selectedDateStr = _toApiDate(_selectedDay!);
    final startTime = _startTime!;
    final endTime = _endTime ?? TimeOfDay(hour: startTime.hour + 1, minute: startTime.minute);

    for (final activity in activities) {
      if (activity.id == widget.activityId) continue;
      if (activity.activityDate != selectedDateStr) continue;
      if (activity.startTime == null) continue;

      final existingStart = _parseTime(activity.startTime!);
      final existingEnd = activity.endTime != null
          ? _parseTime(activity.endTime!)
          : TimeOfDay(hour: existingStart.hour + 1, minute: existingStart.minute);

      if (_timesOverlap(startTime, endTime, existingStart, existingEnd)) {
        return activity;
      }
    }
    return null;
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool _timesOverlap(TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
    final start1Minutes = start1.hour * 60 + start1.minute;
    final end1Minutes = end1.hour * 60 + end1.minute;
    final start2Minutes = start2.hour * 60 + start2.minute;
    final end2Minutes = end2.hour * 60 + end2.minute;

    return start1Minutes < end2Minutes && end1Minutes > start2Minutes;
  }

  // ── Submit ────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter an activity name.');
      return;
    }

    // overlap — nezastaví uloženie, len zobrazí badge
    setState(() => _error = null);

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(activityRepositoryProvider).patchActivity(
            widget.tripId,
            widget.activityId,
            CreateActivityRequestDto(
              name: name,
              placeId: _selectedPlace?.id,
              activityDate:
                  _selectedDay != null ? _toApiDate(_selectedDay!) : null,
              startTime:
                  _startTime != null ? _toApiTime(_startTime!) : null,
              endTime: _endTime != null ? _toApiTime(_endTime!) : null,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            ),
          );

      ref.invalidate(tripActivitiesProvider(widget.tripId));

      if (mounted) context.pop();
    } on Exception catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _submitting = false;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Pre-fill from cached activities
    final activity = ref
        .watch(tripActivitiesProvider(widget.tripId))
        .whenOrNull(
            data: (list) =>
                list.where((a) => a.id == widget.activityId).firstOrNull);

    if (activity != null) _initFromActivity(activity);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppGradients.backgroundDark
              : AppGradients.background,
        ),
        child: SafeArea(
          child: Column(
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
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    Text('Edit activity',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 32),

                    // ── Place ─────────────────────────────────────
                    Text('Pick a place to visit',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_selectedPlace == null) ...[
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search for a place',
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: _searchLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : const Icon(Icons.search),
                        ),
                      ),
                      if (_suggestions.isNotEmpty)
                        Card(
                          margin: const EdgeInsets.only(top: 4),
                          child: Column(
                            children: _suggestions
                                .map((s) => ListTile(
                                      leading:
                                          const Icon(Icons.place_outlined),
                                      title: Text(s.displayName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                      onTap: () => _onSuggestionTap(s),
                                    ))
                                .toList(),
                          ),
                        ),
                    ] else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.place,
                                  color: Color(0xFF7B68EE)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(_selectedPlace!.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    if (_selectedPlace!.address != null)
                                      Text(
                                        _selectedPlace!.address!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color:
                                                    AppColors.textSecondary),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: _clearPlace,
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ── Name ──────────────────────────────────────
                    Text('Activity name',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'e.g. Morning Run, Museum visit...',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Date & time ───────────────────────────────
                    Text('Date & time',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: _pickDay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDay != null
                                  ? _formatDay(_selectedDay!)
                                  : 'Select a day',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: _selectedDay == null
                                        ? AppColors.textSecondary
                                        : null,
                                  ),
                            ),
                            Icon(Icons.calendar_today,
                                size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _TimeTile(
                            label: 'Start time',
                            value: _startTime != null
                                ? _formatTime(_startTime!)
                                : null,
                            onTap: _pickStartTime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimeTile(
                            label: 'End time',
                            value: _endTime != null
                                ? _formatTime(_endTime!)
                                : null,
                            onTap: _pickEndTime,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Notes ─────────────────────────────────────
                    Text('Additional notes',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add any details...',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    // invalid time badge
                    if (_hasInvalidTime) ...[
                      const SizedBox(height: 12),
                      Container(
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
                            Text(
                              'End time must be after start time.',
                              style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // overlap badge
                    if (_hasOverlap) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Time conflict with "${_getOverlappingActivity()?.name ?? 'another activity'}". You can still save.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: Colors.redAccent)),
                    ],

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canSubmit ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          foregroundColor: AppColors.buttonPrimaryText,
                          minimumSize: const Size(double.infinity, 54),
                          shape: const StadiumBorder(),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save changes'),
                      ),
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
}

// ── TimeTile (lokálna kópia) ───────────────────────────────────────
class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        value == null ? AppColors.textSecondary : null,
                  ),
            ),
            Icon(Icons.access_time,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}