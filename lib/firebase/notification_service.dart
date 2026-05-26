import 'package:firebase_messaging/firebase_messaging.dart';
import 'firestore_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Requests messaging permissions and registers the FCM token to Firestore
  Future<void> initializeNotification(String userId) async {
    try {
      // 1. Request permissions for iOS/Android 13+
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Fetch unique Device Token
        String? token = await _fcm.getToken();
        if (token != null) {
          await _firestoreService.updateUserProfile(userId, fcmToken: token);
        }

        // 3. Listen for token refreshes
        _fcm.onTokenRefresh.listen((newToken) async {
          await _firestoreService.updateUserProfile(userId, fcmToken: newToken);
        });

        // 4. Configure notification listeners
        _setupNotificationListeners();
      }
    } catch (e) {
      // Gracefully handle FCM errors (e.g. running on simulators with no services)
      // print('FCM Initialization failed: $e');
    }
  }

  /// Sets up message listeners for active foreground sessions
  void _setupNotificationListeners() {
    // Handled when application is running in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // We can trigger a local notification here if desired
      // E.g., showing a dialog or standard alert banner
    });

    // Handled when app is opened from a background state by tapping notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Perform routing logic based on notification payload contents
    });
  }
}
