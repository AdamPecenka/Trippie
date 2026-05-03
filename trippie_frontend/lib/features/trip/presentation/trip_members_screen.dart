import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_member_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';

part 'trip_members_screen.g.dart';

@riverpod
Future<Uint8List?> memberAvatar(Ref ref, String userId) async {
  try {
    final dio = ref.read(apiServiceProvider).dio;
    final response = await dio.get(
      '/api/user/$userId/avatar',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  } catch (_) {
    return null;
  }
}

class TripMembersScreen extends ConsumerWidget {
  const TripMembersScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final tripsAsync = ref.watch(tripsProvider);

    // Check if this trip is active
    final isActiveTrip =
        tripsAsync.whenOrNull(
          data: (trips) {
            final thisTrip = trips.where((t) => t.id == tripId).firstOrNull;
            return thisTrip?.status == TripStatus.active;
          },
        ) ??
        false;

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
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/home/trip/$tripId/invite'),
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: const Text('Invite'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(
                  'Members',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Expanded(
                child: membersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (members) {
                    final manager = members
                        .where((m) => m.tripRole == 'TRIP_MANAGER')
                        .toList();
                    final rest = members
                        .where((m) => m.tripRole != 'TRIP_MANAGER')
                        .toList();

                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        0,
                        24,
                        MediaQuery.of(context).padding.bottom + 24,
                      ),
                      children: [
                        if (manager.isNotEmpty) ...[
                          _SectionLabel('Trip Manager'),
                          const SizedBox(height: 8),
                          ...manager.map(
                            (m) => _MemberTile(
                              member: m,
                              tripId: tripId,
                              onTap: isActiveTrip
                                  ? () => context.go(
                                      '/home/trip/$tripId/map?memberId=${m.userId}',
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (rest.isNotEmpty) ...[
                          _SectionLabel('Members'),
                          const SizedBox(height: 8),
                          ...rest.map(
                            (m) => _MemberTile(
                              member: m,
                              tripId: tripId,
                              onTap: isActiveTrip
                                  ? () => context.go(
                                      '/home/trip/$tripId/map?memberId=${m.userId}',
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({
    required this.member,
    required this.tripId,
    required this.onTap,
  });

  final TripMemberDto member;
  final String tripId;
  final VoidCallback? onTap;

  String get _initials {
    final f = member.firstname.isNotEmpty ? member.firstname[0] : '';
    final l = member.lastname.isNotEmpty ? member.lastname[0] : '';
    return '$f$l'.toUpperCase();
  }

  Widget _initialsWidget() => Container(
    width: 44,
    height: 44,
    color: const Color(0xFF7B68EE).withValues(alpha: 0.15),
    child: Center(
      child: Text(
        _initials,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7B68EE),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isManager = member.tripRole == 'TRIP_MANAGER';
    final avatarAsync = ref.watch(memberAvatarProvider(member.userId));
    final isClickable = onTap != null;

    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isClickable
              ? Theme.of(context).cardColor
              : Theme.of(context).cardColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // avatar
            ClipOval(
              child: avatarAsync.when(
                loading: () => _initialsWidget(),
                error: (_, __) => _initialsWidget(),
                data: (bytes) => bytes != null
                    ? Image.memory(
                        bytes,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      )
                    : _initialsWidget(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${member.firstname} ${member.lastname}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    member.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isManager)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B68EE).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Manager',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF7B68EE),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
