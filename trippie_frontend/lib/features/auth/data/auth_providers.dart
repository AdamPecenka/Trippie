import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_dto.dart';
import 'package:trippie_frontend/features/auth/data/auth_repository.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';
import 'package:trippie_frontend/shared/services/auth_service.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
ApiService apiService(Ref ref) {
  return ApiService();
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(apiService: ref.watch(apiServiceProvider));
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserDto?> build() async {
    final authSvc = ref.watch(authServiceProvider);
    final apiSvc = ref.watch(apiServiceProvider);

    final accessToken = await authSvc.getAccessToken();
    if (accessToken == null) {
      return null;
    }

    apiSvc.setAuthToken(accessToken);
    return null; // TODO: fetch /api/users/me and return UserDto
  }

  Future<void> login(String email, String password) async {
    final authSvc = ref.read(authServiceProvider);
    final apiSvc = ref.read(apiServiceProvider);
    final repo = ref.read(authRepositoryProvider);

    final dto = await repo.login(LoginRequestDto(
      email: email,
      password: password,
    ));

    await authSvc.saveTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );

    apiSvc.setAuthToken(dto.accessToken);
    state = AsyncData(dto.user);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final authSvc = ref.read(authServiceProvider);
    final apiSvc = ref.read(apiServiceProvider);
    final repo = ref.read(authRepositoryProvider);

    final dto = await repo.register(RegisterRequestDto(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    ));

    await authSvc.saveTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );

    apiSvc.setAuthToken(dto.accessToken);
    state = AsyncData(dto.user);
  }

  Future<void> logout() async {
    final authSvc = ref.read(authServiceProvider);
    final apiSvc = ref.read(apiServiceProvider);

    await authSvc.clearTokens();
    apiSvc.clearAuthToken();
    state = const AsyncData(null);
  }
}