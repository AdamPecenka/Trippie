import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/map/data/place_repository.dart';
import 'package:trippie_frontend/features/map/data/place_suggestion_dto.dart';
import 'package:geolocator/geolocator.dart';

class PlaceSearchSheet extends ConsumerStatefulWidget {
  const PlaceSearchSheet({super.key, required this.currentPosition});

  final Position? currentPosition;

  @override
  ConsumerState<PlaceSearchSheet> createState() => _PlaceSearchSheetState();
}

class _PlaceSearchSheetState extends ConsumerState<PlaceSearchSheet> {
  final _controller = TextEditingController();
  List<PlaceSuggestionDto> _suggestions = [];
  bool _loading = false;
  String? _error;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await ref
          .read(placeRepositoryProvider)
          .search(
            query,
            lat: widget.currentPosition?.latitude,
            lng: widget.currentPosition?.longitude,
          );
      setState(() {
        _suggestions = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _onSuggestionTap(PlaceSuggestionDto suggestion) async {
    setState(() => _loading = true);

    try {
      final place = await ref
          .read(placeRepositoryProvider)
          .resolve(suggestion.googlePlaceId);
      if (mounted) {
        Navigator.of(context).pop(place);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardBackground
            : AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            onSubmitted: _search,
            decoration: InputDecoration(
              hintText: 'Search restaurants, attractions...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = _suggestions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textSecondary,
                    ),
                    title: Text(
                      s.displayName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    onTap: () => _onSuggestionTap(s),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
