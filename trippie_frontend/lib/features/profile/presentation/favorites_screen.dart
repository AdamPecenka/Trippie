// lib/features/profile/presentation/favorites_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/app/router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/profile/data/favorite_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/presentation/widgets/trip_state_badge.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final favoritesProvider = FutureProvider.autoDispose<List<FavoriteDto>>((
  ref,
) async {
  final api = ref.watch(apiServiceProvider);
  final resp = await api.dio.get('/api/favorites');
  final list = resp.data['data'] as List;
  return list
      .map((j) => FavoriteDto.fromJson(j as Map<String, dynamic>))
      .toList();
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);

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
              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Favorites',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Places you want to visit',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showAddSheet(context, ref),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Favorite'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Content ────────────────────────────────────────────
              Expanded(
                child: favAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _ErrorState(
                    onRetry: () => ref.invalidate(favoritesProvider),
                  ),
                  data: (favorites) => favorites.isEmpty
                      ? _EmptyState(onAdd: () => _showAddSheet(context, ref))
                      : _GroupedList(
                          favorites: favorites,
                          onDelete: (fav) => _deleteFavorite(context, ref, fav),
                          onTap: (fav) => _showDetail(context, ref, fav),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AddFavoriteSheet(onAdded: () => ref.invalidate(favoritesProvider)),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, FavoriteDto fav) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        favorite: fav,
        onDelete: () {
          Navigator.of(context, rootNavigator: true).pop();
          _deleteFavorite(context, ref, fav);
        },
        onAddToTrip: () {
          Navigator.of(context, rootNavigator: true).pop();
          _showTripPicker(context, ref, fav);
        },
      ),
    );
  }

  void _showTripPicker(BuildContext context, WidgetRef ref, FavoriteDto fav) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TripPickerSheet(
        favorite: fav,
        onPicked: (tripId) {
          // close all bottom sheets with a single go_router navigation
          context.push(
            AppRoutes.createActivity.replaceFirst(':tripId', tripId),
            extra: PlaceDto(
              id: fav.place.id,
              name: fav.place.name,
              address: fav.place.address,
              city: fav.place.city,
              country: fav.place.country,
              latitude: fav.place.latitude ?? 0,
              longitude: fav.place.longitude ?? 0,
              googlePlaceId: fav.place.googlePlaceId,
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteFavorite(
    BuildContext context,
    WidgetRef ref,
    FavoriteDto fav,
  ) async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.dio.delete('/api/favorites/${fav.place.id}');
      ref.invalidate(favoritesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not remove: $e')));
      }
    }
  }
}

// ─── Grouped list ─────────────────────────────────────────────────────────────

class _GroupedList extends StatelessWidget {
  const _GroupedList({
    required this.favorites,
    required this.onDelete,
    required this.onTap,
  });

  final List<FavoriteDto> favorites;
  final ValueChanged<FavoriteDto> onDelete;
  final ValueChanged<FavoriteDto> onTap;

  /// Group by city, unknowns under "Other"
  Map<String, List<FavoriteDto>> get _grouped {
    final map = <String, List<FavoriteDto>>{};
    for (final f in favorites) {
      final city = (f.place.city?.isNotEmpty == true)
          ? f.place.city!
          : (f.place.country?.isNotEmpty == true ? f.place.country! : 'Other');
      map.putIfAbsent(city, () => []).add(f);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final cities = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.of(context).padding.bottom + 80,
      ),
      itemCount: cities.length,
      itemBuilder: (_, i) {
        final city = cities[i];
        final items = grouped[city]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City header
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                city,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            // Items
            ...items.map(
              (fav) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FavoriteCard(
                  favorite: fav,
                  onTap: () => onTap(fav),
                  onDelete: () => onDelete(fav),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Favorite card ────────────────────────────────────────────────────────────

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.favorite,
    required this.onTap,
    required this.onDelete,
  });

  final FavoriteDto favorite;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final place = favorite.place;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.place_outlined,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (place.address?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        place.address!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.favorite,
                    color: Color(0xFFE57373),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Detail sheet ─────────────────────────────────────────────────────────────

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({
    required this.favorite,
    required this.onDelete,
    required this.onAddToTrip,
  });

  final FavoriteDto favorite;
  final VoidCallback onDelete;
  final VoidCallback onAddToTrip;

  @override
  Widget build(BuildContext context) {
    final place = favorite.place;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.favorite,
                  color: Color(0xFFE57373),
                  size: 22,
                ),
                tooltip: 'Remove from favorites',
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          if (place.address?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    place.address!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddToTrip,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Add to trip'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trip picker ──────────────────────────────────────────────────────────────

class _TripPickerSheet extends ConsumerWidget {
  const _TripPickerSheet({required this.favorite, required this.onPicked});

  final FavoriteDto favorite;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Choose a trip',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Adding: ${favorite.place.name}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          tripsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Text('Failed to load trips'),
            data: (trips) {
              final active = trips
                  .where(
                    (t) =>
                        t.status.name.toUpperCase() == 'PLANNING' ||
                        t.status.name.toUpperCase() == 'ACTIVE',
                  )
                  .toList();

              if (active.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No active trips found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: active.map((trip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onPicked(trip.id);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_fmt(trip.startDate)} – ${_fmt(trip.endDate)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TripStateBadge(status: trip.status),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
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
      'Dec',
    ];
    return '${d.day}. ${m[d.month]} ${d.year}';
  }
}

// ─── Add Favorite sheet ───────────────────────────────────────────────────────
// Full-height draggable sheet with real places search

class _AddFavoriteSheet extends ConsumerStatefulWidget {
  const _AddFavoriteSheet({required this.onAdded});
  final VoidCallback onAdded;

  @override
  ConsumerState<_AddFavoriteSheet> createState() => _AddFavoriteSheetState();
}

class _AddFavoriteSheetState extends ConsumerState<_AddFavoriteSheet> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<_Suggestion> _suggestions = [];
  bool _searching = false;
  String? _errorMsg;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    setState(() => _errorMsg = null);
    if (q.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final api = ref.read(apiServiceProvider);
        final resp = await api.dio.get(
          '/api/places/search',
          queryParameters: {'query': q.trim()},
        );
        final data = resp.data['data'];
        final list = data is List ? data : [];
        if (mounted) {
          setState(() {
            _suggestions = list
                .map(
                  (j) => _Suggestion(
                    googlePlaceId: j['googlePlaceId'] as String,
                    displayName: j['displayName'] as String,
                  ),
                )
                .toList();
            _searching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMsg = e.toString().replaceFirst('Exception: ', '');
            _searching = false;
          });
        }
      }
    });
  }

  Future<void> _addFavorite(_Suggestion s) async {
    // Dismiss keyboard and clear
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _errorMsg = null;
    });

    try {
      final api = ref.read(apiServiceProvider);

      // 1. Resolve Google Place → internal UUID
      final resolveResp = await api.dio.post(
        '/api/places/resolve',
        data: {'googlePlaceId': s.googlePlaceId},
      );
      final placeId = resolveResp.data['data']['id'] as String;

      // 2. Save as favorite
      await api.dio.post('/api/favorites', data: {'placeId': placeId});

      widget.onAdded();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceFirst('Exception: ', '');
          _searching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add Favorite',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search for a place...',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.accent,
                                ),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.search,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _suggestions = [];
                                _errorMsg = null;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: _onSearch,
                ),
              ),

              // Error
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMsg!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Results or hint
              Expanded(
                child: _suggestions.isEmpty && !_searching
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔍', style: TextStyle(fontSize: 36)),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Start typing to search places'
                                  : 'No results found',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          bottomInset + bottomPad + 16,
                        ),
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 46,
                          color: Color(0xFFF0F0F0),
                        ),
                        itemBuilder: (_, i) {
                          final s = _suggestions[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.accent,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              s.displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppColors.accent,
                                size: 18,
                              ),
                            ),
                            onTap: () => _addFavorite(s),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Empty / Error states ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              'Your wishlist is empty',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Save places you dream about visiting and add them to your trips when you\'re ready to go.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Save your first place'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Couldn\'t load favorites',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Local suggestion model ───────────────────────────────────────────────────

class _Suggestion {
  const _Suggestion({required this.googlePlaceId, required this.displayName});
  final String googlePlaceId;
  final String displayName;
}
