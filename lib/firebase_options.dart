// File generated manually for Android-only Firebase configuration.
// Visit Firebase Console → Project Settings → Your Apps
// and download google-services.json to get the correct values.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ANDROID CONFIG — values from google-services.json
  // ═══════════════════════════════════════════════════════════════
  // Open google-services.json and map:
  //   apiKey        ← client[0].api_key[0].current_key
  //   appId         ← client[0].client_info.mobilesdk_app_id
  //   messagingSenderId ← project_info.project_number
  //   projectId     ← project_info.project_id
  //   storageBucket ← project_info.storage_bucket

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7uzEjuK_lDfXkCYzfCBXtuDnz5N4_n1A',
    appId: '1:962890456787:android:325f3c0b07d272f1e6fe26',
    messagingSenderId: '962890456787',
    projectId: 'pdfup-532a2',
    databaseURL: 'https://pdfup-532a2-default-rtdb.firebaseio.com',
    storageBucket: 'pdfup-532a2.appspot.com',
  );

  // ═══════════════════════════════════════════════════════════════
}