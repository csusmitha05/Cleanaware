import 'package:firebase_messaging/firebase_messaging.dart';

import 'auth_service.dart';
import 'firestore_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Foreground message handling is intentionally lightweight for beginners.
    });
  }

  static Future<void> saveUserTokenIfLoggedIn(AuthService authService) async {
    final user = authService.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token != null) {
      await FirestoreService().saveFcmToken(userId: user.uid, token: token);
    }
  }
}
