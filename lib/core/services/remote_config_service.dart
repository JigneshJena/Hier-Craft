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

  String? _overrideId;

  /// Set a local override for the AI provider by ID (takes precedence)
  void setOverrideProvider(String? id) {
    _overrideId = id;
    _logger.i('🔄 AI Provider override set to ID: $_overrideId');
  }

  /// Get the configured AI provider type (preferred from config or override)
  String getApiProvider() {
    if (_overrideId != null) {
      final match = getActiveProviders().firstWhereOrNull((p) => p.id == _overrideId);
      if (match != null) return match.provider.toLowerCase();
    }
    return _remoteConfig.getString('api_provider').toLowerCase();
  }

  /// Get a specific provider by ID or the first active one of a specific type
  AIProviderConfig? getProvider({String? id, String? type}) {
    final providers = getActiveProviders();
    if (providers.isEmpty) return null;

    // 1. Explicit ID requested
    final targetId = id ?? _overrideId;
    if (targetId != null) {
      final match = providers.firstWhereOrNull((p) => p.id == targetId);
      if (match != null) return match;
    }
    
    // 2. Explicit type requested (e.g., 'groq')
    if (type != null) {
      return providers.firstWhereOrNull((p) => p.provider.toLowerCase() == type.toLowerCase());
    }
    
    // 3. Fallback to preferred 'api_provider' type from Remote Config
    final preferredType = _remoteConfig.getString('api_provider').toLowerCase();
    final preferred = providers.firstWhereOrNull((p) => p.provider.toLowerCase() == preferredType.toLowerCase());
    
    // 4. Ultimate fallback to the first active provider
    return preferred ?? providers.first;
  }

  /// Legacy compatibility: Get API key
  String getApiKey(String difficulty, {String? provider}) {
    final config = getProvider(type: provider);
    if (config != null) {
      _logger.d('SUCCESS: Using ${config.id} (${config.provider}) from dynamic config (Ends with: ...${config.apiKey.length > 4 ? config.apiKey.substring(config.apiKey.length - 4) : ""})');
      return config.apiKey;
    }
    _logger.w('WARNING: No active provider found for ${provider ?? getApiProvider()}');
    return '';
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
