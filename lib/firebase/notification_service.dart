import 'package:firebase_messaging/firebase_messaging.dart';
import 'firestore_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Asks the user for push notification permissions and saves their device token
  Future<void> initializeNotification(String userId) async {
    try {
      // 1. Request notifications permission (important for iOS and Android 13+)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Get the unique FCM token for this device
        String? token = await _fcm.getToken();
        if (token != null) {
          await _firestoreService.updateUserProfile(userId, fcmToken: token);
        }

        // 3. Listen in case the token gets refreshed later
        _fcm.onTokenRefresh.listen((newToken) async {
          await _firestoreService.updateUserProfile(userId, fcmToken: newToken);
        });

        // 4. Setup listeners to handle incoming notifications
        _setupNotificationListeners();
      }
    } catch (e) {
      // We catch errors here because FCM might fail on some simulators/emulators
    }
  }

  // Set up listeners for background and foreground notifications
  // TODO: Install flutter_local_notifications to show real heads-up banners when app is active
  void _setupNotificationListeners() {
    // When the app is open and in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // For now, we don't show a popup since the user is already inside the app
    });

    // When the user clicks on a notification from their drawer
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // In the future we can parse message.data and navigate to the post
    });
  }
}
