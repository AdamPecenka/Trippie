import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/flight_dto.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';

part 'flight_repository.g.dart';

@riverpod
FlightRepository flightRepository(Ref ref) =>
    FlightRepository(apiService: ref.watch(apiServiceProvider));

@riverpod
Future<List<FlightDto>> tripFlights(Ref ref, String tripId) =>
    ref.watch(flightRepositoryProvider).getFlights(tripId);

class FlightRepository {
  const FlightRepository({required this.apiService});

  final ApiService apiService;

  Future<List<FlightDto>> getFlights(String tripId) async {
    try {
      final response =
          await apiService.dio.get('/api/trips/$tripId/flights');
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => FlightDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<FlightDto> createFlight(
      String tripId, Map<String, dynamic> dto) async {
    try {
      final response = await apiService.dio.post(
        '/api/trips/$tripId/flights',
        data: dto,
      );
      final data = response.data as Map<String, dynamic>;
      return FlightDto.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteFlight(String tripId, String flightId) async {
    try {
      await apiService.dio.delete('/api/trips/$tripId/flights/$flightId');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<AirportDto>> searchAirports(String query) async {
    try {
      final response = await apiService.dio.get(
        '/api/airports',
        queryParameters: {'search': query, 'limit': 8},
      );
      final data = response.data;
      debugPrint('🛫 airports response: $data');
      List<dynamic> list;
      if (data is Map<String, dynamic>) {
        list = (data['value'] ?? data['data'] ?? []) as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      return list
          .map((e) => AirportDto.fromJson(e as Map<String, dynamic>))
          .toList();
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