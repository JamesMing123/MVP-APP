import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({String baseUrl = 'http://localhost:8000/api/v1'})
      : dio = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio dio;

  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
