import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:firebase_core/firebase_core.dart';

class PresenceService extends GetxService {
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://mockinterview-hirecraft-default-rtdb.asia-southeast1.firebasedatabase.app",
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;


  void initPresence() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _updatePresence(user.uid);
      }
    });
  }

  void _updatePresence(String uid) {
    final presenceRef = _db.ref("presence/$uid");
    final connectedRef = _db.ref(".info/connected");

    connectedRef.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (connected) {
        // Set online status
        presenceRef.set({
          'status': 'online',
          'lastChanged': ServerValue.timestamp,
          'email': _auth.currentUser?.email ?? 'Unknown',
        });

        // Setup onDisconnect to mark as offline
        presenceRef.onDisconnect().set({
          'status': 'offline',
          'lastChanged': ServerValue.timestamp,
        });
      }
    });
  }

  // Stream to get all online users count for Admin
  Stream<int> getOnlineUsersCount() {
    return _db.ref("presence").onValue.map((event) {
      int count = 0;
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        data.forEach((key, value) {
          if (value['status'] == 'online') {
            count++;
          }
        });
      }
      return count;
    });
  }

  // Delete user presence from Realtime DB (Admin only)
  Future<void> deleteUserPresence(String userId) async {
    try {
      await _db.ref("presence/$userId").remove();
      print('✅ User presence $userId deleted from Realtime DB');
    } catch (e) {
      print('❌ Error deleting user presence: $e');
      rethrow;
    }
  }
}
