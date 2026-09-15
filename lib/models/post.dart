import 'package:firebase_database/firebase_database.dart' show ServerValue;

class Post {
  final String id; // ключ push() в posts/
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String? title;
  final String text;
  final List<String> images;
  final String? background;
  final String? backgroundImage;
  final int createdAt;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.title,
    required this.text,
    this.images = const [],
    this.background,
    this.backgroundImage,
    required this.createdAt,
  });

  factory Post.fromMap(String id, Map<dynamic, dynamic> m) {
    final rawImages = m['images'];
    List<String> images = const [];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    } else if (rawImages is Map) {
      images = rawImages.values.map((e) => e.toString()).toList();
    }
    return Post(
      id: id,
      authorId: m['authorId']?.toString() ?? '',
      authorName: m['authorName'] as String? ?? 'Читатель',
      authorAvatar: m['authorAvatar'] as String?,
      title: m['title'] as String?,
      text: m['text'] as String? ?? '',
      images: images,
      background: m['background'] as String?,
      backgroundImage: m['backgroundImage'] as String?,
      createdAt: (m['createdAt'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'title': title,
        'images': images,
        'text': text,
        'background': backgroundImage != null ? null : background,
        'backgroundImage': backgroundImage,
        'createdAt': ServerValue.timestamp,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar ?? '',
      };
}
