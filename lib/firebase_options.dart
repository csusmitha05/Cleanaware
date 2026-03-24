import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase options are not configured for this platform.');
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBlj6G9cWNXqxILKlCpdQrV0EUGREL8Ano',
    appId: '1:941801274048:web:1cf719cdab6a8fe26f0b25',
    messagingSenderId: '941801274048',
    projectId: 'cleanliness-awareness',
    storageBucket: 'cleanliness-awareness.firebasestorage.app',
    authDomain: 'cleanliness-awareness.firebaseapp.com',
    measurementId: 'G-TBSY09YGN4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDoIXPE97dBJO0-GoVEgAcgNt_k6p-W-YU',
    appId: '1:941801274048:android:9c64e2a0ab47f4306f0b25',
    messagingSenderId: '941801274048',
    projectId: 'cleanliness-awareness',
    storageBucket: 'cleanliness-awareness.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'IOS_API_KEY',
    appId: 'IOS_APP_ID',
    messagingSenderId: 'IOS_SENDER_ID',
    projectId: 'IOS_PROJECT_ID',
    storageBucket: 'IOS_STORAGE_BUCKET',
    iosBundleId: 'com.example.cleanlinessEnvironmentAwareness',
  );
}
