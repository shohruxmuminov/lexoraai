import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_entity.dart';
import '../../services/ai_service.dart';

final aiServiceProvider = Provider((ref) => AiService());

class ChatState {
  final List<ChatMessageEntity> messages;
  final bool isStreaming;
  final String? error;
  final String? wordContext;

  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.error,
    this.wordContext,
  });

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isStreaming,
    String? error,
    String? wordContext,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      error: clearError ? null : (error ?? this.error),
      wordContext: wordContext ?? this.wordContext,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._aiService) : super(const ChatState());

  final AiService _aiService;
  final _uuid = const Uuid();

  void setWordContext(String word) {
    state = state.copyWith(
      wordContext: word,
      messages: [
        ChatMessageEntity(
          id: _uuid.v4(),
          role: MessageRole.assistant,
          content: 'Hello! I\'m Lexora AI 🤖\n\nI see you\'re looking at the word **"$word"**. Ask me anything about it — definition, examples, comparisons, or how to use it!',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  void clearContext() {
    state = const ChatState(messages: [
      ChatMessageEntity(
        id: 'welcome',
        role: MessageRole.assistant,
        content: 'Hello! I\'m Lexora AI 🤖\n\nI\'m your personal English language coach. Ask me about any word, grammar rule, or language question!',
        timestamp: null,
      ),
    ]);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.isStreaming) return;

    final userMsg = ChatMessageEntity(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    final assistantMsgId = _uuid.v4();
    final loadingMsg = ChatMessageEntity(
      id: assistantMsgId,
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg, loadingMsg],
      isStreaming: true,
      clearError: true,
    );

    try {
      String fullContent = '';
      final systemPrompt = state.wordContext != null
          ? 'You are Lexora AI, an English language expert. The user is studying the word "${state.wordContext}". Help them understand it deeply.'
          : null;

      await for (final chunk in _aiService.streamChat(
        messages: state.messages.where((m) => !m.isLoading).toList(),
        systemPrompt: systemPrompt,
      )) {
        fullContent += chunk;
        final updatedMessages = state.messages.map((m) {
          if (m.id == assistantMsgId) {
            return m.copyWith(content: fullContent, isLoading: false);
          }
          return m;
        }).toList();
        state = state.copyWith(messages: updatedMessages);
      }
    } catch (e) {
      final updatedMessages = state.messages.map((m) {
        if (m.id == assistantMsgId) {
          return m.copyWith(
            content: 'Sorry, I encountered an error. Please try again.',
            isLoading: false,
          );
        }
        return m;
      }).toList();
      state = state.copyWith(
        messages: updatedMessages,
        isStreaming: false,
        error: e.toString(),
      );
      return;
    }

    state = state.copyWith(isStreaming: false);
  }

  void clearMessages() {
    state = const ChatState();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(aiServiceProvider));
});
