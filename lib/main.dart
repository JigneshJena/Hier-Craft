import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/themes/app_themes.dart';
import 'presentation/controllers/theme_controller.dart';
import 'core/services/voice_service.dart';
import 'core/services/scoring_service.dart';
import 'core/services/dynamic_theme_service.dart';

import 'core/services/connectivity_service.dart';
import 'core/services/ai_api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/presence_service.dart';
import 'core/services/ai_config_service.dart';
import 'core/services/resume_service.dart';
import 'core/services/pdf_generator_service.dart';
import 'core/services/ai_interview_service.dart';
import 'core/services/history_service.dart';
import 'core/services/notification_service.dart';
import 'data/services/user_service.dart';
import 'app/constants/app_constants.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Critical Startup (Blocking)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    await GetStorage.init();
  } catch (e) {
    debugPrint("Critical Init Error: $e");
  }

  // 2. Critical Initialization (Wait for services)
  await _initServices();

  // 3. Start App
  runApp(const MyApp());
}

Future<void> _initServices() async {
  // 1. Sync & Immediate Injections
  Get.put(DynamicThemeService());
  Get.put(ThemeController());
  Get.put(AuthService());
  Get.put(ScoringService()); // Sync dependencies
  
  // 2. Critical Async Injections (Wait for these)
  final connectivity = ConnectivityService();
  Get.put(connectivity);
  await connectivity.init(); // Blocking wait for internet status

  // 3. Post-Config Injections
  Get.put(AiConfigService());
  Get.put(AiApiService());
  Get.put(HistoryService());
  Get.put(ResumeService());
  Get.put(PdfGeneratorService());
  Get.put(AIInterviewService());
  Get.put(PresenceService()).initPresence();
  
  // 4. Background Injections (Non-blocking)
  Get.putAsync(() => UserService().init());
  Get.putAsync(() => NotificationService().init());
  Get.putAsync(() => VoiceService().init());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone standard size for best compatibility
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true, // Ensures proper initialization
      builder: (_, child) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system, // Will be controlled by ThemeController later
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.routes,
          defaultTransition: Transition.fade,
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
