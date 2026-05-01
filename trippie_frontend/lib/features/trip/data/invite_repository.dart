import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/invite_dto.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';

part 'invite_repository.g.dart';

@riverpod
InviteRepository inviteRepository(Ref ref) {
  return InviteRepository(apiService: ref.watch(apiServiceProvider));
}

class InviteRepository {
  const InviteRepository({required this.apiService});

  final ApiService apiService;

  Future<int> getOrCreateInviteCode(String tripId) async {
    try {
      final response = await apiService.dio.post('/api/trips/$tripId/invites');
      final data = response.data as Map<String, dynamic>;
      return data['data']['inviteCode'] as int;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?['message'] ?? 'Failed to get invite code',
      );
    }
  }

  Future<JoinTripDto> joinByCode(int inviteCode) async {
    try {
      final response = await apiService.dio.post(
        '/api/invites/$inviteCode/join',
      );
      final data = response.data as Map<String, dynamic>;
      return JoinTripDto.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?['message'] ?? 'Failed to join trip',
      );
    }
  }
}