import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/map/data/place_suggestion_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';

part 'place_repository.g.dart';

@riverpod
PlaceRepository placeRepository(Ref ref) {
  return PlaceRepository(apiService: ref.watch(apiServiceProvider));
}

class PlaceRepository {
  const PlaceRepository({required this.apiService});

  final ApiService apiService;

  Future<List<PlaceSuggestionDto>> search(String query, {double? lat, double? lng}) async {
    try {
      final queryParams = <String, dynamic>{'query': query};
      if (lat != null) queryParams['latitude'] = lat;
      if (lng != null) queryParams['longitude'] = lng;

      final response = await apiService.dio.get(
        '/api/places/search',
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => PlaceSuggestionDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error']?['message'] ?? 'Search failed');
    }
  }

  Future<PlaceDto> resolve(String googlePlaceId) async {
    try {
      final response = await apiService.dio.post(
        '/api/places/resolve',
        data: {'googlePlaceId': googlePlaceId},
      );
      final data = response.data as Map<String, dynamic>;
      return PlaceDto.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error']?['message'] ?? 'Resolve failed');
    }
  }
}