import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';

class HomeController extends GetxController {
  final RxInt pendingTasks = 0.obs;
  
  final Map<int, String> _dailyTips = {
    0: "The STAR method is your best friend for behavioral questions.",
    1: "Research the company's culture and values before the interview.",
    2: "Prepare at least three questions to ask the interviewer.",
    3: "Dress professionally, even for a video interview.",
    4: "Practice active listening and don't be afraid to take a pause.",
    5: "Follow up with a thank-you note within 24 hours.",
    6: "Use specific examples to demonstrate your skills and impact.",
  };

  String get dailyTip {
    final dayIndex = DateTime.now().day % _dailyTips.length;
    return _dailyTips[dayIndex] ?? _dailyTips[0]!;
  }
  
  void goToMockInterview() => Get.toNamed(AppRoutes.domain);
  void goToResumeBuilder() => Get.toNamed(AppRoutes.resumeBuilder);
  void goToResumeChecker() => Get.toNamed(AppRoutes.resumeChecker);
  void goToPrepHub() => Get.toNamed(AppRoutes.prepHub);
  void goToAiAdmin() => Get.toNamed(AppRoutes.aiProvidersAdmin);
}
