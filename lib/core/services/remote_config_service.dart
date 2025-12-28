import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

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
    'gemini_key': 'AIzaSyDefault_Gemini_Key', // Simple string key
    'groq_api_key': '', // Groq API Key
    'api_key_easy': 'AIzaSyDefault_Easy_Key',
    'api_key_medium': 'AIzaSyDefault_Medium_Key',
    'api_key_hard': 'AIzaSyDefault_Hard_Key',
    'api_key_resume': 'AIzaSyDefault_Resume_Key',
    'api_provider': 'groq', // Options: gemini, openai, deepseek, groq
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

  /// Get API key based on difficulty level
  /// Returns the appropriate API key for easy, medium, hard, or resume
  String getApiKey(String difficulty) {
    // Check provider first
    String provider = getApiProvider();
    
    if (provider == 'groq') {
      String groqKey = _remoteConfig.getString('groq_api_key');
      if (groqKey.isNotEmpty) {
        _logger.d('Using groq_api_key for $difficulty');
        return groqKey;
      }
    }

    // Then, try the main gemini_api_key which is our primary key
    String mainKey = _remoteConfig.getString('gemini_key');
    if (mainKey.isNotEmpty && !mainKey.startsWith('AIzaSyDefault')) {
      _logger.d('Using main gemini_api_key for $difficulty');
      return mainKey;
    }

    // Fallback to legacy/specific keys if main key is not set
    String key;
    switch (difficulty.toLowerCase()) {
      case 'fresher':
      case 'easy':
        key = _remoteConfig.getString('api_key_easy');
        break;
      case 'intermediate':
      case 'medium':
        key = _remoteConfig.getString('api_key_medium');
        break;
      case 'experienced':
      case 'hard':
        key = _remoteConfig.getString('api_key_hard');
        break;
      case 'resume':
        key = _remoteConfig.getString('api_key_resume');
        break;
      default:
        key = _remoteConfig.getString('api_key_easy');
    }

    // If key is still default/empty, log warning
    if (key.isEmpty || key.startsWith('AIzaSyDefault')) {
      _logger.w('Using default API key fallback for $difficulty');
    }

    return key;
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
    return {
      'easy': _remoteConfig.getString('api_key_easy'),
      'medium': _remoteConfig.getString('api_key_medium'),
      'hard': _remoteConfig.getString('api_key_hard'),
      'resume': _remoteConfig.getString('api_key_resume'),
      'provider': _remoteConfig.getString('api_provider'),
    };
  }
}
