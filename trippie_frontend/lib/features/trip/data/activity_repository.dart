import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';

part 'activity_repository.g.dart';

// ── DTOs ──────────────────────────────────────────────────────────

class PlaceSuggestionDto {
  const PlaceSuggestionDto({
    required this.googlePlaceId,
    required this.displayName,
  });

  final String googlePlaceId;
  final String displayName;

  factory PlaceSuggestionDto.fromJson(Map<String, dynamic> json) =>
      PlaceSuggestionDto(
        googlePlaceId: json['googlePlaceId'] as String,
        displayName: json['displayName'] as String,
      );
}

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
  final String? activityDate; // "2026-04-24"
  final String? startTime;   // "14:00:00"
  final String? endTime;     // "16:00:00"
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

// ── Repository ────────────────────────────────────────────────────

@riverpod
ActivityRepository activityRepository(Ref ref) =>
    ActivityRepository(apiService: ref.watch(apiServiceProvider));

class ActivityRepository {
  const ActivityRepository({required this.apiService});

  final ApiService apiService;

  Future<ActivityDto> createActivity(
      String tripId, CreateActivityRequestDto dto) async {
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

  Future<List<PlaceSuggestionDto>> searchPlaces(String query) async {
    try {
      final response = await apiService.dio.get(
        '/api/places/search',
        queryParameters: {'query': query},
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

  Future<void> deleteActivity(String tripId, String activityId) async {
    try {
      await apiService.dio.delete(
        '/api/trips/$tripId/activities/$activityId',
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> patchActivity(
      String tripId, String activityId, CreateActivityRequestDto dto) async {
    try {
      await apiService.dio.patch(
        '/api/trips/$tripId/activities/$activityId',
        data: dto.toJson(),
      );
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