# Cleanliness & Environmental Awareness

A beginner-friendly Flutter + Firebase mobile app with Material 3 UI.

## Features
- Splash screen with green gradient and eco icon
- Firebase email/password login and signup
- Dashboard with 4 tabs (Home, Report Issue, Awareness, Profile)
- Google Maps + Geolocator-based issue reporting
- Firestore + Storage integration for issue data and photos
- Local JSON tips with Text-to-Speech
- Basic admin issue list with status update (Pending/Resolved)
- FCM token storage for push notification workflows

## Folder Structure
- `lib/main.dart`
- `lib/screens/`
- `lib/widgets/`
- `lib/services/`
- `lib/models/`
- `assets/data/tips.json`

## Dependencies
Already added in `pubspec.yaml`:
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`
- `firebase_messaging`
- `google_maps_flutter`
- `geolocator`
- `image_picker`
- `flutter_tts`
- `provider`

## Firebase Setup
1. Create Firebase project at https://console.firebase.google.com
2. Enable:
   - Authentication -> Email/Password
   - Firestore Database
   - Storage
   - Cloud Messaging
3. Register Android and iOS apps in Firebase.
4. Add config files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
5. Run FlutterFire CLI or manually update `lib/firebase_options.dart` placeholder values.

## Google Maps Setup
1. Enable Maps SDK for Android and iOS in Google Cloud Console.
2. Create API key.
3. Add key to Android Manifest (`android/app/src/main/AndroidManifest.xml`):
   - `<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_MAPS_API_KEY" />`
4. Add key to iOS (`ios/Runner/AppDelegate.swift` or Info.plist as per plugin docs).

## Platform Permissions
### Android (`android/app/src/main/AndroidManifest.xml`)
Add:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `INTERNET`
- `CAMERA`
- `READ_MEDIA_IMAGES` (or storage permission for older SDK)

### iOS (`ios/Runner/Info.plist`)
Add usage descriptions:
- `NSLocationWhenInUseUsageDescription`
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

## Firestore Collections
### `issues`
Fields:
- `userId`
- `description`
- `latitude`
- `longitude`
- `imageURL`
- `timestamp`
- `status` (`Pending` or `Resolved`)

### `users`
Fields:
- `fcmToken`

## Push Notifications on Status Change
This app stores user FCM tokens in Firestore. To send notification when status changes, create a Firebase Cloud Function trigger:
- Trigger: Firestore document update on `issues/{issueId}`
- If `status` changed, read `userId`, get user `fcmToken`, send FCM message.

## Run
1. Install Flutter SDK and add to PATH.
2. In project root:
   - `flutter pub get`
   - `flutter run`

## Admin Access (Basic)
Any user whose email contains `admin` can open the admin issue management screen from Profile.
