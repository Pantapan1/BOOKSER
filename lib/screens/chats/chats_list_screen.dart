import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../core/firebase_client.dart';
import '../../core/session_state.dart';
import '../../models/chat.dart';
import '../../services/chat_service.dart';
import 'chat_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final _chatService = ChatService();

  List<ChatSummary> _parse(DatabaseEvent event, String myId) {
    final value = event.snapshot.value;
    if (value == null) return [];
    final map = Map<dynamic, dynamic>.from(value as Map);
    final chats = map.entries
        .map((e) => ChatSummary.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
        .where((c) => c.participants.containsKey(myId))
        .toList();
    chats.sort((a, b) => (b.lastMessageAt ?? 0).compareTo(a.lastMessageAt ?? 0));
    return chats;
  }

  Future<void> _openNewChatPicker() async {
    final me = context.read<SessionState>().profile!;
    final snapshot = await Db.ref('users').get();
    if (!snapshot.exists) return;
    final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
    final entries = map.entries.where((e) => e.key.toString() != me.id).toList();

    if (!mounted) return;
    final picked = await showModalBottomSheet<MapEntry<dynamic, dynamic>>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: entries.map((e) {
          final name = (e.value as Map)['name'] as String? ?? 'Читатель';
          return ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(name),
            onTap: () => Navigator.pop(ctx, e),
          );
        }).toList(),
      ),
    );
    if (picked == null) return;

    final otherId = picked.key.toString();
    final otherName = (picked.value as Map)['name'] as String? ?? 'Читатель';
    final chat = await _chatService.getOrCreateDirectChat(
      myId: me.id,
      myName: me.name,
      otherId: otherId,
      otherName: otherName,
    );
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)));
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<SessionState>().profile;
    if (me == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Чаты')),
      body: StreamBuilder<DatabaseEvent>(
        stream: _chatService.watchChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.hasData ? _parse(snapshot.data!, me.id) : <ChatSummary>[];
          if (chats.isEmpty) return const Center(child: Text('Пока нет чатов'));
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, i) {
              final chat = chats[i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
                title: Text(chat.displayName(me.id)),
                subtitle: chat.lastMessage != null ? Text(chat.lastMessage!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(chat: chat))),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewChatPicker,
        child: const Icon(Icons.add_comment_outlined),
      ),
    );
  }
}
