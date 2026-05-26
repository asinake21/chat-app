import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/auth_service.dart';
import '../firebase/firestore_service.dart';
import '../firebase/storage_service.dart';
import '../firebase/notification_service.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  UserModel? _userModel;
  bool _isLoading = false;
  bool _isSigningUp = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authService.currentUser != null;

  AuthProvider() {
    _init();
  }

  // Initialize the provider by listening to Firebase Auth changes
  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // If logged in, fetch their profile details from Firestore
        await fetchUserProfile(firebaseUser.uid);
        // Also register this device to receive push notifications
        _notificationService.initializeNotification(firebaseUser.uid);
      } else {
        // Clear user model on sign out
        _userModel = null;
        notifyListeners();
      }
    });
  }

  // Load the user's Firestore profile data
  // TODO: Add offline caching using SharedPreferences so the profile loads instantly
  Future<void> fetchUserProfile(String uid) async {
    try {
      _userModel = await _firestoreService.getUser(uid);
      // Fallback: If document doesn't exist yet (e.g. Google login or auth mismatch)
      if (_userModel == null && !_isSigningUp) {
        final firebaseUser = _authService.currentUser;
        if (firebaseUser != null) {
          _userModel = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? 'Student User',
            photoUrl: firebaseUser.photoURL ?? AppConstants.defaultProfilePicture,
            bio: 'Hey there! I am a student using CampusLink.',
            joinedAt: DateTime.now(),
          );
          await _firestoreService.createUser(_userModel!);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  // Helper to toggle the loading state and rebuild the UI
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Register a new student user
  Future<void> signUp(String email, String password, String displayName) async {
    _setLoading(true);
    _isSigningUp = true;
    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      final user = _authService.currentUser;
      if (user != null) {
        await fetchUserProfile(user.uid);
      }
    } finally {
      _isSigningUp = false;
      _setLoading(false);
    }
  }

  // Log in user with email & password
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Sign out the current user and clean up local user state
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _userModel = null;
    } finally {
      _setLoading(false);
    }
  }

  // Send a reset password email to the user
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
    } finally {
      _setLoading(false);
    }
  }

  // Update displayName or bio, then refresh the local user model
  Future<void> updateProfile({
    String? displayName,
    String? bio,
  }) async {
    if (_userModel == null) return;
    _setLoading(true);
    try {
      await _firestoreService.updateUserProfile(
        _userModel!.uid,
        displayName: displayName,
        bio: bio,
      );

      // Re-fetch profile to update UI with new details
      await fetchUserProfile(_userModel!.uid);
    } finally {
      _setLoading(false);
    }
  }
}
