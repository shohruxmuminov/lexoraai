enum MessageRole { user, assistant, system }
enum MessageType { text, comparison, quiz, translation, grammar }

class ChatSessionEntity {
  final String id;
  final String? wordContext;
  final String title;
  final List<ChatMessageEntity> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSessionEntity({
    required this.id,
    this.wordContext,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });
}

class ChatMessageEntity {
  final String id;
  final MessageRole role;
  final String content;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessageEntity({
    required this.id,
    required this.role,
    required this.content,
    this.type = MessageType.text,
    this.metadata,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessageEntity copyWith({
    String? content,
    bool? isLoading,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageEntity(
      id: id,
      role: role,
      content: content ?? this.content,
      type: type,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
