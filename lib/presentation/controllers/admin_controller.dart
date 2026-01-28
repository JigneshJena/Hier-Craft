import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import '../../data/services/user_service.dart';
import '../../data/services/domain_service.dart';
import '../../core/services/presence_service.dart';

class AdminController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final PresenceService _presenceService = Get.find<PresenceService>();
  final DomainService _domainService = Get.put(DomainService());
  
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt onlineCount = 0.obs;
  final RxInt totalDomains = 0.obs;
  final RxInt totalSessions = 0.obs;
  
  StreamSubscription? _usersSub;
  StreamSubscription? _onlineSub;
  StreamSubscription? _domainsSub;
  StreamSubscription? _sessionsSub;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  void refreshData() {
    _startListening();
  }

  void _startListening() {
    _cancelSubs();
    
    // Bind Users
    _usersSub = _userService.getAllUsers().listen(
      (list) {
        users.value = list;
        isLoading.value = false;
      },
      onError: (e) => print("Firestore Error (Users Stream): $e"),
    );
    
    // Bind Online Count
    _onlineSub = _presenceService.getOnlineUsersCount().listen((count) => onlineCount.value = count);
    
    // Bind Total Domains
    _domainsSub = _domainService.getDomainsStream().listen((list) => totalDomains.value = list.length);

    // Bind Total Sessions
    _sessionsSub = FirebaseFirestore.instance.collection('sessions').snapshots().listen((snap) => totalSessions.value = snap.size);
  }

  void _cancelSubs() {
    _usersSub?.cancel();
    _onlineSub?.cancel();
    _domainsSub?.cancel();
    _sessionsSub?.cancel();
  }

  @override
  void onClose() {
    _cancelSubs();
    super.onClose();
  }

  // Real-time online count from Presence System (RTDB)
  int get activeUsersCount => onlineCount.value;

  double get averageProgress => users.isEmpty 
    ? 0 
    : users.map((u) => u.progress).reduce((a, b) => a + b) / users.length;

  // Delete user completely (Firestore + Realtime DB)
  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      
      // Delete from Firestore
      await _userService.deleteUser(userId);
      
      // Delete from Realtime DB (presence)
      await _presenceService.deleteUserPresence(userId);
      
      print('✅ User $userId deleted successfully from all databases');
    } catch (e) {
      print('❌ Error deleting user: $e');
      Get.snackbar(
        'Error',
        'Failed to delete user: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Update user details
  Future<void> updateUser({
    required String userId,
    required String name,
    required String email,
    required String currentPrep,
  }) async {
    try {
      isLoading.value = true;
      await _userService.updateUserDetails(
        userId: userId,
        name: name,
        email: email,
        currentPrep: currentPrep,
      );
      
      Get.snackbar(
        'Success',
        'User details updated successfully',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error updating user: $e');
      Get.snackbar(
        'Error',
        'Failed to update user: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
