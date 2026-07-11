import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/message.dart';
import '../../../core/models/spark.dart';
import '../../../core/repositories/mock/mock_providers.dart';
import '../../../core/repositories/supabase/supabase_repository.dart';
import '../../../core/utils/debug_label.dart';

/// Spark Thread — a read-only view of a single Spark's log/thread messages.
///
/// Each message renders as a chat bubble: mine on the right (accent),
/// others on the left (white). Big-emoji messages render larger. There is no
/// composer — new logs are added via the Metric Log sheet from Spark Details.
class SparkThreadScreen extends ConsumerStatefulWidget {
  const SparkThreadScreen({super.key});

  @override
  ConsumerState<SparkThreadScreen> createState() => _SparkThreadScreenState();
}

class _SparkThreadScreenState extends ConsumerState<SparkThreadScreen> {
  List<Message> _messages = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    final sparkId = ref.read(activeSparkIdProvider);
    if (sparkId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final msgs = await SupabaseRepository.fetchMessages('thread-$sparkId');
      // Merge: combine fetched messages with any optimistic local ones
      // that haven't synced yet (by id).
      final isleId = ref.read(activeIsleIdProvider);
      final isles = ref.read(islesProvider);
      final isle = isles.where((i) => i.id == isleId).firstOrNull;
      final spark = isle?.sparks.where((s) => s.id == sparkId).firstOrNull;
      final localMsgs = spark?.thread ?? <Message>[];
      final fetchedIds = msgs.map((m) => m.id).toSet();
      final localOnly = localMsgs.where((m) => !fetchedIds.contains(m.id)).toList();
      final all = [...msgs, ...localOnly]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (mounted) setState(() { _messages = all; _loading = false; });
    } catch (e) {
      // Fall back to local thread if fetch fails
      final isleId = ref.read(activeIsleIdProvider);
      final isles = ref.read(islesProvider);
      final isle = isles.where((i) => i.id == isleId).firstOrNull;
      final spark = isle?.sparks.where((s) => s.id == sparkId).firstOrNull;
      if (mounted) setState(() { _messages = spark?.thread ?? []; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isleId = ref.watch(activeIsleIdProvider);
    final sparkId = ref.watch(activeSparkIdProvider);
    final isles = ref.watch(islesProvider);
    final isle = isles.where((i) => i.id == isleId).firstOrNull;
    final Spark? spark =
        isle?.sparks.where((s) => s.id == sparkId).firstOrNull;

    if (spark == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
            onPressed: () => context.go('/spark'),
          ).labeled('ST-00'),
        ),
        body: const Center(
          child: Text('Thread not found',
              style: TextStyle(color: Color(0xFF94A3B8))),
        ).labeled('ST-00-err'),
      );
    }

    final meId = ref.watch(currentUserProvider).id;
    // Use fetched messages if loaded, otherwise fall back to local thread
    final messages = _loading ? spark.thread : _messages;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/spark'),
        ).labeled('ST-01'),
        title: Text(spark.title ?? 'Thread').labeled('ST-02'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadMessages(),
        child: messages.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 200),
                  const _EmptyThread().labeled('ST-05'),
                ],
              ).labeled('ST-04')
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final msg = messages[messages.length - 1 - i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ThreadBubble(message: msg, isMe: msg.senderId == meId).labeled('ST-${i + 6}'),
                  );
                },
              ).labeled('ST-list'),
      ).labeled('ST-03'),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('💬', style: TextStyle(fontSize: 40)),
          SizedBox(height: 10),
          Text('No logs yet',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
          SizedBox(height: 4),
          Text('Logs you add from the Spark show up here.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

class _ThreadBubble extends StatelessWidget {
  const _ThreadBubble({required this.message, required this.isMe});
  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final isBig = message.big != null && message.big!.isNotEmpty;
    final body = isBig ? message.big! : (message.content ?? '');

    return Row(
      mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe) ...[
          Text(message.senderAvatar, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 3),
                  child: Text(message.senderName,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8))),
                ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isBig ? 6 : 14,
                  vertical: isBig ? 6 : 10,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFF3B82F6)
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft:
                        isMe ? const Radius.circular(16) : Radius.zero,
                    bottomRight:
                        isMe ? Radius.zero : const Radius.circular(16),
                  ),
                  border: isMe
                      ? null
                      : Border.all(color: const Color(0xFFECEFF2)),
                ),
                child: isBig
                    ? Text(body,
                        style: TextStyle(
                            fontSize: 34,
                            height: 1.1,
                            color: isMe
                                ? Colors.white
                                : const Color(0xFF1F2937)))
                    : Text(body,
                        style: TextStyle(
                            fontSize: 14,
                            height: 1.3,
                            color: isMe
                                ? Colors.white
                                : const Color(0xFF1F2937))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
