import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  final Rx<User?> _user = Rx<User?>(null);
  User? get user => _user.value;
  
  final RxString _role = 'user'.obs;
  String get role => _role.value;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    // Whenever auth state changes, fetch user role
    ever(_user, _handleAuthStateChanged);
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    if (user != null) {
      await _fetchUserRole(user.uid);
    } else {
      _role.value = 'user';
    }
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('users').doc(uid).get();
      final currentUser = _auth.currentUser;
      
      // Auto-upgrade logic for master admin
      if (currentUser?.email?.toLowerCase() == 'hirecraftadmin@gmail.com') {
        if (!doc.exists || doc.data()?['role'] != 'admin') {
          print("Master admin detected. Ensuring admin role in Firestore...");
          await _createUserProfile(uid, currentUser?.displayName ?? 'Admin', currentUser?.email);
          // Re-fetch doc to have latest role
          doc = await _firestore.collection('users').doc(uid).get();
        }
      }

      if (doc.exists) {
        _role.value = doc.data()?['role'] ?? 'user';
        print("User profile found for $uid. Role: ${_role.value}");
      } else {
        print("No profile found for $uid. Creating new profile...");
        await _createUserProfile(
          uid, 
          currentUser?.displayName ?? 'User', 
          currentUser?.email ?? ''
        );
        // After creating, the role will be determined inside _createUserProfile
        // but for local state, we can set it based on email
        if (currentUser?.email?.toLowerCase() == 'hirecraftadmin@gmail.com') {
          _role.value = 'admin';
        } else {
          _role.value = 'user';
        }
      }
    } catch (e) {
      print("Error in _fetchUserRole: $e");
    }
  }

  Future<void> _createUserProfile(String uid, String? name, String? email) async {
    // Check if this is the dedicated admin email
    String role = 'user';
    if (email?.toLowerCase() == 'hirecraftadmin@gmail.com') {
      role = 'admin';
    }

    await _firestore.collection('users').doc(uid).set({
      'id': uid,
      'name': name ?? 'User',
      'email': email ?? '',
      'role': role,
      'currentPrep': 'General',
      'progress': 0.0,
      'lastActive': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _fetchUserRole(userCredential.user!.uid);
      }
      return userCredential;
    } catch (e) {
      Get.snackbar('Google Sign In', 'We couldn\'t connect your Google account. Please try again.');
      return null;
    }
  }

  Future<UserCredential?> signUp(String email, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        await _createUserProfile(cred.user!.uid, name, email);
        // Wait for potential ever() listener to finish or force it
        await _fetchUserRole(cred.user!.uid);
      }
      return cred;
    } catch (e) {
      Get.snackbar('Sign Up Error', 'Account creation failed. This email might already be in use.');
      return null;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        // Ensure role is fetched before returning so UI can redirect correctly
        await _fetchUserRole(cred.user!.uid);
      }
      return cred;
    } catch (e) {
      Get.snackbar('Login Issue', 'Incorrect email or password. Please double-check your credentials.');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  bool get isLoggedIn => _user.value != null;
  bool get isAdmin => _role.value == 'admin';
}
