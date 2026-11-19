import 'package:flutter/foundation.dart';

/// Notifier passed to GoRouter's `refreshListenable` to trigger dynamic route
/// re-evaluation when authentication or session state changes.
class RouterListenable extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  void updateAuthState({required bool isAuthenticated}) {
    if (_isAuthenticated != isAuthenticated || !_isInitialized) {
      _isAuthenticated = isAuthenticated;
      _isInitialized = true;
      notifyListeners();
    }
  }

  void markInitialized() {
    if (!_isInitialized) {
      _isInitialized = true;
      notifyListeners();
    }
  }
}
