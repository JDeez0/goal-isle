import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/message.dart';
import '../../../core/models/spark.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// Spark Thread — a read-only view of a single Spark's log/thread messages.
///
/// Each message renders as a chat bubble: mine on the right (accent),
/// others on the left (white). Big-emoji messages render larger. There is no
/// composer — new logs are added via the Metric Log sheet from Spark Details.
class SparkThreadScreen extends ConsumerWidget {
  const SparkThreadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          ),
        ),
        body: const Center(
          child: Text('Thread not found',
              style: TextStyle(color: Color(0xFF94A3B8))),
        ),
      );
    }

    final meId = ref.watch(currentUserProvider).id;
    final messages = spark.thread;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/spark'),
        ),
        title: Text(spark.title ?? 'Thread'),
      ),
      body: messages.isEmpty
          ? const _EmptyThread()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[messages.length - 1 - i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ThreadBubble(message: msg, isMe: msg.senderId == meId),
                );
              },
            ),
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
