import 'package:get/get.dart';
import '../../presentation/views/splash_view.dart';
import '../../presentation/views/auth_view.dart';
import '../../presentation/views/main_app_view.dart';
import '../../presentation/views/domain_view.dart';
import '../../presentation/views/interview_view.dart';
import '../../presentation/views/results_view.dart';
import '../../presentation/views/resume_checker_view.dart';
import '../../presentation/views/resume_builder_view.dart';
import '../../presentation/views/resume_analysis_view.dart';
import '../../presentation/views/generated_resume_view.dart';
import '../../presentation/views/home_view.dart';
import '../../presentation/views/prep_hub_view.dart';
import '../../presentation/views/practice_mode_selection_view.dart';
import '../../presentation/views/ai_providers_admin_view.dart';
import '../../presentation/views/admin_dashboard_view.dart';
import '../../presentation/views/users_management_view.dart';
import '../../presentation/views/domain_management_view.dart';
import '../../presentation/views/interview_history_view.dart';
import '../../presentation/views/admin_theme_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String mainShell = '/main'; 
  static const String domain = '/domain';
  static const String interview = '/interview';
  static const String results = '/results';
  static const String resumeChecker = '/resume-checker';
  static const String resumeBuilder = '/resume-builder';
  static const String resumeAnalysis = '/resume-analysis';
  static const String generatedResume = '/generated-resume';
  static const String home = '/home';
  static const String prepHub = '/prep-hub';
  static const String practiceMode = '/practice-mode';
  static const String aiProvidersAdmin = '/ai-providers-admin';
  static const String adminDashboard = '/admin-dashboard';
  static const String userManagement = '/user-management';
  static const String domainManagement = '/domain-management';
  static const String history = '/history';
  static const String adminTheme = '/admin-theme';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: auth,
      page: () => const AuthView(),
    ),
    GetPage(
      name: mainShell,
      page: () => const MainAppView(),
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
    GetPage(
      name: home,
      page: () => const HomeView(),
    ),
    GetPage(
      name: prepHub,
      page: () => const PrepHubView(),
    ),
    GetPage(
      name: practiceMode,
      page: () => const PracticeModeSelectionView(),
    ),
    GetPage(
      name: aiProvidersAdmin,
      page: () => const AiProvidersAdminView(),
    ),
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboardView(),
    ),
    GetPage(
      name: userManagement,
      page: () => const UsersManagementView(),
    ),
    GetPage(
      name: domainManagement,
      page: () => const DomainManagementView(),
    ),
    GetPage(
      name: history,
      page: () => const InterviewHistoryView(),
    ),
    GetPage(
      name: adminTheme,
      page: () => const AdminThemeView(),
    ),
  ];
}
