import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets/spark_widget.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/message.dart';
import '../../../core/models/spark.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// Isle Chat — the room for a single Isle. The app bar shows a tappable mini
/// spark that drops down a recipe card (the isle's main key). The message list
/// is reversed (newest at the bottom). Sending a message that exactly matches a
/// main-spark dependency emoji satisfies that dependency and, when all deps are
/// met, lights the spark (state=lit, streak+1).
class IsleChatScreen extends ConsumerStatefulWidget {
  const IsleChatScreen({super.key});

  @override
  ConsumerState<IsleChatScreen> createState() => _IsleChatScreenState();
}

class _IsleChatScreenState extends ConsumerState<IsleChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _canSend = false;
  bool _recipeOpen = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onInputChanged() =>
      setState(() => _canSend = _inputController.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final isleId = ref.watch(activeIsleIdProvider);
    final isles = ref.watch(islesProvider);
    final Isle? isle = isles.where((i) => i.id == isleId).firstOrNull;

    if (isle == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
            onPressed: () => context.go('/isle'),
          ),
        ),
        body: const Center(
          child: Text('Isle not found',
              style: TextStyle(color: Color(0xFF94A3B8))),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: _ChatAppBar(
        isle: isle,
        recipeOpen: _recipeOpen,
        onToggleRecipe: () => setState(() => _recipeOpen = !_recipeOpen),
        onBack: () => context.go('/isle'),
        onInfo: () {
          // Set activeSparkId to the isle's main spark before navigating
          final mainSpark = isle.sparks.where((s) => s.isMain).firstOrNull;
          if (mainSpark != null) {
            ref.read(activeSparkIdProvider.notifier).state = mainSpark.id;
          }
          context.go('/spark');
        },
      ),
      body: Column(
        children: [
          // Recipe dropdown card (below the app bar).
          if (_recipeOpen)
            _RecipeDropdown(isle: isle),
          // Message list.
          Expanded(
            child: _MessageList(
              isle: isle,
              scrollController: _scrollController,
            ),
          ),
          // Composer.
          _Composer(
            controller: _inputController,
            canSend: _canSend,
            onSend: _sendMessage,
            onEmoji: () => _showEmojiSheet(context),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final isleId = ref.read(activeIsleIdProvider);
    if (isleId == null) return;
    final me = ref.read(currentUserProvider);

    // Determine whether the text is a single emoji that satisfies a main-spark
    // dependency. If so, light it + bump the streak.
    final isles = ref.read(islesProvider);
    final Isle? isle = isles.where((i) => i.id == isleId).firstOrNull;
    Spark? litSpark = _maybeLightSpark(isle, text);

    // Compose the message. A single-emoji body renders big.
    final isEmojiOnly = _isSingleEmoji(text);
    final message = Message(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      chatId: isleId,
      senderId: currentAuthId() ?? me.id,
      senderName: me.name,
      senderAvatar: me.avatar,
      content: isEmojiOnly ? null : text,
      big: isEmojiOnly ? text : null,
      createdAt: DateTime.now(),
    );

    ref.read(islesProvider.notifier).addMessage(isleId, message);
    if (litSpark != null) {
      ref.read(islesProvider.notifier).updateSpark(isleId, litSpark);
    }

    _inputController.clear();
  }

  /// If [text] exactly matches a main-spark dependency emoji, satisfy that dep
  /// and, when every dependency is satisfied, light the spark (streak +1).
  /// Returns the updated [Spark] to persist, or `null` if nothing matched.
  Spark? _maybeLightSpark(Isle? isle, String text) {
    if (isle == null) return null;
    final Spark? main = isle.sparks
        .where((s) => s.isMain)
        .firstOrNull;
    if (main == null) return null;

    final depIndex =
        main.dependencies.indexWhere((d) => d.emoji == text && !d.satisfied);
    if (depIndex < 0) return null;

    // Mark the matched dependency satisfied.
    final deps = [
      for (int i = 0; i < main.dependencies.length; i++)
        if (i == depIndex)
          main.dependencies[i].copyWith(satisfied: true)
        else
          main.dependencies[i],
    ];
    final allSatisfied = deps.every((d) => d.satisfied);

    // Don't re-light an already lit spark.
    if (allSatisfied &&
        (main.state == SparkState.lit ||
            main.state == SparkState.streaked)) {
      return main.copyWith(dependencies: deps);
    }

    return main.copyWith(
      dependencies: deps,
      state: allSatisfied ? SparkState.lit : main.state,
      streak: allSatisfied ? main.streak + 1 : main.streak,
      lastCompletedAt: allSatisfied ? DateTime.now() : main.lastCompletedAt,
    );
  }

  void _showEmojiSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EmojiSheet(
        onPick: (emoji) {
          _inputController.text = _inputController.text + emoji;
          _inputController.selection = TextSelection.fromPosition(
            TextPosition(offset: _inputController.text.length),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Heuristic: treat the trimmed text as a single emoji if it's short and
  /// contains no ASCII letters/digits/punctuation.
  bool _isSingleEmoji(String text) {
    final cleaned = text.trim();
    if (cleaned.isEmpty || cleaned.runes.length > 4) return false;
    return RegExp(r'^[^\p{L}\p{N}\p{P}\s]+$',
            unicode: true, caseSensitive: false)
        .hasMatch(cleaned);
  }
}

// -----------------------------------------------------------------------------
// App bar — mini spark + chevron (toggles recipe), info button (→ /spark).
// -----------------------------------------------------------------------------

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.isle,
    required this.recipeOpen,
    required this.onToggleRecipe,
    required this.onBack,
    required this.onInfo,
  });

  final Isle isle;
  final bool recipeOpen;
  final VoidCallback onToggleRecipe;
  final VoidCallback onBack;
  final VoidCallback onInfo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Spark? main = isle.sparks.where((s) => s.isMain).firstOrNull;
    return AppBar(
      backgroundColor: const Color(0xFFF7F8FA),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
        onPressed: onBack,
      ),
      title: GestureDetector(
        onTap: onToggleRecipe,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (main != null)
              SparkWidget(
                emoji: main.emoji,
                state: main.state,
                size: 34,
                showSparkles: false,
              )
            else
              Text(isle.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Icon(
              recipeOpen ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
          onPressed: onInfo,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Recipe dropdown — the isle's main key recipe (deps = hero on one line).
// -----------------------------------------------------------------------------

class _RecipeDropdown extends StatelessWidget {
  const _RecipeDropdown({required this.isle});
  final Isle isle;

  @override
  Widget build(BuildContext context) {
    final Spark? main = isle.sparks.where((s) => s.isMain).firstOrNull;
    if (main == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text('No main key for this Isle.',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
      );
    }
    final deps = main.dependencies;

    return Material(
      color: Colors.white,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFECEFF2))),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              main.title ?? 'Main key',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final d in deps) ...[
                  Text(d.emoji,
                      style: TextStyle(
                          fontSize: 26,
                          color: d.satisfied
                              ? const Color(0xFF1F2937)
                              : const Color(0x551F2937))),
                  if (d != deps.last)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('+',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFFCBD5E1))),
                    ),
                ],
                if (deps.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('=',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF94A3B8))),
                  ),
                SparkWidget(
                  emoji: main.emoji,
                  state: main.state,
                  size: 40,
                  showSparkles: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Message list — reversed so newest sits at the bottom.
// -----------------------------------------------------------------------------

class _MessageList extends ConsumerWidget {
  const _MessageList({required this.isle, required this.scrollController});
  final Isle isle;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meId = ref.watch(currentUserProvider).id;
    final msgs = isle.msgs;

    if (msgs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No messages yet.\nSay hello 👋',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: msgs.length,
      itemBuilder: (context, index) {
        // Reversed list: index 0 is the newest.
        final message = msgs[msgs.length - 1 - index];
        final isMe = message.senderId == meId;
        return _MessageBubble(
          message: message,
          isMe: isMe,
          onLongPress: () => _react(context, ref, message),
        );
      },
    );
  }

  void _react(BuildContext context, WidgetRef ref, Message message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('React',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Text('🔥', style: TextStyle(fontSize: 24)),
                title: const Text('Fire'),
                onTap: () {
                  _addReaction(ref, message);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addReaction(WidgetRef ref, Message message) {
    // Add (or extend) a 🔥 reaction from the current user.
    final existing = message.reactions
        .where((r) => r.emoji == '🔥')
        .firstOrNull;
    final meId = ref.read(currentUserProvider).id;
    final updatedReactions = [
      for (final r in message.reactions)
        if (r.emoji == '🔥')
          r.copyWith(
            users: r.users.contains(meId)
                ? r.users
                : [...r.users, meId],
          )
        else
          r,
      if (existing == null)
        MessageReaction(emoji: '🔥', users: [meId]),
    ];
    ref
        .read(islesProvider.notifier)
        .updateMessage(isle.id, message.copyWith(reactions: updatedReactions));
  }
}

// -----------------------------------------------------------------------------
// Message bubble — sender name (if not me), content (text or big emoji),
// timestamp, reactions.
// -----------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.onLongPress,
  });

  final Message message;
  final bool isMe;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isBig = message.big != null && message.big!.isNotEmpty;
    final body = isBig ? message.big! : (message.content ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message.senderAvatar,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(message.senderName,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B))),
                ],
              ),
            ),
          GestureDetector(
            onLongPress: onLongPress,
            child: _bubble(isBig, body),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              _formatTime(message.createdAt),
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF94A3B8)),
            ),
          ),
          if (message.reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final r in message.reactions)
                    _ReactionChip(emoji: r.emoji, count: r.users.length),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _bubble(bool isBig, String body) {
    if (isBig) {
      // Big emoji messages render without a bubble background.
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(body, style: const TextStyle(fontSize: 42)),
        ),
      );
    }
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF3B82F6) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            border: isMe
                ? null
                : Border.all(color: const Color(0xFFECEFF2)),
          ),
          child: Text(
            body,
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              color: isMe ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    final amPm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $amPm';
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({required this.emoji, required this.count});
  final String emoji;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFECEFF2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text('$count',
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Composer — round emoji button (left) + pill input (center) + round send (right).
// -----------------------------------------------------------------------------

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.canSend,
    required this.onSend,
    required this.onEmoji,
  });

  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;
  final VoidCallback onEmoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFECEFF2))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Emoji button (round).
              Material(
                color: const Color(0xFFF1F5F9),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onEmoji,
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Center(
                      child: Text('😊', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Pill-shaped input.
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 5,
                    style: const TextStyle(
                        fontSize: 15, color: Color(0xFF1F2937)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10),
                      hintText: 'Message…',
                      hintStyle:
                          TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button (round).
              Material(
                color: canSend
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFE2E8F0),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: canSend ? onSend : null,
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: canSend
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Emoji sheet — a small grid of common emojis that insert into the input.
// -----------------------------------------------------------------------------

class _EmojiSheet extends StatelessWidget {
  const _EmojiSheet({required this.onPick});
  final ValueChanged<String> onPick;

  static const List<String> _emojis = [
    '🔥', '👍', '❤️', '🎉', '🙌', '😂', '💪', '✨',
    '📈', '📚', '🏃', '💧', '🧩', '📖', '🎓', '⏱️',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Insert emoji',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
              children: [
                for (final e in _emojis)
                  GestureDetector(
                    onTap: () => onPick(e),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
