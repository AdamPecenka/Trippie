import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_dto.dart';
import 'package:trippie_frontend/features/auth/data/auth_repository.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';
import 'package:trippie_frontend/shared/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
ApiService apiService(Ref ref) {
  final api = ApiService();
  final auth = ref.watch(authServiceProvider);

  api.onGetRefreshToken = () => auth.getRefreshToken();
  api.onSaveTokens = (access, refresh) =>
      auth.saveTokens(accessToken: access, refreshToken: refresh);
  api.onClearTokens = () async {
    await auth.clearTokens();
    api.clearAuthToken();
  };

  api.setupRefreshInterceptor();
  return api;
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
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    final user = ref.watch(authProvider).when(
      data: (data) => data,
      loading: () => null,
      error: (_, __) => null,
    );
    return user?.theme == 'DARK' ? ThemeMode.dark : ThemeMode.light;
  }

  void setDark() => state = ThemeMode.dark;
  void setLight() => state = ThemeMode.light;
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

    try {
      final response = await apiSvc.dio.get('/api/user/me');
      final data = response.data as Map<String, dynamic>;
      return UserDto.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[E] Failed to fetch user on startup: $e');
      await authSvc.clearTokens();
      apiSvc.clearAuthToken();
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    final authSvc = ref.read(authServiceProvider);
    final apiSvc = ref.read(apiServiceProvider);
    final repo = ref.read(authRepositoryProvider);

    final dto = await repo.login(
      LoginRequestDto(email: email, password: password),
    );

    await authSvc.saveTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );

    apiSvc.setAuthToken(dto.accessToken);
    state = AsyncData(dto.user);
  }

  Future<void> googleLogin() async {
    final authSvc = ref.read(authServiceProvider);
    final apiSvc = ref.read(apiServiceProvider);
    final repo = ref.read(authRepositoryProvider);

    final googleSignIn = GoogleSignIn();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Failed to get ID token from Google.');
    }

    final dto = await repo.googleLogin(idToken);

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

    final dto = await repo.register(
      RegisterRequestDto(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      ),
    );

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