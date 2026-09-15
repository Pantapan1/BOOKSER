import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class SessionState extends ChangeNotifier {
  final AuthService _auth = AuthService();

  UserProfile? profile;
  bool loading = true;

  SessionState() {
    _restore();
  }

  Future<void> _restore() async {
    profile = await _auth.tryRestoreSession();
    loading = false;
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    try {
      profile = await _auth.login(username: username, password: password);
      notifyListeners();
      return null;
    } catch (e) {
      return _friendlyError(e);
    }
  }

  Future<String?> register(String username, String password) async {
    try {
      profile = await _auth.register(username: username, password: password);
      notifyListeners();
      return null;
    } catch (e) {
      return _friendlyError(e);
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    profile = null;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('user_already_exists')) return 'Никнейм уже занят!';
    if (msg.contains('user_invalid_credentials')) return 'Неверный никнейм или пароль';
    if (msg.contains('английские буквы')) return 'Используйте только английские буквы и цифры для ника';
    return 'Что-то пошло не так, попробуйте ещё раз';
  }
}
