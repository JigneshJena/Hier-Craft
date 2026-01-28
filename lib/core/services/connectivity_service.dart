import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// Service for monitoring network connectivity
/// Provides reactive connectivity status and online/offline detection
class ConnectivityService extends GetxService {
  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();
  
  final RxBool isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Initialize connectivity service
  Future<ConnectivityService> init() async {
    try {
      _logger.i('Initializing Connectivity Service...');
      
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          _logger.e('Connectivity listener error: $error');
        },
      );

      _logger.i('Connectivity Service initialized');
    } catch (e) {
      _logger.e('Error initializing Connectivity Service: $e');
      // Default to online if we can't detect
      isOnline.value = true;
    }
    
    return this;
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if any result indicates connectivity
    final bool hasConnection = results.any((result) => 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet
    );

    final bool wasOnline = isOnline.value;
    isOnline.value = hasConnection;

    if (wasOnline != hasConnection) {
      _logger.i('Connection status changed: ${hasConnection ? "ONLINE" : "OFFLINE"}');
    }
  }

  /// Check if currently online
  bool get isConnected => isOnline.value;

  /// Check if currently offline
  bool get isOffline => !isOnline.value;

  /// Stream of connectivity status
  Stream<bool> get connectivityStream => isOnline.stream;

  /// Force check current connectivity
  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return isOnline.value;
    } catch (e) {
      _logger.e('Error checking connection: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
