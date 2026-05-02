import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
// import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/accommodation_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_member_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_repository.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';

part 'trip_providers.g.dart';

// ---------------------------------------------------------------------------
// Repository — jeden, keepAlive
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
TripRepository tripRepository(Ref ref) {
  return TripRepository(apiService: ref.watch(apiServiceProvider));
}

// ---------------------------------------------------------------------------
// Všetky tripy — keepAlive, s refresh()
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
class TripsNotifier extends _$TripsNotifier {
  @override
  Future<List<TripDto>> build() async {
    return ref.watch(tripRepositoryProvider).getTrips();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRepositoryProvider).getTrips(),
    );
  }
}

// ---------------------------------------------------------------------------
// Derived: len ACTIVE tripy
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
List<TripDto> activeTrips(Ref ref) {
  return ref.watch(tripsProvider).maybeWhen(
    data: (trips) => trips.where((t) => t.status == TripStatus.active).toList(),
    orElse: () => [],
  );
}

// ---------------------------------------------------------------------------
// Active trip data — keepAlive
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
Future<List<TripMemberDto>> activeTripMembers(Ref ref, String tripId) async {
  return ref.watch(tripRepositoryProvider).getMembers(tripId);
}

@Riverpod(keepAlive: true)
Future<List<ActivityDto>> activeTripActivities(Ref ref, String tripId) async {
  return ref.watch(tripRepositoryProvider).getActivities(tripId);
}

@Riverpod(keepAlive: true)
Future<AccommodationDto?> activeTripAccommodation(Ref ref, String tripId) async {
  return ref.watch(tripRepositoryProvider).getAccommodation(tripId);
}

// ---------------------------------------------------------------------------
// On-demand (non-active trips) — auto-dispose
// ---------------------------------------------------------------------------
@riverpod
Future<List<ActivityDto>> tripActivities(Ref ref, String tripId) async {
  return ref.watch(tripRepositoryProvider).getActivities(tripId);
}

@riverpod
Future<List<TripMemberDto>> tripMembers(Ref ref, String tripId) async {
  return ref.watch(tripRepositoryProvider).getMembers(tripId);
}

@riverpod
Future<AccommodationDto?> tripAccommodation(Ref ref, String tripId) async {
  return ref.watch(tripRepositoryProvider).getAccommodation(tripId);
}