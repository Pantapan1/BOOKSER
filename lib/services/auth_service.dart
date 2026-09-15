import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/firebase_client.dart';
import '../models/user_profile.dart';

/// Логин/пароль — точно та же схема, что и в оригинале (core.js):
///   auth_users/{safeUsername} -> { password: sha256hex, id: 'usr_<timestamp>' }
///   users/{id}                -> профиль (name, coins, avatar, lastSeen, ...)
/// Локальная сессия — SharedPreferences вместо localStorage('sr_auth_user').
/// Существующие пользователи (в т.ч. со старыми пароля-как-текст записями)
/// логинятся без изменений — сохранена поддержка legacy-записей.
class AuthService {
  static const _prefsIdKey = 'sr_auth_user_id';
  static const _prefsNameKey = 'sr_auth_user_name';

  String _safeUsername(String un) => un.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

  String _hashPassword(String pw) => sha256.convert(utf8.encode(pw)).toString();

  Future<UserProfile> register({required String username, required String password}) async {
    final safeUn = _safeUsername(username);
    if (safeUn.isEmpty) {
      throw Exception('Используйте только английские буквы и цифры для ника');
    }

    final authRef = Db.ref('auth_users/$safeUn');
    final existing = await authRef.get();
    if (existing.exists) {
      throw Exception('user_already_exists');
    }

    final newId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final hashed = _hashPassword(password);
    await authRef.set({'password': hashed, 'id': newId});

    await _persistSession(newId, username.trim());
    await _ensureUserProfile(newId, username.trim());
    return getMyProfile();
  }

  Future<UserProfile> login({required String username, required String password}) async {
    final safeUn = _safeUsername(username);
    final hashed = _hashPassword(password);

    final snapshot = await Db.ref('auth_users/$safeUn').get();
    if (!snapshot.exists) {
      throw Exception('user_invalid_credentials');
    }
    final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
    final stored = data['password'] as String?;
    final isHashMatch = stored == hashed;
    final isLegacyMatch = !isHashMatch && stored == password;

    if (!isHashMatch && !isLegacyMatch) {
      throw Exception('user_invalid_credentials');
    }
    if (isLegacyMatch) {
      // мигрируем старую запись на хэш при успешном входе — как и в оригинале
      await Db.ref('auth_users/$safeUn/password').set(hashed);
    }

    final id = data['id'] as String;
    await _persistSession(id, username.trim());
    await _ensureUserProfile(id, username.trim());
    return getMyProfile();
  }

  Future<void> _ensureUserProfile(String id, String name) async {
    await Db.ref('users/$id').update({'name': name, 'lastSeen': DateTime.now().millisecondsSinceEpoch});
  }

  Future<void> _persistSession(String id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsIdKey, id);
    await prefs.setString(_prefsNameKey, name);
  }

  Future<UserProfile?> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsIdKey);
    if (id == null) return null;
    return getMyProfile();
  }

  Future<UserProfile> getMyProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsIdKey);
    final fallbackName = prefs.getString(_prefsNameKey) ?? 'Читатель';
    if (id == null) throw Exception('Нет активной сессии');

    final snapshot = await Db.ref('users/$id').get();
    if (!snapshot.exists) return UserProfile(id: id, name: fallbackName);
    return UserProfile.fromMap(id, Map<dynamic, dynamic>.from(snapshot.value as Map));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsIdKey);
    await prefs.remove(_prefsNameKey);
  }
}
