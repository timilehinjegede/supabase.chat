class ChatMessage {
  final String? id;
  final String content;
  final String userId;
  final String userDisplayName;
  final DateTime createdAt;
  final String? imagePath;

  ChatMessage({
    this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.userDisplayName,
    this.imagePath,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      userId: map['user_id'],
      userDisplayName: map['user_display_name'],
      imagePath: map['image_path'],
    );
  }

  static (String, String) idAndCreatedAtKeys() {
    return ('id', 'created_at');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'user_display_name': userDisplayName,
      'image_path': imagePath,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    String? userId,
    String? userDisplayName,
    String? imagePath,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
