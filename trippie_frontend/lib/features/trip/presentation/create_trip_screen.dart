import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  PlaceDto? _selectedPlace;
  DateTime? _startDate;
  DateTime? _endDate;

  List<PlaceSuggestionDto> _suggestions = [];
  bool _searchLoading = false;
  bool _submitting = false;
  String? _error;
  Timer? _debounce;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _selectedPlace != null &&
      _startDate != null &&
      _endDate != null &&
      !_submitting;

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

  // ── Date range picker ─────────────────────────────────────────────

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: const Color(0xFF7B68EE),
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearDates() => setState(() {
        _startDate = null;
        _endDate = null;
      });

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day}. ${months[d.month]}';
  }

  // ── Submit ────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_selectedPlace == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final tripId = await ref.read(tripRepositoryProvider).createTrip(
        name: _nameController.text.trim(),
        destinationPlaceId: _selectedPlace!.id,
        transportType: 'FLIGHT',
        startDate: _startDate!,  // non-nullable
        endDate: _endDate!,
      );

      await ref.read(tripsProvider.notifier).refresh();

      if (mounted) context.go('/home/trip/$tripId/hub');
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
                    Text('New Trip',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Just the essentials. Add details later.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 32),

                    // ── Trip name ─────────────────────────────────
                    Text('Trip name *',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration('e.g. Barcelona 2026'),
                    ),
                    const SizedBox(height: 20),

                    // ── Destination ───────────────────────────────
                    Text('Destination *',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_selectedPlace == null) ...[
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: _inputDecoration(
                          'Where do you wanna go?',
                          suffix: _searchLoading
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
                                      dense: true,
                                      leading: const Icon(Icons.place_outlined),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_selectedPlace!.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    if (_selectedPlace!.country != null)
                                      Text(
                                        _selectedPlace!.country!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppColors.textSecondary),
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
                    const SizedBox(height: 20),

                    // ── Dates ─────────────────────────────────────
                    Text('Dates *',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _startDate != null && _endDate != null
                                  ? Text(
                                      '${_formatDate(_startDate!)} – ${_formatDate(_endDate!)} ${_endDate!.year}',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    )
                                  : Text(
                                      'Select travel dates',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: AppColors.textSecondary),
                                    ),
                            ),
                            if (_startDate != null)
                              GestureDetector(
                                onTap: _clearDates,
                                child: Icon(Icons.close,
                                    size: 18, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                size: 16, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade800)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // "That's all" hint
                    if (_canSubmit)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check,
                                    size: 14, color: Colors.green.shade600),
                                const SizedBox(width: 6),
                                Text(
                                  "That's all you need to start!",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

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
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Create Trip →',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
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

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }
}