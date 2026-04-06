import 'package:dio/dio.dart';
import 'package:trippie_frontend/features/auth/data/auth_dto.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';
import 'package:trippie_frontend/core/errors/error_messages.dart';

// inside _mapDioError, replace the serverMessage extraction:

class AuthRepository {
  const AuthRepository({required this.apiService});

  final ApiService apiService;

  Future<AuthResponseDto> login(LoginRequestDto dto) async {
    try {
      final response = await apiService.dio.post(
        '/api/auth/login',
        data: dto.toJson(),
      );

      final data = response.data as Map<String, dynamic>;
      return AuthResponseDto.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<AuthResponseDto> register(RegisterRequestDto dto) async {
    try {
      final response = await apiService.dio.post(
        '/api/auth/register',
        data: dto.toJson(),
      );

      final data = response.data as Map<String, dynamic>;
      return AuthResponseDto.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<AuthResponseDto> refreshToken(String refreshToken) async {
    try {
      final response = await apiService.dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      return AuthResponseDto.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return Exception(
        'Cannot reach the server. Check your network or LAN IP in AppConfig.',
      );
    }

    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      final error = responseData['error'];
      if (error is Map<String, dynamic>) {
        final code = error['message'] as String?;
        serverMessage = code != null ? ErrorMessages.fromCode(code) : null;
      }
    }

    switch (statusCode) {
      case 400:
        return Exception(serverMessage ?? 'Invalid request.');
      case 401:
        return Exception(serverMessage ?? 'Invalid credentials.');
      case 409:
        return Exception(serverMessage ?? 'Account already exists.');
      case 500:
        return Exception(serverMessage ?? 'Server error. Try again later.');
      default:
        return Exception(serverMessage ?? 'Unexpected error ($statusCode).');
    }
  }
}
