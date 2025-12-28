import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offAllNamed(AppRoutes.domain);
  }
}
