import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goal_isle/providers/message_provider.dart';
import 'package:goal_isle/providers/sub_point_provider.dart';
import 'package:goal_isle/providers/goal_provider.dart';
import 'package:goal_isle/providers/auth_provider.dart' as auth;
import 'package:goal_isle/models/sub_point.dart';
import 'package:goal_isle/models/goal.dart';
import 'package:goal_isle/models/message.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // DISABLED FOR MOCKUP
// import 'dart:io'; // REMOVED - dart:io is not compatible with Flutter web

class ChatScreen extends StatefulWidget {
  final String isleId;
  final String isleName;

  const ChatScreen({
    super.key,
    required this.isleId,
    required this.isleName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  Goal? _goal;
  List<SubPoint> _subPoints = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Need to use ref properly inside initState
      // This will be called later when widget is built with Consumer
    } catch (e) {
      print('Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadDataWithRef(WidgetRef ref) async {
    setState(() => _isLoading = true);

    try {
      // Fetch goal for this isle
      await ref.read(goalProvider.notifier).fetchGoals(widget.isleId);
      final goals = ref.read(goalProvider);
      
      if (goals.isNotEmpty) {
        setState(() => _goal = goals.first);
        
        // Fetch sub-points for this goal
        await ref.read(subPointProvider.notifier).fetchSubPoints(_goal!.id);
        setState(() => _subPoints = ref.read(subPointProvider));
      }

      // Fetch messages
      await ref.read(messageProvider.notifier).fetchMessages(widget.isleId);
    } catch (e) {
      print('Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final messages = ref.watch(messageProvider);
        final currentUser = ref.watch(auth.authProvider);

        // First load if not already loading
        if (_isLoading && messages.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadDataWithRef(ref);
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E17),
          appBar: AppBar(
            title: Text(widget.isleName),
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadDataWithRef(ref),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    // Sub-points display
                    if (_subPoints.isNotEmpty)
                      Container(
                        height: 80,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1F2E),
                          border: Border(
                            bottom: BorderSide(
                              color: const Color(0xFF374151).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: _subPoints.map<Widget>((subPoint) {
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: _subPoints.indexOf(subPoint) < _subPoints.length - 1 ? 8 : 0,
                                ),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF252B3D),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      subPoint.emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${subPoint.fillCount}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    // Messages list
                    Expanded(
                      child: messages.isEmpty
                          ? const Center(
                              child: Text(
                                'No messages yet. Send one to get started!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final isCurrentUser = message.senderId == currentUser?.id;
                                
                                return _buildMessageBubble(message, isCurrentUser, ref);
                              },
                            ),
                    ),

                    // Message input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        border: Border(
                          top: BorderSide(
                            color: const Color(0xFF374151).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Message...',
                                hintStyle: const TextStyle(color: Colors.white38),
                                filled: true,
                                fillColor: const Color(0xFF252B3D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _isUploading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF60A5FA),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.photo_camera),
                                  onPressed: () => _pickImage(ref),
                                  color: const Color(0xFF60A5FA),
                                ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _isUploading ? null : () => _sendMessage(ref),
                            color: const Color(0xFF60A5FA),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMessageBubble(dynamic message, bool isCurrentUser, WidgetRef ref) {
    return Column(
      crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            bottom: 8,
            right: isCurrentUser ? 0 : 40,
            left: isCurrentUser ? 40 : 0,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrentUser ? const Color(0xFF60A5FA) : const Color(0xFF252B3D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show image if available
              if (message.contentType == 'image' && message.content != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.content,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Show text content
              if (message.content != null && message.contentType != 'image')
                Text(
                  message.content ?? '', // ✅ SAFE: Use null-aware operator
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              
              if (message.reactions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: message.reactions.map<Widget>((reaction) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            reaction['emoji'] as String,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reaction['count'] as int}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        if (message.reactions.isEmpty && _subPoints.isNotEmpty)
          _buildReactionRow(message, isCurrentUser, ref),
      ],
    );
  }

  Widget _buildReactionRow(dynamic message, bool isCurrentUser, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(
        left: isCurrentUser ? 0 : 4,
        right: isCurrentUser ? 4 : 0,
        bottom: 8,
      ),
      child: Row(
        children: _subPoints.map<Widget>((subPoint) {
          return GestureDetector(
            onTap: () => _addReaction(message.id, subPoint.emoji, ref),
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF252B3D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subPoint.emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'React',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _sendMessage(WidgetRef ref) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await ref.read(messageProvider.notifier).sendMessage(
      isleId: widget.isleId,
      content: text,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage(WidgetRef ref) async {
    // MOCKUP MODE - Simulate image upload with placeholder
    setState(() => _isUploading = true);
    
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Add a mock image message
    await ref.read(messageProvider.notifier).sendMessage(
      isleId: widget.isleId,
      content: 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
      contentType: 'image',
    );
    
    setState(() => _isUploading = false);
    _scrollToBottom();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mock image uploaded! 📷'),
        backgroundColor: Color(0xFF34D399),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _fillSubPointForUpload(String imageUrl, WidgetRef ref) async {
    // DISABLED FOR MOCKUP - No auto-fill
  }

  Future<void> _addReaction(String messageId, String emoji, WidgetRef ref) async {
    // MOCKUP MODE - Add reaction locally for demo
    final messages = ref.read(messageProvider);
    final messageIndex = messages.indexWhere((m) => m.id == messageId);
    
    if (messageIndex == -1) return;
    
    final message = messages[messageIndex];
    final existingReactionIndex = message.reactions.indexWhere((r) => r['emoji'] == emoji);
    
    List<Map<String, dynamic>> newReactions;
    if (existingReactionIndex >= 0) {
      // Update existing reaction count
      newReactions = List.from(message.reactions);
      newReactions[existingReactionIndex] = {
        'emoji': emoji,
        'count': (newReactions[existingReactionIndex]['count'] as int) + 1,
        'user_id': 'mock-user-id',
      };
    } else {
      // Add new reaction
      newReactions = [
        ...message.reactions,
        {'emoji': emoji, 'count': 1, 'user_id': 'mock-user-id'}
      ];
    }
    
    // Create updated message
    final updatedMessage = Message(
      id: message.id,
      isleId: message.isleId,
      senderId: message.senderId,
      content: message.content,
      contentType: message.contentType,
      reactions: newReactions,
      createdAt: message.createdAt,
    );
    
    // Update the state
    final updatedMessages = List<Message>.from(messages);
    updatedMessages[messageIndex] = updatedMessage;
    ref.read(messageProvider.notifier).state = updatedMessages;
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $emoji reaction!'),
        backgroundColor: const Color(0xFF34D399),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}