import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../route_paths.dart';

/// Standardized 404 / Route Error screen displayed when navigating to an invalid or unknown route.
class NotFoundScreen extends StatelessWidget {
  final String? errorMessage;
  final String? attemptedPath;

  const NotFoundScreen({
    super.key,
    this.errorMessage,
    this.attemptedPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                '404 - Page Not Found',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage ??
                    (attemptedPath != null
                        ? 'The path "$attemptedPath" does not exist.'
                        : 'The requested page could not be found.'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go(RoutePaths.root),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
