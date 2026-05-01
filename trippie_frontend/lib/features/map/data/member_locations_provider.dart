// lib/features/map/data/member_locations_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/map/data/member_location.dart';

part 'member_locations_provider.g.dart';

@Riverpod(keepAlive: true)
class MemberLocations extends _$MemberLocations {
  @override
  Map<String, MemberLocation> build() {
    return {};
  }

  void update({
    required String userId,
    required String firstname,
    required String lastname,
    required double latitude,
    required double longitude,
    bool isOnline = true,
  }) {
    state = {
      ...state,
      userId: MemberLocation(
        userId: userId,
        firstname: firstname,
        lastname: lastname,
        latitude: latitude,
        longitude: longitude,
        isOnline: isOnline,
      ),
    };
    print('[~] member location updated | user:$userId online:$isOnline');
  }

  void clear() {
    state = {};
    print('[-] member locations cleared');
  }

  void markOffline(String userId) {
    final existing = state[userId];
    if (existing == null) return;
    state = {
      ...state,
      userId: MemberLocation(
        userId: existing.userId,
        firstname: existing.firstname,
        lastname: existing.lastname,
        latitude: existing.latitude,
        longitude: existing.longitude,
        isOnline: false,
      ),
    };
    print('[-] member went offline | user:$userId');
  }
}
