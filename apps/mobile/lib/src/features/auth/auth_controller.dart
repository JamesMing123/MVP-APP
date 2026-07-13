import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/api_client.dart';
import '../../shared/token_storage.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(
    repository: ref.watch(authRepositoryProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  )..bootstrap();
});

class AuthState {
  const AuthState({
    this.isLoading = true,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final AuthUser? user;
  final String? error;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    AuthUser? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository repository,
    required TokenStorage tokenStorage,
  })  : _repository = repository,
        _tokenStorage = tokenStorage;

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  AuthState state = const AuthState();

  Future<void> bootstrap() async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      state = const AuthState(isLoading: false);
      notifyListeners();
      return;
    }

    try {
      final user = await _repository.me();
      state = AuthState(isLoading: false, isAuthenticated: true, user: user);
    } catch (_) {
      await _tokenStorage.clearToken();
      state = const AuthState(isLoading: false);
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    notifyListeners();
    try {
      final token = await _repository.login(email: email, password: password);
      await _tokenStorage.saveToken(token);
      final user = await _repository.me();
      state = AuthState(isLoading: false, isAuthenticated: true, user: user);
    } catch (error) {
      state = AuthState(isLoading: false, error: _readableError(error));
    }
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String username,
    required String nickname,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    notifyListeners();
    try {
      final token = await _repository.register(
        email: email,
        username: username,
        nickname: nickname,
        password: password,
      );
      await _tokenStorage.saveToken(token);
      final user = await _repository.me();
      state = AuthState(isLoading: false, isAuthenticated: true, user: user);
    } catch (error) {
      state = AuthState(isLoading: false, error: _readableError(error));
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    state = const AuthState(isLoading: false);
    notifyListeners();
  }

  String _readableError(Object error) {
    final text = error.toString();
    if (text.contains('401')) {
      return '邮箱或密码不正确';
    }
    if (text.contains('409')) {
      return '邮箱或用户名已存在';
    }
    return '请求失败，请稍后再试';
  }
}
