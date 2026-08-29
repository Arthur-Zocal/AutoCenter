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
    apiKey: 'AIzaSyDIikuPwc5zXk_NPmLqWw_SUjUhDduaqLc',
    appId: '1:468299351202:web:c3eb355973cef4bf6c83fb',
    messagingSenderId: '468299351202',
    projectId: 'auto-center-bd1b6',
    authDomain: 'auto-center-bd1b6.firebaseapp.com',
    storageBucket: 'auto-center-bd1b6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIikuPwc5zXk_NPmLqWw_SUjUhDduaqLc',
    appId: '1:468299351202:android:c3eb355973cef4bf6c83fb',
    messagingSenderId: '468299351202',
    projectId: 'auto-center-bd1b6',
    storageBucket: 'auto-center-bd1b6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDIikuPwc5zXk_NPmLqWw_SUjUhDduaqLc',
    appId: '1:468299351202:ios:c3eb355973cef4bf6c83fb',
    messagingSenderId: '468299351202',
    projectId: 'auto-center-bd1b6',
    storageBucket: 'auto-center-bd1b6.firebasestorage.app',
    iosBundleId: 'com.example.projetoFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDIikuPwc5zXk_NPmLqWw_SUjUhDduaqLc',
    appId: '1:468299351202:ios:c3eb355973cef4bf6c83fb',
    messagingSenderId: '468299351202',
    projectId: 'auto-center-bd1b6',
    storageBucket: 'auto-center-bd1b6.firebasestorage.app',
    iosBundleId: 'com.example.projetoFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDIikuPwc5zXk_NPmLqWw_SUjUhDduaqLc',
    appId: '1:468299351202:web:c3eb355973cef4bf6c83fb',
    messagingSenderId: '468299351202',
    projectId: 'auto-center-bd1b6',
    authDomain: 'auto-center-bd1b6.firebaseapp.com',
    storageBucket: 'auto-center-bd1b6.firebasestorage.app',
  );
}