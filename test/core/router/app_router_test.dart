import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate_sdd/core/router/app_router.dart';
import 'package:flutter_boilerplate_sdd/core/router/route_paths.dart';
import 'package:flutter_boilerplate_sdd/core/router/router_listenable.dart';
import 'package:flutter_boilerplate_sdd/core/router/screens/not_found_screen.dart';

void main() {
  group('AppRouter', () {
    late RouterListenable listenable;
    late AppRouter appRouter;

    setUp(() {
      listenable = RouterListenable();
      appRouter = AppRouter(routerListenable: listenable);
    });

    testWidgets('renders Root page by default when unauthenticated', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter.router,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LifeHub Root'), findsOneWidget);
    });

    testWidgets('redirects to Login when accessing protected route without auth', (tester) async {
      listenable.updateAuthState(isAuthenticated: false);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter.router,
        ),
      );
      await tester.pumpAndSettle();

      appRouter.router.go(RoutePaths.dashboard);
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('redirects to Dashboard when authenticated user navigates to Login', (tester) async {
      listenable.updateAuthState(isAuthenticated: true);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter.router,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Screen'), findsOneWidget);
    });

    testWidgets('displays NotFoundScreen for invalid routes', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter.router,
        ),
      );
      await tester.pumpAndSettle();

      appRouter.router.go('/unknown-nonexistent-route');
      await tester.pumpAndSettle();

      expect(find.byType(NotFoundScreen), findsOneWidget);
      expect(find.text('404 - Page Not Found'), findsOneWidget);
    });
  });
}
