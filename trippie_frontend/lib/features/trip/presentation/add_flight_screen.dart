import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/flight_dto.dart';
import 'package:trippie_frontend/features/trip/data/flight_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';

class AddFlightScreen extends ConsumerStatefulWidget {
  const AddFlightScreen({
    super.key,
    required this.tripId,
    this.existing,
    this.outboundFlight,
  });

  final String tripId;
  final FlightDto? existing;
  final FlightDto? outboundFlight;

  @override
  ConsumerState<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends ConsumerState<AddFlightScreen> {
  final _flightNumberController = TextEditingController();

  String _direction = 'OUTBOUND';
  AirportDto? _departure;
  AirportDto? _arrival;
  DateTime? _departureTime;
  DateTime? _arrivalTime;

  List<AirportDto> _departureSuggestions = [];
  List<AirportDto> _arrivalSuggestions = [];
  bool _departureLoading = false;
  bool _arrivalLoading = false;
  bool _submitting = false;
  String? _error;

  Timer? _departureDebounce;
  Timer? _arrivalDebounce;

  bool get _isEditing => widget.existing != null;

  bool get _canSubmit =>
      _departure != null && _arrival != null && !_submitting && !_isTimeTravelError;

  bool get _isTimeTravelError =>
      _departureTime != null &&
      _arrivalTime != null &&
      _arrivalTime!.isBefore(_departureTime!);

  Duration? get _flightDuration {
    if (_departureTime == null || _arrivalTime == null) return null;
    final d = _arrivalTime!.difference(_departureTime!);
    return d.isNegative ? null : d;
  }

  DateTime get _tripStart =>
      ref.read(tripsProvider).whenOrNull(
        data: (trips) =>
            trips.where((t) => t.id == widget.tripId).firstOrNull?.startDate,
      ) ??
      DateTime.now();

  DateTime get _tripEnd =>
      ref.read(tripsProvider).whenOrNull(
        data: (trips) =>
            trips.where((t) => t.id == widget.tripId).firstOrNull?.endDate,
      ) ??
      DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    if (_isEditing) {
      final e = widget.existing!;
      _direction = e.travelDirection.toUpperCase();
      _flightNumberController.text = e.flightNumber ?? '';
      _departureTime = e.departureTime;
      _arrivalTime = e.arrivalTime;
      _departure = e.departure;
      _arrival = e.arrival;
    } else if (widget.outboundFlight != null) {
      final ob = widget.outboundFlight!;
      _direction = 'RETURN';
      _departure = ob.arrival;
      _arrival = ob.departure;
    }
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    _departureDebounce?.cancel();
    _arrivalDebounce?.cancel();
    super.dispose();
  }

  void _searchDeparture(String query) {
    _departureDebounce?.cancel();
    if (query.length < 2) {
      setState(() => _departureSuggestions = []);
      return;
    }
    _departureDebounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _departureLoading = true);
      try {
        final results =
            await ref.read(flightRepositoryProvider).searchAirports(query);
        setState(() => _departureSuggestions = results);
      } catch (_) {
        setState(() => _departureSuggestions = []);
      } finally {
        setState(() => _departureLoading = false);
      }
    });
  }

  void _searchArrival(String query) {
    _arrivalDebounce?.cancel();
    if (query.length < 2) {
      setState(() => _arrivalSuggestions = []);
      return;
    }
    _arrivalDebounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _arrivalLoading = true);
      try {
        final results =
            await ref.read(flightRepositoryProvider).searchAirports(query);
        setState(() => _arrivalSuggestions = results);
      } catch (_) {
        setState(() => _arrivalSuggestions = []);
      } finally {
        setState(() => _arrivalLoading = false);
      }
    });
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final tripStart = _tripStart;
    final tripEnd = _tripEnd;

    var selected = initial ?? tripStart;
    if (selected.isBefore(tripStart)) selected = tripStart;
    if (selected.isAfter(tripEnd)) selected = tripEnd;

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: 360,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text('Select date & time',
                  style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${_fmtDate(tripStart)} – ${_fmtDate(tripEnd)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.accent),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: selected,
                  minimumDate: tripStart,
                  maximumDate: tripEnd,
                  use24hFormat: true,
                  onDateTimeChanged: (dt) => selected = dt,
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
    return selected;
  }

  String _fmtDate(DateTime d) {
    const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month]} ${d.year}';
  }

  Future<void> _submit() async {
    if (_departure == null || _arrival == null) return;
    setState(() { _submitting = true; _error = null; });

    try {
      final body = {
        'TravelDirection': _direction,
        'DepartureAirportId': _departure!.id,
        'ArrivalAirportId': _arrival!.id,
        if (_flightNumberController.text.trim().isNotEmpty)
          'FlightNumber': _flightNumberController.text.trim(),
        if (_departureTime != null)
          'DepartureTime': _departureTime!.toUtc().toIso8601String(),
        if (_arrivalTime != null)
          'ArrivalTime': _arrivalTime!.toUtc().toIso8601String(),
      };

      if (_isEditing) {
        await ref
            .read(flightRepositoryProvider)
            .patchFlight(widget.tripId, widget.existing!.id, body);
      } else {
        await ref
            .read(flightRepositoryProvider)
            .createFlight(widget.tripId, body);
      }

      ref.invalidate(tripFlightsProvider(widget.tripId));
      if (mounted) context.pop();
    } on Exception catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripsProvider).whenOrNull(
      data: (trips) => trips.where((t) => t.id == widget.tripId).firstOrNull,
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
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  children: [
                    Text(
                      _isEditing ? 'Edit Flight' : 'Add Flight',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (trip != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.date_range, size: 14, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            'Trip: ${_fmtDate(trip.startDate)} – ${_fmtDate(trip.endDate)}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Direction
                    Text('Direction', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DirectionTile(
                            label: 'Outbound', icon: '🛫',
                            selected: _direction == 'OUTBOUND',
                            onTap: () => setState(() => _direction = 'OUTBOUND'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DirectionTile(
                            label: 'Return', icon: '🛬',
                            selected: _direction == 'RETURN',
                            onTap: () => setState(() => _direction = 'RETURN'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Return pre-fill notice
                    if (widget.outboundFlight != null && !_isEditing && _direction == 'RETURN')
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.swap_horiz, size: 16, color: AppColors.accent),
                            const SizedBox(width: 8),
                            const Text('Airports pre-filled from outbound flight.',
                                style: TextStyle(fontSize: 12, color: AppColors.accent)),
                          ],
                        ),
                      ),

                    // From
                    Text('From', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_departure == null) ...[
                      _AirportSearchField(
                        hint: 'Search departure airport...',
                        loading: _departureLoading,
                        onChanged: _searchDeparture,
                      ),
                      if (_departureSuggestions.isNotEmpty)
                        _AirportSuggestions(
                          suggestions: _departureSuggestions,
                          onTap: (a) => setState(() {
                            _departure = a;
                            _departureSuggestions = [];
                          }),
                        ),
                    ] else
                      _AirportChip(
                        airport: _departure!,
                        onClear: () => setState(() => _departure = null),
                      ),
                    const SizedBox(height: 20),

                    // To
                    Text('To', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_arrival == null) ...[
                      _AirportSearchField(
                        hint: 'Search arrival airport...',
                        loading: _arrivalLoading,
                        onChanged: _searchArrival,
                      ),
                      if (_arrivalSuggestions.isNotEmpty)
                        _AirportSuggestions(
                          suggestions: _arrivalSuggestions,
                          onTap: (a) => setState(() {
                            _arrival = a;
                            _arrivalSuggestions = [];
                          }),
                        ),
                    ] else
                      _AirportChip(
                        airport: _arrival!,
                        onClear: () => setState(() => _arrival = null),
                      ),
                    const SizedBox(height: 20),

                    // Flight number
                    Text('Flight number (opt.)', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _flightNumberController,
                      decoration: InputDecoration(
                        hintText: 'e.g. FR 1819',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date & time
                    Text('Date & time (opt.)', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DateTimeTile(
                            label: 'Departure',
                            value: _departureTime,
                            onTap: () async {
                              final dt = await _pickDateTime(_departureTime);
                              if (dt != null) setState(() => _departureTime = dt);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateTimeTile(
                            label: 'Arrival',
                            value: _arrivalTime,
                            onTap: () async {
                              final dt = await _pickDateTime(_arrivalTime);
                              if (dt != null) setState(() => _arrivalTime = dt);
                            },
                          ),
                        ),
                      ],
                    ),

                    if (_isTimeTravelError) ...[
                      const SizedBox(height: 16),
                      const _TimeTravelBadge(),
                    ] else if (_flightDuration != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.flight, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            _formatDuration(_flightDuration!),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],

                    if (_error != null) ...[
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
                            Expanded(
                              child: Text(_error!,
                                  style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
                            ),
                          ],
                        ),
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
                          minimumSize: const Size(double.infinity, 56),
                          shape: const StadiumBorder(),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _isEditing ? 'Save changes' : 'Save Flight',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
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

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return 'Flight duration: ${m}m';
    if (m == 0) return 'Flight duration: ${h}h';
    return 'Flight duration: ${h}h ${m}m';
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _DirectionTile extends StatelessWidget {
  const _DirectionTile({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label, icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7B68EE).withValues(alpha: 0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF7B68EE) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected ? const Color(0xFF7B68EE) : null,
                    )),
          ],
        ),
      ),
    );
  }
}

class _AirportSearchField extends StatelessWidget {
  const _AirportSearchField({required this.hint, required this.loading, required this.onChanged});
  final String hint;
  final bool loading;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: loading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : null,
      ),
    );
  }
}

class _AirportSuggestions extends StatelessWidget {
  const _AirportSuggestions({required this.suggestions, required this.onTap});
  final List<AirportDto> suggestions;
  final ValueChanged<AirportDto> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Column(
        children: suggestions.map((a) => ListTile(
          dense: true,
          leading: const Icon(Icons.flight_takeoff, size: 18),
          title: Text(a.displayName, style: Theme.of(context).textTheme.bodyMedium),
          subtitle: Text('${a.name}, ${a.country}', style: Theme.of(context).textTheme.bodySmall),
          onTap: () => onTap(a),
        )).toList(),
      ),
    );
  }
}

class _AirportChip extends StatelessWidget {
  const _AirportChip({required this.airport, required this.onClear});
  final AirportDto airport;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.flight_takeoff, color: Color(0xFF7B68EE), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(airport.displayName, style: Theme.of(context).textTheme.titleSmall),
                  Text('${airport.name}, ${airport.country}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
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

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({required this.label, required this.value, required this.onTap});
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  String _format(DateTime dt) {
    const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day}. ${months[dt.month]}\n${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null ? AppColors.accent.withValues(alpha: 0.4) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: value != null
                  ? Text(_format(value!), style: Theme.of(context).textTheme.bodySmall)
                  : Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ),
            Icon(Icons.access_time, size: 16,
                color: value != null ? AppColors.accent : AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TimeTravelBadge extends StatelessWidget {
  const _TimeTravelBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('⏳', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cestovanie v čase! ✈️',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700, color: const Color(0xFFE53935))),
                Text('Arrival is before departure. Please check the dates.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12, color: const Color(0xFFE53935))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}