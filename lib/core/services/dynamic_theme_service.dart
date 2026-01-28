import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DynamicThemeService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  
  // Observables for the 4 key colors
  final primaryColor = Rx<Color>(const Color(0xFF1A3263));
  final secondaryColor = Rx<Color>(const Color(0xFF547792));
  final accentColor = Rx<Color>(const Color(0xFFFAB95B));
  final backgroundColor = Rx<Color>(const Color(0xFFF7F5F2));

  // Storage keys for persistence when offline
  static const String _primaryKey = 'dynamic_primary';
  static const String _secondaryKey = 'dynamic_secondary';
  static const String _accentKey = 'dynamic_accent';
  static const String _backgroundKey = 'dynamic_background';

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    _listenToThemeChanges();
  }

  void _loadFromStorage() {
    primaryColor.value = _getColorFromHex(_storage.read(_primaryKey) ?? '1A3263');
    secondaryColor.value = _getColorFromHex(_storage.read(_secondaryKey) ?? '547792');
    accentColor.value = _getColorFromHex(_storage.read(_accentKey) ?? 'FAB95B');
    backgroundColor.value = _getColorFromHex(_storage.read(_backgroundKey) ?? 'F7F5F2');
  }

  void _listenToThemeChanges() {
    _firestore.collection('settings').doc('app_theme').snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        
        final p = data['primary'] as String?;
        final s = data['secondary'] as String?;
        final a = data['accent'] as String?;
        final b = data['background'] as String?;

        if (p != null) {
          primaryColor.value = _getColorFromHex(p);
          _storage.write(_primaryKey, p);
        }
        if (s != null) {
          secondaryColor.value = _getColorFromHex(s);
          _storage.write(_secondaryKey, s);
        }
        if (a != null) {
          accentColor.value = _getColorFromHex(a);
          _storage.write(_accentKey, a);
        }
        if (b != null) {
          backgroundColor.value = _getColorFromHex(b);
          _storage.write(_backgroundKey, b);
        }
        
        // Refresh the whole app UI
        Get.forceAppUpdate();
      }
    });
  }

  Future<void> updateTheme({
    required String primary,
    required String secondary,
    required String accent,
    required String background,
  }) async {
    await _firestore.collection('settings').doc('app_theme').set({
      'primary': primary,
      'secondary': secondary,
      'accent': accent,
      'background': background,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse("0x$hexColor"));
  }
}
