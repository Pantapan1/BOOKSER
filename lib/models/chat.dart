import 'package:firebase_database/firebase_database.dart' show ServerValue;

class ChatSummary {
  final String id;
  final String type; // 'direct' (по умолчанию) | 'group'
  final String? name; // только для групп
  final String? avatar; // только для групп
  final String? adminId; // только для групп
  final Map<String, bool> participants; // {uid: true}
  final Map<String, String> participantNames; // {uid: name}
  final String? lastMessage;
  final int? lastMessageAt;

  ChatSummary({
    required this.id,
    this.type = 'direct',
    this.name,
    this.avatar,
    this.adminId,
    required this.participants,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatSummary.fromMap(String id, Map<dynamic, dynamic> m) {
    Map<String, bool> parts = {};
    final rawParts = m['participants'];
    if (rawParts is Map) {
      parts = rawParts.map((k, v) => MapEntry(k.toString(), v == true));
    }
    Map<String, String> names = {};
    final rawNames = m['participantNames'];
    if (rawNames is Map) {
      names = rawNames.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return ChatSummary(
      id: id,
      type: m['type'] as String? ?? 'direct',
      name: m['name'] as String?,
      avatar: m['avatar'] as String?,
      adminId: m['adminId'] as String?,
      participants: parts,
      participantNames: names,
      lastMessage: m['lastMessage'] as String?,
      lastMessageAt: (m['lastMessageAt'] as num?)?.toInt(),
    );
  }

  /// Заголовок в списке чатов: имя группы или имя собеседника (см. otherParticipant() в chats.js).
  String displayName(String myId) {
    if (type == 'group') return name ?? 'Группа';
    final otherId = participants.keys.firstWhere((id) => id != myId, orElse: () => myId);
    return participantNames[otherId] ?? 'Читатель';
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final int createdAt;
  final String? messageStyle; // 'action' | 'thought' | null

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.messageStyle,
  });

  factory ChatMessage.fromMap(String id, Map<dynamic, dynamic> m) {
    return ChatMessage(
      id: id,
      senderId: m['senderId']?.toString() ?? '',
      senderName: m['senderName'] as String? ?? 'Читатель',
      text: m['text'] as String? ?? '',
      createdAt: (m['createdAt'] as num?)?.toInt() ?? 0,
      messageStyle: m['messageStyle'] as String?,
    );
  }

  static Map<String, dynamic> createMap({
    required String senderId,
    required String senderName,
    required String text,
  }) =>
      {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'createdAt': ServerValue.timestamp,
      };
}
