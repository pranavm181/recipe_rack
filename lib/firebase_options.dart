// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDuJlyJ10lBBYcq_4xWvMsXtx4a_qxCOaI',
    appId: '1:281722860128:web:3058f44ff0fa74bec1c905',
    messagingSenderId: '281722860128',
    projectId: 'practice-30dca',
    authDomain: 'practice-30dca.firebaseapp.com',
    storageBucket: 'practice-30dca.appspot.com',
    measurementId: 'G-MG8QEE2P2G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7ZI3R7MsER3DUTUZ5xKF3aw9Uv8LwYbM',
    appId: '1:281722860128:android:54e285f5cbc73d64c1c905',
    messagingSenderId: '281722860128',
    projectId: 'practice-30dca',
    storageBucket: 'practice-30dca.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgUraOEM3E1kCqGfD19iMFKAfS1IEYggc',
    appId: '1:281722860128:ios:768270fa6db27f73c1c905',
    messagingSenderId: '281722860128',
    projectId: 'practice-30dca',
    storageBucket: 'practice-30dca.appspot.com',
    androidClientId: '281722860128-lblmkb19qk000i4bfmf7f6gohhr0lt95.apps.googleusercontent.com',
    iosClientId: '281722860128-phbc0hi8rc4ln26ce0pc6dmcg08huh67.apps.googleusercontent.com',
    iosBundleId: 'com.example.recipeRack',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCgUraOEM3E1kCqGfD19iMFKAfS1IEYggc',
    appId: '1:281722860128:ios:768270fa6db27f73c1c905',
    messagingSenderId: '281722860128',
    projectId: 'practice-30dca',
    storageBucket: 'practice-30dca.appspot.com',
    androidClientId: '281722860128-lblmkb19qk000i4bfmf7f6gohhr0lt95.apps.googleusercontent.com',
    iosClientId: '281722860128-phbc0hi8rc4ln26ce0pc6dmcg08huh67.apps.googleusercontent.com',
    iosBundleId: 'com.example.recipeRack',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDyvqRYWzsnVT7tYwKgAigETcQ4R2hpVyI',
    appId: '1:281722860128:web:c90e06104acc6b8fc1c905',
    messagingSenderId: '281722860128',
    projectId: 'practice-30dca',
    authDomain: 'practice-30dca.firebaseapp.com',
    storageBucket: 'practice-30dca.appspot.com',
    measurementId: 'G-TV2TCF4812',
  );
}
