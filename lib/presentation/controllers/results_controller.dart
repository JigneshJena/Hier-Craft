import 'package:get/get.dart';

class ResultsController extends GetxController {
  late num totalScore;
  late int maxScore;
  late List<Map<String, dynamic>> results;
  late String domain;
  Map<String, dynamic>? personality;

  @override
  void onInit() {
    super.onInit();
    totalScore = Get.arguments['totalScore'] ?? 0.0;
    maxScore = Get.arguments['maxScore'] ?? 100;
    results = Get.arguments['results'] ?? [];
    domain = Get.arguments['domain'] ?? 'Software';
    personality = Get.arguments['personality'];
  }

  double get percentage => (totalScore / maxScore) * 100;

  String get performanceMessage {
    if (percentage >= 80) return "Outstanding!";
    if (percentage >= 60) return "Well Done!";
    if (percentage >= 40) return "Good Effort!";
    return "Keep Practicing!";
  }
}
