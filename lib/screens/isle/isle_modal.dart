import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goal_isle/models/isle.dart';
import 'package:goal_isle/screens/chat/chat_screen.dart';
import 'package:goal_isle/providers/goal_provider.dart';
import 'package:goal_isle/providers/sub_point_provider.dart';
import 'package:goal_isle/models/goal.dart';
import 'package:goal_isle/models/sub_point.dart';

class IsleModal extends ConsumerStatefulWidget {
  final Isle isle;

  const IsleModal({super.key, required this.isle});

  @override
  ConsumerState<IsleModal> createState() => _IsleModalState();
}

class _IsleModalState extends ConsumerState<IsleModal> {
  Goal? _goal;
  List<SubPoint> _subPoints = [];

  @override
  void initState() {
    super.initState();
    _loadGoalAndSubPoints();
  }

  Future<void> _loadGoalAndSubPoints() async {
    // Create some mock goals and sub-points for demonstration
    // Fix: Use local variable to avoid null check race condition
    final goalId = 'mock-goal-${widget.isle.id}';
    
    setState(() {
      _goal = Goal(
        id: goalId,
        isleId: widget.isle.id,
        emoji: widget.isle.mainEmoji,
        text: 'Main goal for ${widget.isle.name}',
        metadata: {},
        createdAt: DateTime.now(),
      );
      
      // Create mock sub-points based on the isle
      if (widget.isle.name.contains('Fitness')) {
        _subPoints = [
          SubPoint(
            id: 'mock-sub-1',
            goalId: goalId, // ✅ SAFE: Use local variable instead of _goal!.id
            emoji: '🏃',
            description: 'Run for 30 minutes',
            fillCount: 12,
            lastFilledAt: DateTime.now().subtract(Duration(hours: 25)),
            fillHistory: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          SubPoint(
            id: 'mock-sub-2',
            goalId: goalId, // ✅ SAFE: Use local variable
            emoji: '💧',
            description: 'Drink 8 glasses of water',
            fillCount: 8,
            lastFilledAt: DateTime.now().subtract(Duration(hours: 2)),
            fillHistory: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
      } else if (widget.isle.name.contains('Spanish')) {
        _subPoints = [
          SubPoint(
            id: 'mock-sub-3',
            goalId: goalId, // ✅ SAFE: Use local variable
            emoji: '📖',
            description: 'Study vocabulary for 20 mins',
            fillCount: 5,
            lastFilledAt: DateTime.now().subtract(Duration(hours: 26)),
            fillHistory: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          SubPoint(
            id: 'mock-sub-4',
            goalId: goalId, // ✅ SAFE: Use local variable
            emoji: '🎧',
            description: 'Listen to Spanish podcast',
            fillCount: 3,
            lastFilledAt: DateTime.now().subtract(Duration(hours: 4)),
            fillHistory: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
      } else {
        _subPoints = [
          SubPoint(
            id: 'mock-sub-5',
            goalId: goalId, // ✅ SAFE: Use local variable
            emoji: '💰',
            description: 'Save \$50 today',
            fillCount: 2,
            lastFilledAt: DateTime.now().subtract(Duration(hours: 30)),
            fillHistory: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E17),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Isle emoji and name
          Row(
            children: [
              Text(
                widget.isle.mainEmoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isle.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mass: ${widget.isle.mass}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Goal display
          if (_goal != null) _buildGoalDisplay(),

          const SizedBox(height: 32),

          // Chat button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openChat(context, widget.isle.id, widget.isle.name),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              child: const Text('Open Chat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF374151),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal (main point)
          Row(
            children: [
              Text(
                _goal?.emoji ?? '', // ✅ SAFE: Null check added
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _goal?.text ?? '', // ✅ SAFE: Null check added
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sub-points
          ..._subPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final subPoint = entry.value;

            return Padding(
              padding: EdgeInsets.only(top: index > 0 ? 12 : 0),
              child: Row(
                children: [
                  Text(
                    subPoint.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subPoint.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: subPoint.fillCount > 0
                          ? const Color(0xFF34D399).withOpacity(0.2)
                          : const Color(0xFF374151).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${subPoint.fillCount}',
                      style: TextStyle(
                        color: subPoint.fillCount > 0
                            ? const Color(0xFF34D399)
                            : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, String isleId, String isleName) {
    Navigator.pop(context); // Close modal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(isleId: isleId, isleName: isleName),
      ),
    );
  }
}