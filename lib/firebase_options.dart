// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA17E5iqG7utYYPZzi6-yrlOzfWjNHWd80',
    appId: '1:700925272298:web:c1afcffda0229bcf4db793',
    messagingSenderId: '700925272298',
    projectId: 'cit-ecommerce-vn',
    authDomain: 'cit-ecommerce-vn.firebaseapp.com',
    databaseURL: 'https://cit-ecommerce-vn-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cit-ecommerce-vn.appspot.com',
    measurementId: 'G-0PBMWVVD5C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCVjhYFSKd9T3enyrhBLiECBKXUmyDXjx4',
    appId: '1:700925272298:android:a4fa0538ec2bc2294db793',
    messagingSenderId: '700925272298',
    projectId: 'cit-ecommerce-vn',
    databaseURL: 'https://cit-ecommerce-vn-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cit-ecommerce-vn.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqKReMHpCoYWKhcmATU_SWKNe5ibCzXjc',
    appId: '1:700925272298:ios:71bfdc553cdcd6714db793',
    messagingSenderId: '700925272298',
    projectId: 'cit-ecommerce-vn',
    databaseURL: 'https://cit-ecommerce-vn-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cit-ecommerce-vn.appspot.com',
    iosBundleId: 'com.citgroupvn.ecommerce',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDqKReMHpCoYWKhcmATU_SWKNe5ibCzXjc',
    appId: '1:700925272298:ios:63ce75947b6940ef4db793',
    messagingSenderId: '700925272298',
    projectId: 'cit-ecommerce-vn',
    databaseURL: 'https://cit-ecommerce-vn-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cit-ecommerce-vn.appspot.com',
    iosBundleId: 'com.citgroupvn.efood.efoodtable.RunnerTests',
  );
}
