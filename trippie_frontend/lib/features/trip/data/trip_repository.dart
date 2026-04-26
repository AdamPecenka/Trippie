import 'package:dio/dio.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
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
