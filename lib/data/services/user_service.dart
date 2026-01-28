import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import '../../core/services/auth_service.dart';
import 'dart:io';

class UserService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();
  final String _collection = 'users';
  final String _userKey = 'local_user_id';

  String get userId {
    final authService = Get.find<AuthService>();
    if (authService.isLoggedIn) {
      return authService.user!.uid;
    }
    return _storage.read(_userKey) ?? 'unknown';
  }

  Future<UserService> init() async {
    String? localId = _storage.read(_userKey);
    if (localId == null) {
      localId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await _storage.write(_userKey, localId);
    }
    return this;
  }

  // Sync a specific session to global sessions (for Admin reports)
  Future<void> syncSessionToFirestore(Map<String, dynamic> sessionData) async {
    try {
      final authService = Get.find<AuthService>();
      final uid = authService.user?.uid ?? userId;
      
      await _firestore.collection('sessions').doc(sessionData['id']).set({
        ...sessionData,
        'userId': uid,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing session: $e');
    }
  }

  // Update user activity and progress
  Future<void> syncUserProgress({
    required String currentPrep,
    required double progress,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final authService = Get.find<AuthService>();
      final name = authService.isLoggedIn 
          ? (authService.user!.displayName ?? authService.user!.email?.split('@')[0] ?? 'User')
          : 'User_${userId.substring(userId.length - 4)}';
      
      final email = authService.user?.email ?? '';

      await _firestore.collection(_collection).doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'currentPrep': currentPrep,
        'progress': progress,
        'lastActive': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing user progress: $e');
    }
  }

  // Stream of all users for Admin
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection(_collection)
        .orderBy('lastActive', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Delete user from Firestore (Admin only)
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
      print('✅ User $userId deleted from Firestore');
    } catch (e) {
      print('❌ Error deleting user from Firestore: $e');
      rethrow;
    }
  }

  // Update user details (Admin only)
  Future<void> updateUserDetails({
    required String userId,
    required String name,
    required String email,
    required String currentPrep,
  }) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'name': name,
        'email': email,
        'currentPrep': currentPrep,
        'lastActive': FieldValue.serverTimestamp(),
      });
      print('✅ User $userId updated successfully');
    } catch (e) {
      print('❌ Error updating user: $e');
      rethrow;
    }
  }
}
