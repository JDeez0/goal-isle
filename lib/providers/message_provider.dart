import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // DISABLED FOR MOCKUP
import 'package:goal_isle/models/message.dart';

class MessageNotifier extends StateNotifier<List<Message>> {
  MessageNotifier() : super([]);

  Future<void> fetchMessages(String isleId) async {
    // DISABLED FOR MOCKUP - Return mock messages for demonstration
    final now = DateTime.now();
    state = [
      Message(
        id: 'msg-1',
        isleId: isleId,
        senderId: 'mock-user-id',
        content: 'Just started this journey! 💪',
        contentType: 'text',
        reactions: [],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Message(
        id: 'msg-2',
        isleId: isleId,
        senderId: 'friend-alice',
        content: 'You can do it! Keep going! 🌟',
        contentType: 'text',
        reactions: [
          {'emoji': '💪', 'count': 1, 'user_id': 'mock-user-id'}
        ],
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      Message(
        id: 'msg-3',
        isleId: isleId,
        senderId: 'mock-user-id',
        content: 'Thanks for the encouragement! 🙏',
        contentType: 'text',
        reactions: [],
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  Future<void> sendMessage({
    required String isleId,
    required String content,
    String contentType = 'text',
  }) async {
    // DISABLED FOR MOCKUP - Add to local state for demo
    final newMessage = Message(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      isleId: isleId,
      senderId: 'mock-user-id',
      content: content,
      contentType: contentType,
      reactions: [],
      createdAt: DateTime.now(),
    );
    
    state = [...state, newMessage];
  }
}

final messageProvider = StateNotifierProvider<MessageNotifier, List<Message>>((ref) {
  return MessageNotifier();
});
