import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/map/data/member_location.dart';

class MemberBottomSheet extends StatelessWidget {
  const MemberBottomSheet({
    super.key,
    required this.member,
    required this.currentPosition,
  });

  final MemberLocation member;
  final Position? currentPosition;

  String? _formatDistance() {
    if (currentPosition == null) return null;
    final distanceMeters = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      member.latitude,
      member.longitude,
    );
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m away';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km away';
  }

  Future<void> _onNavigate() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${member.latitude},${member.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final distance = _formatDistance();

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
          // drag handle
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
                  '${member.firstname} ${member.lastname}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          Text(
            member.isOnline ? 'Live location' : 'Last known location',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 12),
          if (distance != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    distance,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}