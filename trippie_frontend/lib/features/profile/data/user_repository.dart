import 'package:dio/dio.dart';
import 'package:trippie_frontend/features/auth/data/auth_dto.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';
import 'dart:typed_data';

class UpdateUserRequestDto {
  const UpdateUserRequestDto({
    required this.firstname,
    required this.lastname,
    this.phoneNumber,
  });

  final String firstname;
  final String lastname;
  final String? phoneNumber;

  Map<String, dynamic> toJson() => {
    'firstname': firstname,
    'lastname': lastname,
    'phoneNumber': phoneNumber,
  };
}

class UserRepository {
  const UserRepository({required this.apiService});

  final ApiService apiService;

  Future<UserDto> getMe() async {
    try {
      final response = await apiService.dio.get('/api/user/me');
      final data = response.data as Map<String, dynamic>;
      return UserDto.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> updateMe(UpdateUserRequestDto dto) async {
    try {
      await apiService.dio.put('/api/user/me', data: dto.toJson());
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> toggleTheme() async {
    try {
      await apiService.dio.patch('/api/user/me/theme');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      await apiService.dio.put('/api/user/me/avatar', data: formData);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Uint8List?> getAvatar() async {
    try {
      final response = await apiService.dio.get(
        '/api/user/me/avatar',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data as List<int>);
    } on DioException {
      return null;
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
