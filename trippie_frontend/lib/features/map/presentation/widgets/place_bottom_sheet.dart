import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/profile/presentation/favorites_screen.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';

class PlaceBottomSheet extends ConsumerStatefulWidget {
  const PlaceBottomSheet({super.key, required this.place});

  final PlaceDto place;

  @override
  ConsumerState<PlaceBottomSheet> createState() => _PlaceBottomSheetState();
}

class _PlaceBottomSheetState extends ConsumerState<PlaceBottomSheet> {
  bool _isFavorite = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      final api = ref.read(apiServiceProvider);
      final resp = await api.dio.get('/api/favorites');
      final list = resp.data['data'] as List;
      final isFav = list.any((f) => f['place']['id'] == widget.place.id);
      if (mounted) setState(() => _isFavorite = isFav);
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final api = ref.read(apiServiceProvider);
      if (_isFavorite) {
        await api.dio.delete('/api/favorites/${widget.place.id}');
        setState(() => _isFavorite = false);
        debugPrint('[-] removed from favorites: ${widget.place.name}');
      } else {
        await api.dio.post('/api/favorites', data: {'placeId': widget.place.id});
        setState(() => _isFavorite = true);
        debugPrint('[+] added to favorites: ${widget.place.name}');
      }
      ref.invalidate(favoritesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onNavigate() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.place.latitude},${widget.place.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.place.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.redAccent : null,
                      ),
                    ),
            ],
          ),
          if (widget.place.city != null || widget.place.country != null)
            Text(
              [widget.place.city, widget.place.country]
                  .where((s) => s != null)
                  .join(', '),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          const SizedBox(height: 12),
          if (widget.place.address != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.place.address!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onNavigate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34A853),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Navigate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}