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
import 'core/services/remote_config_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/ai_api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/presence_service.dart';
import 'core/services/ai_config_service.dart';
import 'core/services/resume_service.dart';
import 'core/services/ai_interview_service.dart';
import 'core/services/history_service.dart';
import 'core/services/notification_service.dart';
import 'data/services/user_service.dart';
import 'app/constants/app_constants.dart';
import 'app/routes/app_routes.dart';

void main() async {
  print('main start');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase initialized');
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Initialize Services
  Get.put(ThemeController());
  final authService = Get.put(AuthService());
  Get.put(PresenceService()).initPresence();
  Get.put(AiConfigService());
  Get.put(ScoringService());
  Get.put(AiApiService());
  Get.put(HistoryService());
  await Get.putAsync(() => UserService().init());
  // Initialize Notification Service
  await Get.putAsync(() => NotificationService().init());
  
  // Initialize Remote Config first (required by ResumeService)
  await Get.putAsync(() => RemoteConfigService().init());
  print('Remote Config initialized');
  
  // Now initialize ResumeService (depends on RemoteConfigService)
  Get.put(ResumeService());
  
  // Initialize AI Interview Service for conversations
  Get.put(AIInterviewService());
  print('AI Interview Service initialized');
  
  // Initialize Connectivity Service
  await Get.putAsync(() => ConnectivityService().init());
  print('Connectivity Service initialized');
  
  // Initialize Voice Service
  print('VoiceService initialization start');
  await Get.putAsync(() => VoiceService().init());
  print('VoiceService initialization end');
  
  print('All services initialized successfully');

  print('runApp start');
  runApp(const MyApp());
  print('main end');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeController.theme,
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.routes,
          defaultTransition: Transition.fade,
          transitionDuration: const Duration(milliseconds: 400),
        );
      },
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'This is a placeholder for: $title',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
