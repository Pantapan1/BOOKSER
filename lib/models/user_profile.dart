class UserProfile {
  final String id; // = usr_{timestamp}, ключ в auth_users/*/id и в users/{id}
  final String name;
  final String? avatar;
  final String? bio;
  final int coins;
  final bool isAdmin;
  final bool verified;
  final String? telegramId;
  final int? lastSeen;
  final int? joinedAt;

  UserProfile({
    required this.id,
    required this.name,
    this.avatar,
    this.bio,
    this.coins = 0,
    this.isAdmin = false,
    this.verified = false,
    this.telegramId,
    this.lastSeen,
    this.joinedAt,
  });

  /// [map] — содержимое users/{id} (snapshot.value as Map), [id] — ключ узла.
  factory UserProfile.fromMap(String id, Map<dynamic, dynamic>? map) {
    final m = map ?? const {};
    return UserProfile(
      id: id,
      name: m['name'] as String? ?? 'Читатель',
      avatar: m['avatar'] as String?,
      bio: m['bio'] as String?,
      coins: (m['coins'] as num?)?.toInt() ?? 0,
      isAdmin: m['isAdmin'] as bool? ?? false,
      verified: m['verified'] as bool? ?? false,
      telegramId: m['telegramId']?.toString(),
      lastSeen: (m['lastSeen'] as num?)?.toInt(),
      joinedAt: (m['joinedAt'] as num?)?.toInt(),
    );
  }
}
