import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:flutter/cupertino.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  const AddActivityScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
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

  // ── Helpers ──────────────────────────────────────────────────────

  List<DateTime> get _tripDays {
    final trip = ref
        .read(tripsProvider)
        .whenOrNull(data: (trips) =>
            trips.where((t) => t.id == widget.tripId).firstOrNull);

    if (trip == null) return [];

    final start = DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
    final end = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);

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
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[d.weekday]}, ${d.day}. ${months[d.month]}';
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _toApiTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _toApiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool get _canSubmit {
    final hasName = _nameController.text.trim().isNotEmpty;
    return hasName && !_submitting;
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
        final results = await ref
            .read(activityRepositoryProvider)
            .searchPlaces(query);
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
        // auto-fill name ak je prázdne
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
    await _showCupertinoTimePicker(
      initial: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
      onChanged: (t) => setState(() => _startTime = t),
    );
  }

  Future<void> _pickEndTime() async {
    await _showCupertinoTimePicker(
      initial: _endTime ?? _startTime ?? const TimeOfDay(hour: 10, minute: 0),
      onChanged: (t) => setState(() => _endTime = t),
    );
  }

  Future<void> _showCupertinoTimePicker({
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
              Text(
                'Select time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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

  bool _hasTimeOverlap() {
    if (_selectedDay == null || _startTime == null) return false;

    final activities = ref
        .read(tripActivitiesProvider(widget.tripId))
        .whenOrNull(data: (list) => list) ?? [];

    final selectedDateStr = _toApiDate(_selectedDay!);
    final startTime = _startTime!;
    final endTime = _endTime ?? TimeOfDay(hour: startTime.hour + 1, minute: startTime.minute);

    for (final activity in activities) {
      // Only check activities on the same date
      if (activity.activityDate != selectedDateStr) continue;
      
      // Skip activities without time
      if (activity.startTime == null) continue;

      final existingStart = _parseTime(activity.startTime!);
      final existingEnd = activity.endTime != null 
          ? _parseTime(activity.endTime!) 
          : TimeOfDay(hour: existingStart.hour + 1, minute: existingStart.minute);

      // Check for overlap
      if (_timesOverlap(startTime, endTime, existingStart, existingEnd)) {
        return true;
      }
    }
    return false;
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

    // Check for time overlaps
    if (_hasTimeOverlap()) {
      setState(() => _error = 'This activity overlaps with another activity on the same day.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(activityRepositoryProvider).createActivity(
        widget.tripId,
        CreateActivityRequestDto(
          name: name,
          placeId: _selectedPlace?.id,
          activityDate: _selectedDay != null ? _toApiDate(_selectedDay!) : null,
          startTime: _startTime != null ? _toApiTime(_startTime!) : null,
          endTime: _endTime != null ? _toApiTime(_endTime!) : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ),
      );

      // refresh activities
      ref.invalidate(tripActivitiesProvider(widget.tripId));

      if (mounted) {
        context.pushReplacement(
          '/home/trip/${widget.tripId}/activity/success',
        );
      }
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
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    Text('Add activity',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 32),

                    // ── Place search ──────────────────────────────
                    Text('Pick a place to visit',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),

                    if (_selectedPlace == null) ...[
                      _SearchField(
                        controller: _searchController,
                        loading: _searchLoading,
                        onChanged: _onSearchChanged,
                      ),
                      if (_suggestions.isNotEmpty)
                        _SuggestionsList(
                          suggestions: _suggestions,
                          onTap: _onSuggestionTap,
                        ),
                    ] else
                      _SelectedPlaceChip(
                        place: _selectedPlace!,
                        onClear: _clearPlace,
                      ),

                    const SizedBox(height: 24),

                    // ── Activity name ─────────────────────────────
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

                    // Day picker
                    GestureDetector(
                      onTap: _pickDay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

                    // Time pickers
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

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: Colors.redAccent)),
                    ],

                    const SizedBox(height: 32),

                    // ── Submit ────────────────────────────────────
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
                            : const Text('Add to trip'),
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

// ── Sub-widgets ───────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: loading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(Icons.search),
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({
    required this.suggestions,
    required this.onTap,
  });

  final List<PlaceSuggestionDto> suggestions;
  final ValueChanged<PlaceSuggestionDto> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Column(
        children: suggestions
            .map((s) => ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(s.displayName,
                      style: Theme.of(context).textTheme.bodyMedium),
                  onTap: () => onTap(s),
                ))
            .toList(),
      ),
    );
  }
}

class _SelectedPlaceChip extends StatelessWidget {
  const _SelectedPlaceChip({required this.place, required this.onClear});

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
                  Text(place.name,
                      style: Theme.of(context).textTheme.titleSmall),
                  if (place.address != null)
                    Text(place.address!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            )),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClear,
            ),
          ],
        ),
      ),
    );
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.days,
    required this.selected,
    required this.formatDay,
    required this.onSelected,
  });

  final List<DateTime> days;
  final DateTime? selected;
  final String Function(DateTime) formatDay;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final d = days[i];
          final isSelected = selected != null &&
              d.year == selected!.year &&
              d.month == selected!.month &&
              d.day == selected!.day;
          return GestureDetector(
            onTap: () => onSelected(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.buttonPrimary
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                formatDay(d),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    color: value == null ? AppColors.textSecondary : null,
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

class ActivitySuccessScreen extends StatefulWidget {
  const ActivitySuccessScreen({required this.tripId});
  final String tripId;

  @override
  State<ActivitySuccessScreen> createState() => _ActivitySuccessScreenState();
}

class _ActivitySuccessScreenState extends State<ActivitySuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppGradients.backgroundDark
              : AppGradients.background,
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('It\'s on the plan ✅',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 8),
              Text('Your activity has been added.',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}