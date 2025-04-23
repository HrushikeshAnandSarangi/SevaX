// lib/utils/connectivity_service.dart
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

abstract class ConnectivityService {
  Future<bool> get isConnected;
  Stream<bool> get onConnectionChanged;
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Additional connectivity verification
    return await _verifyConnection();
  }

  Future<bool> _verifyConnection() async {
    try {
      // Use http package for a cross-platform solution
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> get onConnectionChanged {
    return _connectivity.onConnectivityChanged.asyncMap((result) async {
      if (result == ConnectivityResult.none) return false;
      return await _verifyConnection();
    });
  }
}
