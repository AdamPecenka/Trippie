import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/map/data/place_suggestion_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/presentation/widgets/activity_form_widgets.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  const AddActivityScreen({super.key, required this.tripId, this.initialPlace});

  final String tripId;
  final PlaceDto? initialPlace;

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
  void initState() {
    super.initState();
    if (widget.initialPlace != null) {
      _selectedPlace = widget.initialPlace;
      _searchController.text = widget.initialPlace!.name;
      _nameController.text = widget.initialPlace!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _notesController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  List<DateTime> get _tripDays {
    final trip = ref
        .read(tripsProvider)
        .whenOrNull(
          data: (trips) =>
              trips.where((t) => t.id == widget.tripId).firstOrNull,
        );
    if (trip == null) return [];
    final start = DateTime(
      trip.startDate.year,
      trip.startDate.month,
      trip.startDate.day,
    );
    final end = DateTime(
      trip.endDate.year,
      trip.endDate.month,
      trip.endDate.day,
    );
    final days = <DateTime>[];
    var d = start;
    while (!d.isAfter(end)) {
      days.add(d);
      d = d.add(const Duration(days: 1));
    }
    return days;
  }

  String _toApiTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _toApiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      !_submitting &&
      !_hasInvalidTime;

  bool get _hasInvalidTime {
    if (_startTime == null || _endTime == null) return false;
    return (_endTime!.hour * 60 + _endTime!.minute) <=
        (_startTime!.hour * 60 + _startTime!.minute);
  }

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

  Future<void> _pickStartTime() async {
    await showCupertinoTimePicker(
      context: context,
      initial: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
      onChanged: (t) => setState(() => _startTime = t),
    );
  }

  Future<void> _pickEndTime() async {
    await showCupertinoTimePicker(
      context: context,
      initial: _endTime ?? _startTime ?? const TimeOfDay(hour: 10, minute: 0),
      onChanged: (t) => setState(() => _endTime = t),
    );
  }

  ActivityDto? _getOverlappingActivity() {
    if (_selectedDay == null || _startTime == null) return null;
    final activities =
        ref
            .read(tripActivitiesProvider(widget.tripId))
            .whenOrNull(data: (list) => list) ??
        [];
    final selectedDateStr = _toApiDate(_selectedDay!);
    final startTime = _startTime!;
    final endTime =
        _endTime ??
        TimeOfDay(hour: startTime.hour + 1, minute: startTime.minute);
    for (final activity in activities) {
      if (activity.activityDate != selectedDateStr) continue;
      if (activity.startTime == null) continue;
      final existingStart = parseTime(activity.startTime!);
      final existingEnd = activity.endTime != null
          ? parseTime(activity.endTime!)
          : TimeOfDay(
              hour: existingStart.hour + 1,
              minute: existingStart.minute,
            );
      if (timesOverlap(startTime, endTime, existingStart, existingEnd)) {
        return activity;
      }
    }
    return null;
  }

  Future<bool> _showOverlapDialog(ActivityDto conflict) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Time conflict'),
        content: Text('At this time you already have "${conflict.name}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('keep'),
            child: const Text('Keep current time'),
          ),
        ],
      ),
    );
    if (result == null || result == 'cancel') return false;
    return true;
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter an activity name.');
      return;
    }

    final conflict = _getOverlappingActivity();
    if (conflict != null) {
      final shouldProceed = await _showOverlapDialog(conflict);
      if (!shouldProceed) return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(activityRepositoryProvider)
          .createActivity(
            widget.tripId,
            CreateActivityRequestDto(
              name: name,
              placeId: _selectedPlace?.id,
              activityDate: _selectedDay != null
                  ? _toApiDate(_selectedDay!)
                  : null,
              startTime: _startTime != null ? _toApiTime(_startTime!) : null,
              endTime: _endTime != null ? _toApiTime(_endTime!) : null,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            ),
          );
      ref.invalidate(tripActivitiesProvider(widget.tripId));
    } on OfflineQueuedException {
      // queued — navigate to success anyway
    } on Exception catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _submitting = false;
      });
      return;
    }

    if (mounted) {
      context.pushReplacement('/home/trip/${widget.tripId}/activity/success');
    }
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
                    Text(
                      'Add activity',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Pick a place to visit',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_selectedPlace == null) ...[
                      ActivitySearchField(
                        controller: _searchController,
                        loading: _searchLoading,
                        onChanged: _onSearchChanged,
                      ),
                      if (_suggestions.isNotEmpty)
                        ActivitySuggestionsList(
                          suggestions: _suggestions,
                          onTap: _onSuggestionTap,
                        ),
                    ] else
                      SelectedPlaceChip(
                        place: _selectedPlace!,
                        onClear: _clearPlace,
                      ),

                    const SizedBox(height: 24),
                    Text(
                      'Activity name',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                    Text(
                      'Date & time',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ActivityDayPicker(
                      selectedDay: _selectedDay,
                      onTap: _pickDay,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ActivityTimeTile(
                            label: 'Start time',
                            value: _startTime != null
                                ? formatTime(_startTime!)
                                : null,
                            onTap: _pickStartTime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ActivityTimeTile(
                            label: 'End time',
                            value: _endTime != null
                                ? formatTime(_endTime!)
                                : null,
                            onTap: _pickEndTime,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Additional notes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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

                    if (_hasInvalidTime) ...[
                      const SizedBox(height: 12),
                      ActivityErrorBanner(
                        message: 'End time must be after start time.',
                      ),
                    ],

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
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
