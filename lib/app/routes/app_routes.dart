import 'package:get/get.dart';
import '../../presentation/views/splash_view.dart';
import '../../presentation/views/domain_view.dart';
import '../../presentation/views/interview_view.dart';
import '../../presentation/views/results_view.dart';
import '../../presentation/views/resume_checker_view.dart';
import '../../presentation/views/resume_builder_view.dart';
import '../../presentation/views/resume_analysis_view.dart';
import '../../presentation/views/generated_resume_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String domain = '/domain';
  static const String interview = '/interview';
  static const String results = '/results';
  static const String resumeChecker = '/resume-checker';
  static const String resumeBuilder = '/resume-builder';
  static const String resumeAnalysis = '/resume-analysis';
  static const String generatedResume = '/generated-resume';

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
    GetPage(
      name: resumeBuilder,
      page: () => const ResumeBuilderView(),
    ),
    GetPage(
      name: resumeAnalysis,
      page: () => const ResumeAnalysisView(),
    ),
    GetPage(
      name: generatedResume,
      page: () => const GeneratedResumeView(),
    ),
  ];
}
