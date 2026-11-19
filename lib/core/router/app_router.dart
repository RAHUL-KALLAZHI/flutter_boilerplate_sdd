import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';
import 'router_listenable.dart';
import 'screens/not_found_screen.dart';

/// Central navigation configuration for LifeHub backed by [GoRouter].
class AppRouter {
  final RouterListenable routerListenable;
  final List<RouteBase> additionalRoutes;

  late final GoRouter router = _buildRouter();

  AppRouter({
    required this.routerListenable,
    this.additionalRoutes = const [],
  });

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: RoutePaths.root,
      refreshListenable: routerListenable,
      debugLogDiagnostics: false,
      errorBuilder: (context, state) => NotFoundScreen(
        errorMessage: state.error?.message,
        attemptedPath: state.uri.toString(),
      ),
      redirect: _handleRedirect,
      routes: [
        GoRoute(
          path: RoutePaths.root,
          name: RoutePaths.rootName,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('LifeHub Root')),
          ),
        ),
        GoRoute(
          path: RoutePaths.login,
          name: RoutePaths.loginName,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Login Screen')),
          ),
        ),
        GoRoute(
          path: RoutePaths.dashboard,
          name: RoutePaths.dashboardName,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Dashboard Screen')),
          ),
        ),
        ...additionalRoutes,
      ],
    );
  }

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isAuth = routerListenable.isAuthenticated;
    final isGoingToLogin = state.matchedLocation == RoutePaths.login;
    final isGoingToRoot = state.matchedLocation == RoutePaths.root;

    // Protected routes requiring authentication
    final protectedRoutes = [RoutePaths.dashboard, RoutePaths.profile];
    final isProtectedRoute = protectedRoutes.contains(state.matchedLocation);

    if (!isAuth && isProtectedRoute) {
      return RoutePaths.login;
    }

    if (isAuth && (isGoingToLogin || isGoingToRoot)) {
      return RoutePaths.dashboard;
    }

    return null;
  }
}
