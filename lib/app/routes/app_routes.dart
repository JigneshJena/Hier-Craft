import 'package:get/get.dart';
import '../../presentation/views/splash_view.dart';
import '../../presentation/views/domain_view.dart';
import '../../presentation/views/interview_view.dart';
import '../../presentation/views/results_view.dart';
import '../../presentation/views/resume_checker_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String domain = '/domain';
  static const String interview = '/interview';
  static const String results = '/results';
  static const String resumeChecker = '/resume-checker';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: domain,
      page: () => const DomainView(),
    ),
    GetPage(
      name: interview,
      page: () => const InterviewView(),
    ),
    GetPage(
      name: results,
      page: () => const ResultsView(),
    ),
    GetPage(
      name: resumeChecker,
      page: () => const ResumeCheckerView(),
    ),
  ];
}
