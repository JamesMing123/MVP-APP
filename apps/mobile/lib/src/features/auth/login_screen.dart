import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider).state;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/lebron.png',
              fit: BoxFit.cover, alignment: Alignment.topCenter),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33111424),
                  Color(0xdd080a0f),
                  Color(0xff080a0f)
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Card(
                    color: const Color(0xdd111722),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('NBA Super',
                                style: TextStyle(
                                    fontSize: 34, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text(_isRegister ? '创建你的球迷账号' : '欢迎回来，继续看球'),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: '邮箱',
                                  prefixIcon: Icon(Icons.mail_outline)),
                              validator: (value) =>
                                  value != null && value.contains('@')
                                      ? null
                                      : '请输入有效邮箱',
                            ),
                            const SizedBox(height: 12),
                            if (_isRegister) ...[
                              TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                    labelText: '用户名',
                                    prefixIcon: Icon(Icons.alternate_email)),
                                validator: (value) =>
                                    value != null && value.length >= 3
                                        ? null
                                        : '用户名至少 3 个字符',
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _nicknameController,
                                decoration: const InputDecoration(
                                    labelText: '昵称',
                                    prefixIcon: Icon(Icons.person_outline)),
                                validator: (value) =>
                                    value != null && value.isNotEmpty
                                        ? null
                                        : '请输入昵称',
                              ),
                              const SizedBox(height: 12),
                            ],
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                  labelText: '密码',
                                  prefixIcon: Icon(Icons.lock_outline)),
                              validator: (value) =>
                                  value != null && value.length >= 8
                                      ? null
                                      : '密码至少 8 个字符',
                            ),
                            if (auth.error != null) ...[
                              const SizedBox(height: 12),
                              Text(auth.error!,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                            ],
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: auth.isLoading ? null : _submit,
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : Text(_isRegister ? '注册并进入' : '登录'),
                            ),
                            TextButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () => setState(
                                      () => _isRegister = !_isRegister),
                              child:
                                  Text(_isRegister ? '已有账号？去登录' : '没有账号？立即注册'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(authControllerProvider);
    if (_isRegister) {
      controller.register(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      controller.login(
          email: _emailController.text.trim(),
          password: _passwordController.text);
    }
  }
}
