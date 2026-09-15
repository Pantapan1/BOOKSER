import 'package:firebase_database/firebase_database.dart';
import '../core/firebase_client.dart';
import '../models/chat.dart';

/// chats/{chatId} и chats/{chatId}/messages/{pushId} — та же структура,
/// что и в оригинальном chats.js (startChatWith/sendMessage).
class ChatService {
  DatabaseReference get _chatsRef => Db.ref('chats');

  Future<List<ChatSummary>> listMyChats(String myId) async {
    final snapshot = await _chatsRef.get();
    if (!snapshot.exists) return [];
    final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
    final chats = map.entries
        .map((e) => ChatSummary.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
        .where((c) => c.participants.containsKey(myId))
        .toList();
    chats.sort((a, b) => (b.lastMessageAt ?? 0).compareTo(a.lastMessageAt ?? 0));
    return chats;
  }

  /// Живой список чатов — аналог onValue(ref(db,'chats')) в оригинале.
  Stream<DatabaseEvent> watchChats() => _chatsRef.onValue;

  /// Тот же алгоритм id, что и startChatWith() в chats.js:
  /// chatId = [uidA, uidB].sort().join('_') — детерминированный id direct-чата.
  String directChatId(String a, String b) {
    final ids = [a, b]..sort();
    return ids.join('_');
  }

  Future<ChatSummary> getOrCreateDirectChat({
    required String myId,
    required String myName,
    required String otherId,
    required String otherName,
  }) async {
    final chatId = directChatId(myId, otherId);
    final ref = _chatsRef.child(chatId);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({
        'participants': {myId: true, otherId: true},
        'participantNames': {myId: myName, otherId: otherName},
        'createdAt': ServerValue.timestamp,
      });
    }
    final fresh = await ref.get();
    return ChatSummary.fromMap(chatId, Map<dynamic, dynamic>.from(fresh.value as Map));
  }

  Stream<DatabaseEvent> watchMessages(String chatId) =>
      _chatsRef.child('$chatId/messages').orderByChild('createdAt').onValue;

  Future<List<ChatMessage>> listMessages(String chatId, {int limit = 50}) async {
    final snapshot =
        await _chatsRef.child('$chatId/messages').orderByChild('createdAt').limitToLast(limit).get();
    if (!snapshot.exists) return [];
    final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
    final msgs = map.entries
        .map((e) => ChatMessage.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
        .toList();
    msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return msgs;
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    await _chatsRef.child('$chatId/messages').push().set(
          ChatMessage.createMap(senderId: senderId, senderName: senderName, text: text),
        );
    await _chatsRef.child(chatId).update({
      'lastMessage': text,
      'lastMessageAt': ServerValue.timestamp,
    });
  }
}
