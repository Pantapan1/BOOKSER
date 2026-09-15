import 'package:firebase_database/firebase_database.dart';

/// Тонкая обёртка над FirebaseDatabase — те же пути, что и в оригинальном
/// state.db из core.js: users/, auth_users/, posts/, chats/.
class Db {
  Db._();
  static final FirebaseDatabase instance = FirebaseDatabase.instance;

  static DatabaseReference ref(String path) => instance.ref(path);
}
