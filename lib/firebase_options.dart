import 'package:firebase_core/firebase_core.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_uqJPJhBvOr_xe_mAHjnx4e4mBCKT9VQ',
    appId: '1:1090105547909:android:1c58120fd991ecc8189dec',
    messagingSenderId: '1090105547909',
    projectId: 'spotibook-736fe',
    storageBucket: 'spotibook-736fe.firebasestorage.app',
  );
}
