import 'package:dio/dio.dart';
import 'package:trippie_frontend/features/map/data/member_last_location_dto.dart';
import 'package:trippie_frontend/features/trip/data/accommodation_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_member_dto.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';

class TripRepository {
  const TripRepository({required this.apiService});

  final ApiService apiService;

  Future<List<TripDto>> getTrips() async {
    try {
      final response = await apiService.dio.get('/api/trips');
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => TripDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<ActivityDto>> getActivities(String tripId) async {
    try {
      final response = await apiService.dio.get(
        '/api/trips/$tripId/activities',
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => ActivityDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<TripMemberDto>> getMembers(String tripId) async {
    try {
      final response = await apiService.dio.get('/api/trips/$tripId/members');
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => TripMemberDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AccommodationDto?> getAccommodation(String tripId) async {
    try {
      final response = await apiService.dio.get(
        '/api/trips/$tripId/accommodations',
      );
      final data = response.data as Map<String, dynamic>;
      return AccommodationDto.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _mapError(e);
    }
  }

  Future<List<MemberLastLocationDto>> getLastKnownLocations(
    String tripId,
  ) async {
    try {
      final response = await apiService.dio.get(
        '/api/location/trips/$tripId/members',
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => MemberLastLocationDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<String> createTrip({
    required String name,
    required String destinationPlaceId,
    required String transportType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await apiService.dio.post(
        '/api/trips',
        data: {
          'Name': name,
          'DestinationPlaceId': destinationPlaceId,
          'TransportType': transportType,
          'StartDate': startDate.toUtc().toIso8601String(),
          'EndDate': endDate.toUtc().toIso8601String(),
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data['data']['tripId'] as String;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final responseData = e.response?.data;
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      final error = responseData['error'];
      if (error is Map<String, dynamic>) {
        serverMessage = error['message'] as String?;
      }
    }
    return Exception(serverMessage ?? 'Unexpected error.');
  }
}