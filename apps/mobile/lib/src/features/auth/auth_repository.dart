import '../../shared/api_client.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<String> login(
      {required String email, required String password}) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = _apiClient.unwrap<Map<String, dynamic>>(response);
    return data['access_token'] as String;
  }

  Future<String> register({
    required String email,
    required String username,
    required String nickname,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/register',
      data: {
        'email': email,
        'username': username,
        'nickname': nickname,
        'password': password,
      },
    );
    final data = _apiClient.unwrap<Map<String, dynamic>>(response);
    return data['access_token'] as String;
  }

  Future<AuthUser> me() async {
    final response = await _apiClient.dio.get('/auth/me');
    final data = _apiClient.unwrap<Map<String, dynamic>>(response);
    return AuthUser.fromJson(data);
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    required this.nickname,
    required this.role,
  });

  final int id;
  final String email;
  final String username;
  final String nickname;
  final String role;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      role: json['role'] as String,
    );
  }
}
