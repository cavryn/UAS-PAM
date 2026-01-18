import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB4cwLk0DaOWb00w0X2wqFtufweyqab7eY',
    appId: '1:416676628876:web:YOUR_WEB_APP_ID',
    messagingSenderId: '416676628876',
    projectId: 'apa-kek-9abbe',
    authDomain: 'apa-kek-9abbe.firebaseapp.com',
    storageBucket: 'apa-kek-9abbe.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4cwLk0DaOWb00w0X2wqFtufweyqab7eY',
    appId: '1:416676628876:android:08461eb14ee0257836eea9',
    messagingSenderId: '416676628876',
    projectId: 'apa-kek-9abbe',
    storageBucket: 'apa-kek-9abbe.firebasestorage.app',
  );
}