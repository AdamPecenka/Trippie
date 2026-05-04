// lib/features/trip/data/accommodation_repository.dart
//
// ⚠️  After adding this file, run:
//     dart run build_runner build --delete-conflicting-outputs

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/accommodation_dto.dart';

part 'accommodation_repository.g.dart';

@Riverpod(keepAlive: false)
AccommodationRepository accommodationRepository(Ref ref) {
  return AccommodationRepository(
    dio: ref.watch(apiServiceProvider).dio,
  );
}

@riverpod
Future<AccommodationDto?> tripAccommodation(Ref ref, String tripId) {
  return ref
      .watch(accommodationRepositoryProvider)
      .getAccommodation(tripId);
}

class AccommodationRepository {
  AccommodationRepository({required this.dio});

  final Dio dio;

  Future<AccommodationDto?> getAccommodation(String tripId) async {
    try {
      final response = await dio.get('/trips/$tripId/accommodations');
      final data = response.data['data'];
      if (data == null) return null;
      if (data is List) {
        if (data.isEmpty) return null;
        return AccommodationDto.fromJson(data.first as Map<String, dynamic>);
      }
      return AccommodationDto.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<AccommodationDto> createAccommodation(
    String tripId,
    Map<String, dynamic> body,
  ) async {
    final response =
        await dio.post('/trips/$tripId/accommodations', data: body);
    return AccommodationDto.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<AccommodationDto> patchAccommodation(
    String tripId,
    String accommodationId,
    Map<String, dynamic> body,
  ) async {
    final response = await dio.patch(
      '/trips/$tripId/accommodations/$accommodationId',
      data: body,
    );
    return AccommodationDto.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}