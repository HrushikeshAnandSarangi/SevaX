// lib/ui/utils/connectivity.dart
import 'package:flutter/foundation.dart';
import 'package:sevaexchange/utils/connectivity_service.dart';

class ConnectionStatusSingleton {
  static final ConnectionStatusSingleton _instance =
      ConnectionStatusSingleton._internal();
  final ConnectivityService _connectivityService = ConnectivityServiceImpl();

  factory ConnectionStatusSingleton() {
    return _instance;
  }

  ConnectionStatusSingleton._internal();

  static ConnectionStatusSingleton getInstance() => _instance;

  Future<void> initialize() async {
    if (kIsWeb) {
      // Web-specific initialization if needed
      return;
    }
    // Mobile/desktop initialization
    _connectivityService.onConnectionChanged.listen((isConnected) {
      // Handle connection changes
    });
  }

  Future<bool> checkConnection() async {
    return await _connectivityService.isConnected;
  }
}
