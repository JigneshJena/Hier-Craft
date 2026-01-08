import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../data/models/ai_provider_model.dart';

/// Service for managing Firebase Remote Config
/// Handles fetching API keys and configuration from Firebase
class RemoteConfigService extends GetxService {
  final Logger _logger = Logger();
  late FirebaseRemoteConfig _remoteConfig;
  final RxBool isInitialized = false.obs;

  // Public getter for direct access
  FirebaseRemoteConfig get remoteConfig => _remoteConfig;

  // Default values - these will be overridden by Firebase Remote Config
  final Map<String, dynamic> _defaults = {
    'ai_providers_config': '[]', // JSON array of AIProviderConfig
    'api_provider': 'gemini', // Default fallback provider type
  };

  /// Initialize Remote Config service
  Future<RemoteConfigService> init() async {
    try {
      _logger.i('Initializing Remote Config...');
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set config settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero, // Fetch immediately (for testing)
        ),
      );

      // Set default values
      await _remoteConfig.setDefaults(_defaults);

      // Fetch and activate
      await fetchAndActivate();

      isInitialized.value = true;
      _logger.i('Remote Config initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Remote Config: $e');
      // Even if Remote Config fails, we fall back to defaults
      isInitialized.value = true;
    }
    return this;
  }

  /// Fetch and activate remote config values
  Future<void> fetchAndActivate() async {
    try {
      final bool updated = await _remoteConfig.fetchAndActivate();
      if (updated) {
        _logger.i('Remote Config values updated from server');
      } else {
        _logger.i('Remote Config values already up to date');
      }
    } catch (e) {
      _logger.w('Failed to fetch Remote Config, using cached/default values: $e');
    }
  }

  /// Get all configured AI providers from Remote Config
  List<AIProviderConfig> getProviders() {
    try {
      final String configJson = _remoteConfig.getString('ai_providers_config');
      if (configJson.isEmpty || configJson == '[]') {
        _logger.w('No AI providers configured in Remote Config');
        return [];
      }

      final List<dynamic> decoded = jsonDecode(configJson);
      return decoded.map((item) => AIProviderConfig.fromJson(item)).toList();
    } catch (e) {
      _logger.e('Error parsing ai_providers_config: $e');
      return [];
    }
  }

  /// Get active providers only
  List<AIProviderConfig> getActiveProviders() {
    return getProviders().where((p) => p.isActive).toList();
  }

  /// Get a specific provider by ID or the first active one of a specific type
  AIProviderConfig? getProvider({String? id, String? type}) {
    final providers = getActiveProviders();
    if (id != null) {
      return providers.firstWhereOrNull((p) => p.id == id);
    }
    if (type != null) {
      return providers.firstWhereOrNull((p) => p.provider.toLowerCase() == type.toLowerCase());
    }
    return providers.isNotEmpty ? providers.first : null;
  }

  /// Legacy compatibility: Get API key (not recommended, use getProvider instead)
  String getApiKey(String difficulty, {String? provider}) {
    final config = getProvider(type: provider);
    if (config != null) {
      _logger.d('SUCCESS: Using ${config.id} from dynamic config (Ends with: ...${config.apiKey.substring(config.apiKey.length - 4)})');
      return config.apiKey;
    }
    _logger.w('WARNING: No active provider found for $provider');
    return '';
  }

  /// Get the configured AI provider (gemini, openai, deepseek)
  String getApiProvider() {
    return _remoteConfig.getString('api_provider');
  }

  /// Force refresh remote config (useful for testing)
  Future<void> forceRefresh() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // Allow immediate fetch
      ),
    );
    await fetchAndActivate();
  }

  /// Get all current values (for debugging)
  Map<String, String> getAllKeys() {
    final providers = getActiveProviders();
    return {
      for (var p in providers) p.id: p.apiKey,
      'provider': getApiProvider(),
    };
  }
}
