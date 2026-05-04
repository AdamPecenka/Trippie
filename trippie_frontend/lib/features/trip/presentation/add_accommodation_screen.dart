// lib/features/trip/presentation/add_accommodation_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/accommodation_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';

// ─── Local search models ──────────────────────────────────────────────────────

class _PlaceSuggestion {
  final String googlePlaceId;
  final String displayName;
  const _PlaceSuggestion({required this.googlePlaceId, required this.displayName});
}

class _ResolvedPlace {
  final String id;
  final String name;
  final String? address;
  const _ResolvedPlace({required this.id, required this.name, this.address});
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddAccommodationScreen extends ConsumerStatefulWidget {
  const AddAccommodationScreen({
    super.key,
    required this.tripId,
    this.existing,
    this.onSaved,
  });

  final String tripId;
  final AccommodationDto? existing;
  final ValueChanged<AccommodationDto>? onSaved;

  @override
  ConsumerState<AddAccommodationScreen> createState() =>
      _AddAccommodationScreenState();
}

class _AddAccommodationScreenState
    extends ConsumerState<AddAccommodationScreen> {
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();

  _ResolvedPlace? _selectedPlace;
  List<_PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _showDropdown = false;

  TimeOfDay _checkInTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 10, minute: 0);

  bool _isLoading = false;
  Timer? _debounce;

  bool get _isEditing => widget.existing != null;
  bool get _canSubmit => _selectedPlace != null;

  // ── lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.existing!;
      _addressController.text = e.address ?? '';
      _nameController.text = e.placeName;
      if (e.checkIn != null) _checkInTime = TimeOfDay.fromDateTime(e.checkIn!);
      if (e.checkOut != null) _checkOutTime = TimeOfDay.fromDateTime(e.checkOut!);
      // placeId might not be in AccommodationDto — use empty string as fallback
      // so the existing data is shown but user must re-search to save
      _selectedPlace = _ResolvedPlace(
        id: e.placeId ?? '',
        name: e.placeName,
        address: e.address,
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Places search ─────────────────────────────────────────────────────────

  void _onAddressChanged(String query) {
    if (_selectedPlace != null) {
      setState(() { _selectedPlace = null; _nameController.clear(); });
    }
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() { _suggestions = []; _showDropdown = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isSearching = true);
      try {
        final results =
            await ref.read(activityRepositoryProvider).searchPlaces(query);
        final suggestions = results
            .map((r) => _PlaceSuggestion(
                  googlePlaceId: r.googlePlaceId,
                  displayName: r.displayName,
                ))
            .toList();
        if (mounted) {
          setState(() {
            _suggestions = suggestions;
            _showDropdown = suggestions.isNotEmpty;
            _isSearching = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  Future<void> _selectSuggestion(_PlaceSuggestion suggestion) async {
    setState(() { _isSearching = true; _showDropdown = false; });
    try {
      final place = await ref
          .read(activityRepositoryProvider)
          .resolvePlace(suggestion.googlePlaceId);
      if (mounted) {
        setState(() {
          _selectedPlace = _ResolvedPlace(
            id: place.id,
            name: place.name,
            address: place.address,
          );
          _addressController.text = place.address ?? suggestion.displayName;
          _nameController.text = place.name;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── Time pickers ──────────────────────────────────────────────────────────

  Future<void> _pickCheckInTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _checkInTime,
      builder: (ctx, child) => _themed(ctx, child!),
    );
    if (t != null) setState(() => _checkInTime = t);
  }

  Future<void> _pickCheckOutTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _checkOutTime,
      builder: (ctx, child) => _themed(ctx, child!),
    );
    if (t != null) setState(() => _checkOutTime = t);
  }

  Widget _themed(BuildContext ctx, Widget child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.accent),
        ),
        child: child,
      );

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_canSubmit) return;

    // Editing: if placeId is empty the user hasn't re-searched — require it
    if (_isEditing && _selectedPlace!.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search and select the hotel address again to save changes.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final trip = ref.read(tripsProvider).whenOrNull(
        data: (trips) => trips.where((t) => t.id == widget.tripId).firstOrNull,
      );
      final startDate = trip?.startDate ?? DateTime.now();
      final endDate = trip?.endDate ?? DateTime.now().add(const Duration(days: 7));
      final checkIn = _combine(startDate, _checkInTime).toUtc().toIso8601String();
      final checkOut = _combine(endDate, _checkOutTime).toUtc().toIso8601String();

      final api = ref.read(apiServiceProvider);
      final body = {
        'placeId': _selectedPlace!.id,
        'checkIn': checkIn,
        'checkOut': checkOut,
      };

      if (_isEditing) {
        // PATCH — response body varies; we build the result from known data
        await api.dio.patch(
          '/api/trips/${widget.tripId}/accommodations/${widget.existing!.id}',
          data: body,
        );
        final result = AccommodationDto(
          id: widget.existing!.id,
          placeName: _selectedPlace!.name,
          address: _selectedPlace!.address,
          checkIn: _combine(startDate, _checkInTime),
          checkOut: _combine(endDate, _checkOutTime),
        );
        if (!mounted) return;
        widget.onSaved?.call(result);
      } else {
        final resp = await api.dio.post(
          '/api/trips/${widget.tripId}/accommodations',
          data: body,
        );
        // Safely parse response regardless of wrapping
        final dynamic raw = resp.data;
        final Map<String, dynamic> jsonData = raw is Map<String, dynamic>
            ? (raw['data'] as Map<String, dynamic>? ?? raw)
            : <String, dynamic>{};
        final result = jsonData.isNotEmpty
            ? AccommodationDto.fromJson(jsonData)
            : AccommodationDto(
                id: '',
                placeName: _selectedPlace!.name,
                address: _selectedPlace!.address,
                checkIn: _combine(startDate, _checkInTime),
                checkOut: _combine(endDate, _checkOutTime),
              );
        if (!mounted) return;
        widget.onSaved?.call(result);
      }

      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to save: ${e.toString().replaceFirst('Exception: ', '')}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  // ── Build ─────────────────────────────────────────────────────────────────

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
          bottom: false,
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      _isEditing ? 'Edit Accommodation' : 'Add Accommodation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              // ── Content ───────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Address ────────────────────────────────
                      _Label('Address *'),
                      const SizedBox(height: 6),
                      _SearchField(
                        controller: _addressController,
                        hint: 'Street, hotel address...',
                        icon: Icons.search,
                        isLoading: _isSearching,
                        isConfirmed: _selectedPlace != null &&
                            _selectedPlace!.id.isNotEmpty,
                        onChanged: _onAddressChanged,
                        onFocusLost: () => Future.delayed(
                          const Duration(milliseconds: 200),
                          () {
                            if (mounted) {
                              setState(() => _showDropdown = false);
                            }
                          },
                        ),
                      ),
                      if (_showDropdown) ...[
                        const SizedBox(height: 4),
                        _SuggestionsDropdown(
                          suggestions: _suggestions,
                          onSelect: _selectSuggestion,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // ── Name ───────────────────────────────────
                      _Label('Accommodation name *'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        readOnly: _selectedPlace != null &&
                            _selectedPlace!.id.isNotEmpty,
                        decoration: InputDecoration(
                          hintText: 'Filled from address search',
                          suffixIcon: _selectedPlace != null &&
                                  _selectedPlace!.id.isNotEmpty
                              ? const Icon(Icons.check_circle,
                                  color: Color(0xFF4CAF50))
                              : const Icon(Icons.hotel_outlined,
                                  color: AppColors.textHint),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Check-in / Check-out ───────────────────
                      Text('Details',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      _TimeRow(
                        label: 'Check-in time',
                        time: _checkInTime,
                        onTap: _pickCheckInTime,
                      ),
                      const SizedBox(height: 12),
                      _TimeRow(
                        label: 'Check-out time',
                        time: _checkOutTime,
                        onTap: _pickCheckOutTime,
                      ),

                      // ── Date summary ───────────────────────────
                      Consumer(builder: (context, ref, _) {
                        final trip = ref.watch(tripsProvider).whenOrNull(
                          data: (trips) => trips
                              .where((t) => t.id == widget.tripId)
                              .firstOrNull,
                        );
                        if (trip == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 14, color: AppColors.accent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Check-in: ${_fmtDate(trip.startDate)} ${_fmtTime(_checkInTime)}'
                                    '  ·  Check-out: ${_fmtDate(trip.endDate)} ${_fmtTime(_checkOutTime)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // ── Save button ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 12, 24, MediaQuery.of(context).padding.bottom + 16),
                child: ElevatedButton(
                  onPressed: _canSubmit && !_isLoading ? _submit : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Save accommodation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
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
    return '${d.day}. ${m[d.month]}';
  }

  String _fmtTime(TimeOfDay t) {
    final h12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h12:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isLoading,
    required this.isConfirmed,
    required this.onChanged,
    required this.onFocusLost,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isLoading;
  final bool isConfirmed;
  final ValueChanged<String> onChanged;
  final VoidCallback onFocusLost;

  @override
  Widget build(BuildContext context) {
    Widget? suffix;
    if (isLoading) {
      suffix = const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      );
    } else if (isConfirmed) {
      suffix = const Icon(Icons.check_circle, color: Color(0xFF4CAF50));
    } else {
      suffix = Icon(icon, color: AppColors.textHint);
    }

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) onFocusLost();
      },
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        onChanged: onChanged,
      ),
    );
  }
}

class _SuggestionsDropdown extends StatelessWidget {
  const _SuggestionsDropdown(
      {required this.suggestions, required this.onSelect});
  final List<_PlaceSuggestion> suggestions;
  final ValueChanged<_PlaceSuggestion> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: suggestions
            .map((s) => InkWell(
                  onTap: () => onSelect(s),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(s.displayName,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow(
      {required this.label, required this.time, required this.onTap});
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  String _fmt(TimeOfDay t) {
    final h12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h12:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Text(_fmt(time),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}