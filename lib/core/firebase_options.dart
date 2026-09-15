import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Собрано вручную из вашего существующего google-services.json
/// (проект book-2b50d, Android-приложение bokser.rlteam.com) — того же
/// файла, что уже используется в оригинальной APK-сборке через Capacitor.
///
/// Если позже добавите iOS, замените iosApiKey/iosAppId на значения из
/// GoogleService-Info.plist (для этого нужно зарегистрировать iOS-приложение
/// в консоли Firebase: Project settings -> Add app -> iOS) — либо просто
/// один раз запустите `flutterfire configure`, если у вас есть Firebase CLI,
/// он сгенерирует этот файл автоматически для всех платформ.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web пока не настроен — MVP только под Android.');
    }
    if (Platform.isAndroid) return android;
    throw UnsupportedError(
      'FirebaseOptions для этой платформы ещё не заданы. Добавьте приложение '
      'в консоли Firebase и впишите его данные сюда (или через flutterfire configure).',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDplb6Xeg6EObwMOc_hBxC3oDM9MMqjM_0',
    appId: '1:461145405797:android:989859c17c6a92a025098c',
    messagingSenderId: '461145405797',
    projectId: 'book-2b50d',
    databaseURL: 'https://book-2b50d-default-rtdb.firebaseio.com',
    storageBucket: 'book-2b50d.firebasestorage.app',
  );
}
