import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/map/data/place_suggestion_dto.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';
import 'package:uuid/uuid.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/shared/providers/connectivity_provider.dart';
import 'package:trippie_frontend/shared/services/offline_queue_service.dart';

part 'activity_repository.g.dart';

// ── DTOs ─────────────────────────────────────────────────────────

class CreateActivityRequestDto {
  const CreateActivityRequestDto({
    this.name,
    this.placeId,
    this.activityDate,
    this.startTime,
    this.endTime,
    this.notes,
  });

  final String? name;
  final String? placeId;
  final String? activityDate;
  final String? startTime;
  final String? endTime;
  final String? notes;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (placeId != null) 'placeId': placeId,
    if (activityDate != null) 'activityDate': activityDate,
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
    if (notes != null) 'notes': notes,
  };
}

// ── Offline queued exception (create only) ────────────────────────

class OfflineQueuedException implements Exception {
  const OfflineQueuedException();
}

// ── Repository ────────────────────────────────────────────────────

@riverpod
ActivityRepository activityRepository(Ref ref) =>
    ActivityRepository(apiService: ref.watch(apiServiceProvider), ref: ref);

class ActivityRepository {
  const ActivityRepository({required this.apiService, required this.ref});

  final ApiService apiService;
  final Ref ref;

  bool get _isOnline => ref.read(isOnlineProvider);

  Future<ActivityDto> createActivity(
      String tripId, CreateActivityRequestDto dto) async {
    if (!_isOnline) {
      await OfflineQueueService().add(PendingActivity(
        localId: const Uuid().v4(),
        operation: OfflineOperation.create,
        tripId: tripId,
        name: dto.name,
        placeId: dto.placeId,
        activityDate: dto.activityDate,
        startTime: dto.startTime,
        endTime: dto.endTime,
        notes: dto.notes,
      ));
      debugPrint('[+] activity create queued offline');
      throw const OfflineQueuedException();
    }

    try {
      final response = await apiService.dio.post(
        '/api/trips/$tripId/activities',
        data: dto.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ActivityDto.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> patchActivity(
      String tripId, String activityId, CreateActivityRequestDto dto) async {
    if (!_isOnline) {
      await OfflineQueueService().add(PendingActivity(
        localId: const Uuid().v4(),
        operation: OfflineOperation.update,
        tripId: tripId,
        activityId: activityId,
        name: dto.name,
        placeId: dto.placeId,
        activityDate: dto.activityDate,
        startTime: dto.startTime,
        endTime: dto.endTime,
        notes: dto.notes,
      ));
      debugPrint('[+] activity update queued offline');
      return;
    }

    try {
      await apiService.dio.patch(
        '/api/trips/$tripId/activities/$activityId',
        data: dto.toJson(),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteActivity(String tripId, String activityId) async {
    if (!_isOnline) {
      await OfflineQueueService().add(PendingActivity(
        localId: const Uuid().v4(),
        operation: OfflineOperation.delete,
        tripId: tripId,
        activityId: activityId,
      ));
      debugPrint('[+] activity delete queued offline');
      return;
    }

    try {
      await apiService.dio.delete(
        '/api/trips/$tripId/activities/$activityId',
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<PlaceSuggestionDto>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'query': query};
      if (latitude != null) queryParameters['latitude'] = latitude;
      if (longitude != null) queryParameters['longitude'] = longitude;

      final response = await apiService.dio.get(
        '/api/places/search',
        queryParameters: queryParameters,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => PlaceSuggestionDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<PlaceDto> resolvePlace(String googlePlaceId) async {
    try {
      final response = await apiService.dio.post(
        '/api/places/resolve',
        data: {'googlePlaceId': googlePlaceId},
      );
      final data = response.data as Map<String, dynamic>;
      return PlaceDto.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final responseData = e.response?.data;
    String? msg;
    if (responseData is Map<String, dynamic>) {
      msg = responseData['error']?['message'] as String?;
    }
    return Exception(msg ?? 'Unexpected error.');
  }
}