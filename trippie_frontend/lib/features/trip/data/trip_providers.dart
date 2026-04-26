import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_repository.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';

part 'trip_providers.g.dart';

@Riverpod(keepAlive: true)
TripRepository tripRepository(Ref ref) {
  return TripRepository(apiService: ref.watch(apiServiceProvider));
}

@riverpod
Future<List<ActivityDto>> tripActivities(Ref ref, String tripId) async {
  return ref.watch(tripRepositoryProvider).getActivities(tripId);
}

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