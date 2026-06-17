import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/chat_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<Map<String, String>> _suggestions = [
    {'emoji': '⚔️', 'text': 'Make vs Do — what\'s the difference?'},
    {'emoji': '📚', 'text': 'Explain IELTS Academic vocabulary'},
    {'emoji': '🔤', 'text': 'How to use "however" correctly?'},
    {'emoji': '🎯', 'text': 'Top 10 words for IELTS Writing Task 2'},
    {'emoji': '🗣️', 'text': 'How to improve my English speaking?'},
    {'emoji': '✍️', 'text': 'Check my English: "I am very boring today"'},
  ];

  @override
  void initState() {
    super.initState();
    ref.read(chatProvider.notifier).clearContext();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasMessages = chatState.messages.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lexora AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                Text(
                  chatState.isStreaming ? 'Typing...' : 'Online',
                  style: TextStyle(
                    fontSize: 11,
                    color: chatState.isStreaming ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? AppColors.textWhite50 : AppColors.textLight,
            ),
            onPressed: () => ref.read(chatProvider.notifier).clearMessages(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Messages or welcome screen
          Expanded(
            child: hasMessages
                ? _MessagesList(messages: chatState.messages, isDark: isDark, scrollCtrl: _scrollCtrl)
                : _WelcomeView(suggestions: _suggestions, onSuggestionTap: _send),
          ),

          // Input area
          _InputBar(
            ctrl: _ctrl,
            isDark: isDark,
            isStreaming: chatState.isStreaming,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    ref.read(chatProvider.notifier).sendMessage(text.trim());
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
}

class _WelcomeView extends StatelessWidget {
  final List<Map<String, String>> suggestions;
  final Function(String) onSuggestionTap;

  const _WelcomeView({required this.suggestions, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // AI avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 42),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 20),

          Text(
            'Hello! I\'m Lexora AI 👋',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

          const SizedBox(height: 8),

          Text(
            'Your personal English coach powered by GPT-4o.\nAsk me anything about English!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textWhite50 : AppColors.textMedium,
              height: 1.5,
            ),
          ).animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: 32),

          // Capabilities chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _capChip('Word Explanations', Icons.book_rounded),
              _capChip('Grammar Help', Icons.spellcheck_rounded),
              _capChip('Translations', Icons.translate_rounded),
              _capChip('Writing Check', Icons.edit_rounded),
              _capChip('Word Comparisons', Icons.compare_arrows_rounded),
              _capChip('Study Plans', Icons.calendar_today_rounded),
            ],
          ).animate(delay: 400.ms).fadeIn(),

          const SizedBox(height: 32),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Try asking:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),

          ...suggestions.map((s) => _SuggestionTile(
            emoji: s['emoji']!,
            text: s['text']!,
            onTap: onSuggestionTap,
          ).animate(delay: 500.ms).fadeIn().slideX(begin: -0.1, end: 0)),
        ],
      ),
    );
  }

  Widget _capChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String emoji;
  final String text;
  final Function(String) onTap;

  const _SuggestionTile({required this.emoji, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
            ),
            Icon(Icons.north_east_rounded, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final List messages;
  final bool isDark;
  final ScrollController scrollCtrl;

  const _MessagesList({required this.messages, required this.isDark, required this.scrollCtrl});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final msg = messages[i];
        final isUser = msg.role.toString().contains('user');
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8, top: 2),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 16),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomRight: isUser ? const Radius.circular(4) : null,
                      bottomLeft: !isUser ? const Radius.circular(4) : null,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: msg.isLoading
                      ? _dots()
                      : SelectableText(
                          msg.content,
                          style: TextStyle(
                            color: isUser ? Colors.white : (isDark ? Colors.white : AppColors.textDark),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _dots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: AppColors.textLight,
          shape: BoxShape.circle,
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(delay: Duration(milliseconds: i * 150), duration: 600.ms)),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool isDark;
  final bool isStreaming;
  final Function(String) onSend;

  const _InputBar({
    required this.ctrl,
    required this.isDark,
    required this.isStreaming,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: TextField(
                controller: ctrl,
                maxLines: null,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask Lexora AI...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.textWhite30 : AppColors.textLight,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onSend(ctrl.text),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: isStreaming ? null : AppColors.primaryGradient,
                color: isStreaming ? AppColors.primary.withOpacity(0.3) : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: isStreaming
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
