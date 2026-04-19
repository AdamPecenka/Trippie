import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:trippie_frontend/core/config/app_config.dart';

class ApiService {
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (log) => debugPrint('[i] $log'),
      ),
    );
  }

  late final Dio _dio;

  // Callbacks set by auth layer after initialization
  Future<String?> Function()? onGetRefreshToken;
  Future<void> Function(String access, String refresh)? onSaveTokens;
  Future<void> Function()? onClearTokens;

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  void setupRefreshInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          if (error.requestOptions.path.contains('/api/auth/refresh')) {
            await onClearTokens?.call();
            clearAuthToken();
            return handler.next(error);
          }

          final refreshToken = await onGetRefreshToken?.call();
          if (refreshToken == null) {
            await onClearTokens?.call();
            clearAuthToken();
            return handler.next(error);
          }

          try {
            final refreshResponse = await _dio.post(
              '/api/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            final data = refreshResponse.data as Map<String, dynamic>;
            final newAccessToken = data['data']['accessToken'] as String;
            final newRefreshToken = data['data']['refreshToken'] as String;

            await onSaveTokens?.call(newAccessToken, newRefreshToken);
            setAuthToken(newAccessToken);

            if (error.requestOptions.contentType?.contains('multipart') ==
                true) {
              return handler.next(error);
            }

            // Retry for non-multipart requests
            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await _dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          } on DioException {
            await onClearTokens?.call();
            clearAuthToken();
            return handler.next(error);
          }
        },
      ),
    );
  }
}
