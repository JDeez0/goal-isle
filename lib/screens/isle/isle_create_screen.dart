import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goal_isle/providers/isle_provider.dart';
// import 'package:goal_isle/providers/auth_provider.dart'; // DISABLED FOR MOCKUP
// import 'package:goal_isle/providers/goal_provider.dart'; // DISABLED FOR MOCKUP
// import 'package:goal_isle/providers/sub_point_provider.dart'; // DISABLED FOR MOCKUP
// import 'package:supabase_flutter/supabase_flutter.dart'; // DISABLED FOR MOCKUP

class IsleCreateScreen extends ConsumerStatefulWidget {
  const IsleCreateScreen({super.key});

  @override
  ConsumerState<IsleCreateScreen> createState() => _IsleCreateScreenState();
}

class _IsleCreateScreenState extends ConsumerState<IsleCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedEmoji = '🎯';

  static const List<String> _commonEmojis = [
    '🎯', '💪', '🏃', '📸', '🎨', '🏋️', '🍎', '🍊', '🥗', '🧘',
    '🎸', '🚀', '⭐', '🎵', '🎭', '🏀', '⚽', '🎲', '🏆', '📚',
    '💻', '🎥', '🎬', '✍️', '🎤', '🎧', '🎹', '🎺'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Isle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Isle name
              const Text(
                'Isle Name',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., Fitness Journey',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1A1F2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Isle emoji
              const Text(
                'Isle Emoji',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showEmojiPicker(),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF374151),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canCreate ? _createIsle : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60A5FA),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  child: const Text('Create Isle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canCreate => _nameController.text.isNotEmpty;

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1,
          ),
          itemCount: _commonEmojis.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() => _selectedEmoji = _commonEmojis[index]);
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  _commonEmojis[index],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _createIsle() async {
    // DISABLED FOR MOCKUP - No auth check
    // final currentUser = ref.read(authProvider);
    // if (currentUser == null) return;

    // Create isle
    await ref.read(isleProvider.notifier).createIsle(
      name: _nameController.text,
      mainEmoji: _selectedEmoji,
    );

    // DISABLED FOR MOCKUP - No goals/sub-points
    // // Create goal (main point)
    // final goal = await ref.read(goalProvider.notifier).createGoal(
    //   isleId: isle.id,
    //   emoji: _goalEmoji,
    //   text: _goalTextController.text,
    // );

    // // Create sub-point
    // await ref.read(subPointProvider.notifier).createSubPoint(
    //   goalId: goal.id,
    //   emoji: _subPointEmoji,
    //   text: _subPointTextController.text,
    // );

    if (mounted) {
      Navigator.pop(context);
    }
  }
}