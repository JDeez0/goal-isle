import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // DISABLED FOR MOCKUP
import 'package:goal_isle/models/goal.dart';

class GoalNotifier extends StateNotifier<List<Goal>> {
  GoalNotifier() : super([]);

  // DISABLED FOR MOCKUP - Supabase fetch
  // Future<void> fetchGoals(String isleId) async {
  //   final response = await Supabase.instance.client
  //       .from('goals')
  //       .select()
  //       .eq('isle_id', isleId);

  //   final goals = (response as List<dynamic>)
  //       .map((json) => Goal.fromJson(json as Map<String, dynamic>))
  //       .toList();

  //   state = goals;
  // }

  Future<void> fetchGoals(String isleId) async {
    // Return empty list for mockup
    state = [];
  }

  Future<Goal> createGoal({
    required String isleId,
    required String emoji,
    required String text,
    Map<String, dynamic>? metadata,
  }) async {
    // DISABLED FOR MOCKUP - Supabase insert
    // final response = await Supabase.instance.client.from('goals').insert({
    //   'isle_id': isleId,
    //   'emoji': emoji,
    //   'text': text,
    //   'metadata': metadata ?? {},
    // }).select();

    // final goalData = (response as List<dynamic>).first as Map<String, dynamic>;
    // final goal = Goal.fromJson(goalData);

    final now = DateTime.now();
    final goal = Goal(
      id: now.millisecondsSinceEpoch.toString(),
      isleId: isleId,
      emoji: emoji,
      text: text,
      metadata: metadata ?? {},
      createdAt: now,
    );

    state = [...state, goal];

    return goal;
  }
}

final goalProvider = StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier();
});