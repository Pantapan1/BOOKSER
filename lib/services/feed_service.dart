import 'package:firebase_database/firebase_database.dart';
import '../core/firebase_client.dart';
import '../models/post.dart';

/// posts/{pushId} — та же структура, что и в оригинальном feed.js.
class FeedService {
  DatabaseReference get _postsRef => Db.ref('posts');

  Future<List<Post>> listPosts({int limit = 50}) async {
    final snapshot = await _postsRef.orderByChild('createdAt').limitToLast(limit).get();
    if (!snapshot.exists) return [];
    final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
    final posts = map.entries
        .map((e) => Post.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
        .toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  /// Живая лента — аналог onValue(ref(db, 'posts')) в оригинале.
  Stream<DatabaseEvent> watchPosts() => _postsRef.onValue;

  Future<void> createPost({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    String? title,
    required String text,
    List<String> images = const [],
  }) async {
    final post = Post(
      id: '',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      title: title,
      text: text,
      images: images,
      createdAt: 0,
    );
    await _postsRef.push().set(post.toCreateMap());
  }

  Future<void> deletePost(String id) => _postsRef.child(id).remove();
}
