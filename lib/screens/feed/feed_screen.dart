import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../core/session_state.dart';
import '../../models/post.dart';
import '../../services/feed_service.dart';
import 'widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _feedService = FeedService();

  List<Post> _parse(DatabaseEvent event) {
    final value = event.snapshot.value;
    if (value == null) return [];
    final map = Map<dynamic, dynamic>.from(value as Map);
    final posts = map.entries
        .map((e) => Post.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
        .toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  Future<void> _openCompose() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новый пост'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Что нового?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Опубликовать'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;

    final me = context.read<SessionState>().profile!;
    await _feedService.createPost(authorId: me.id, authorName: me.name, authorAvatar: me.avatar, text: text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лента')),
      body: StreamBuilder<DatabaseEvent>(
        stream: _feedService.watchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) return const Center(child: Text('Пока нет постов'));
          final posts = _parse(snapshot.data!);
          if (posts.isEmpty) return const Center(child: Text('Пока нет постов'));
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, i) => PostCard(post: posts[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCompose,
        child: const Icon(Icons.add),
      ),
    );
  }
}
