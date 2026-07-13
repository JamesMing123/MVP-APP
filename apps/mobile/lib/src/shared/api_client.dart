import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_storage.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000/api/v1',
);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.watch(tokenStorageProvider));
});

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    String baseUrl = apiBaseUrl,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;

  T unwrap<T>(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body['code'] == 0) {
      return body['data'] as T;
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message:
          body is Map ? body['message']?.toString() : 'Unexpected API response',
    );
  }
}
