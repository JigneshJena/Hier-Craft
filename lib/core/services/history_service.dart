import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../../data/services/user_service.dart';

class HistoryService extends GetxService {
  final _storage = GetStorage();
  static const String _keySessions = 'interview_sessions';
  static const String _keyHistory = 'interview_history'; // Added back

  /// Save or update an interview session
  Future<void> saveSession({
    required String sessionId,
    required String domain,
    required String level,
    required List<Map<String, dynamic>> conversation,
    required bool isComplete,
    double? score,
    Map<String, dynamic>? results,
  }) async {
    final List<dynamic> sessions = _storage.read(_keySessions) ?? [];
    final sessionMap = sessions.cast<Map<String, dynamic>>();
    
    final existingIndex = sessionMap.indexWhere((s) => s['id'] == sessionId);
    
    final sessionData = {
      'id': sessionId,
      'domain': domain,
      'level': level,
      'conversation': conversation,
      'isComplete': isComplete,
      'score': score,
      'results': results,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (existingIndex != null && existingIndex >= 0) {
      sessionMap[existingIndex] = sessionData;
    } else {
      sessionMap.add(sessionData);
    }

    // Keep last 50 sessions
    if (sessionMap.length > 50) {
      sessionMap.removeAt(0);
    }

    await _storage.write(_keySessions, sessionMap);
    
    // Sync to Firestore for Admin Reports
    Get.find<UserService>().syncSessionToFirestore(sessionData);
    
    // If complete, sync progress
    if (isComplete && score != null) {
      _syncProgress(domain, score);
    }
  }

  /// Legacy Support: Save a question that was answered
  Future<void> saveAnsweredQuestion({
    required String question,
    required double score,
    required String domain,
  }) async {
    final List<dynamic> history = _storage.read(_keyHistory) ?? [];
    final historyList = history.cast<Map<String, dynamic>>();
    
    historyList.add({
      'question': question,
      'score': score,
      'domain': domain,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (historyList.length > 200) historyList.removeAt(0);
    await _storage.write(_keyHistory, historyList);
  }

  /// Legacy Support: Get mastered questions
  List<String> getMasteredQuestions(String domain) {
    final List<dynamic>? data = _storage.read(_keyHistory);
    if (data == null) return [];
    final history = data.cast<Map<String, dynamic>>();
    return history
        .where((item) => item['domain'] == domain && (item['score'] as num) >= 7.0)
        .map((item) => item['question'] as String)
        .toList();
  }

  void _syncProgress(String domain, double score) {
    final history = getSessions();
    final completedInDomain = history.where((s) => s['domain'] == domain && s['isComplete'] == true).toList();
    final masteredCount = completedInDomain.where((s) => (s['score'] as num? ?? 0) >= 7.0).length;
    final progress = (masteredCount / 10.0).clamp(0.0, 1.0); // 10 mastered for 100%

    Get.find<UserService>().syncUserProgress(
      currentPrep: domain,
      progress: progress,
      metadata: {
        'totalInterviews': completedInDomain.length,
        'lastScore': score,
      },
    );
  }

  List<Map<String, dynamic>> getSessions() {
    final List<dynamic>? data = _storage.read(_keySessions);
    if (data == null) return [];
    return data.cast<Map<String, dynamic>>().reversed.toList(); // Newest first
  }

  /// Legacy compatibility
  List<Map<String, dynamic>> getHistory() => getSessions();

  Future<void> clearHistory() async {
    await _storage.remove(_keySessions);
    await _storage.remove(_keyHistory);
  }
}
