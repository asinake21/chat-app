import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

// This service handles all Firebase Authentication actions like signing in, signing up, and resetting password.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Get the currently logged-in user
  User? get currentUser => _auth.currentUser;

  // Stream that tells us if the user's auth state changed (like logged in or out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Signs up a new user and sets up their Firestore profile
  // TODO: Add email verification step if we have time before submission
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // 1. Create the credentials in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Set their display name on the Firebase user profile
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      // 3. Save additional user info to Firestore so we can show profiles
      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
          photoUrl: AppConstants.defaultProfilePicture,
          bio: 'Hey there! I am a student using CampusLink.',
          joinedAt: DateTime.now(),
        );
        await _firestoreService.createUser(userModel);
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred during registration: $e');
    }
  }

  // Logs in an existing user with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in: $e');
    }
  }

  // Signs out the user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Sends a password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
}
