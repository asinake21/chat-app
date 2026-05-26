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

  /// Listens to authentication state changes and loads profile when user is signed in
  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await fetchUserProfile(firebaseUser.uid);
        // Initialize push notifications for the authenticated user
        _notificationService.initializeNotification(firebaseUser.uid);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  /// Fetches the profile data from Cloud Firestore
  Future<void> fetchUserProfile(String uid) async {
    try {
      _userModel = await _firestoreService.getUser(uid);
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
      // Handle error or print
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Signs up a new user and signs them in
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

  /// Signs in an existing user
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

  /// Signs out the current user
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _userModel = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Triggers a password reset email
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
    } finally {
      _setLoading(false);
    }
  }

  /// Updates profile metadata
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

      // Refresh the locally stored model
      await fetchUserProfile(_userModel!.uid);
    } finally {
      _setLoading(false);
    }
  }
}
