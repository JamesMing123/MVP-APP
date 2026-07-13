import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/ai/ai_report_screen.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/community/community_screen.dart';
import 'features/community/create_post_screen.dart';
import 'features/community/post_detail_screen.dart';
import 'features/home/home_screen.dart';
import 'features/matches/match_detail_screen.dart';
import 'features/matches/matches_screen.dart';
import 'theme/app_theme.dart';

class NbaSuperApp extends ConsumerWidget {
  const NbaSuperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);
    final router = GoRouter(
      initialLocation: '/',
      refreshListenable: authController,
      redirect: (context, state) {
        final auth = authController.state;
        final location = state.uri.path;
        if (auth.isLoading) {
          return location == '/splash' ? null : '/splash';
        }
        if (!auth.isAuthenticated) {
          return location == '/login' ? null : '/login';
        }
        if (location == '/login' || location == '/splash') {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
            GoRoute(
                path: '/matches', builder: (_, __) => const MatchesScreen()),
            GoRoute(
                path: '/community',
                builder: (_, __) => const CommunityScreen()),
            GoRoute(path: '/ai', builder: (_, __) => const AiReportScreen()),
          ],
        ),
        GoRoute(
            path: '/community/new',
            builder: (_, __) => const CreatePostScreen()),
        GoRoute(
          path: '/community/posts/:id',
          builder: (_, state) =>
              PostDetailScreen(postId: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: '/matches/:id',
          builder: (_, state) =>
              MatchDetailScreen(matchId: state.pathParameters['id']!),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'NBA Super',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = switch (location) {
      '/matches' => 1,
      '/community' => 2,
      '/ai' => 3,
      _ => 0,
    };

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          switch (value) {
            case 0:
              context.go('/');
            case 1:
              context.go('/matches');
            case 2:
              context.go('/community');
            case 3:
              context.go('/ai');
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '首页'),
          NavigationDestination(
              icon: Icon(Icons.sports_basketball_outlined),
              selectedIcon: Icon(Icons.sports_basketball),
              label: '比赛'),
          NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum),
              label: '社区'),
          NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'AI'),
        ],
      ),
    );
  }
}
