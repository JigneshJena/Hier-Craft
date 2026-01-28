import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/constants/app_constants.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _key = AppConstants.isDarkModeKey;
  
  late final Rx<ThemeMode> _themeMode;

  @override
  void onInit() {
    super.onInit();
    // Default to light mode (false) if no preference is saved
    _themeMode = (_loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light).obs;
    
    // If it's the first time, force light mode
    if (_storage.read(_key) == null) {
      _storage.write(_key, false);
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  ThemeMode get theme => _themeMode.value;

  bool _loadThemeFromBox() => _storage.read(_key) ?? false;

  void saveThemeToBox(bool isDarkMode) => _storage.write(_key, isDarkMode);

  void switchTheme() {
    final isDarkMode = _themeMode.value == ThemeMode.dark;
    _themeMode.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(_themeMode.value);
    saveThemeToBox(!isDarkMode);
  }
}
