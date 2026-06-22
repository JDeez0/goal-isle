import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // DISABLED FOR MOCKUP
import 'package:goal_isle/models/sub_point.dart';

class SubPointNotifier extends StateNotifier<List<SubPoint>> {
  SubPointNotifier() : super([]);

  Future<void> fetchSubPoints(String goalId) async {
    // DISABLED FOR MOCKUP - Return empty list
    state = [];

    // Future<void> fetchSubPoints(String goalId) async {
    //   final response = await Supabase.instance.client
    //       .from('sub_points')
    //       .select()
    //       .eq('goal_id', goalId);

    //   final subPoints = (response as List<dynamic>)
    //       .map((json) => SubPoint.fromJson(json as Map<String, dynamic>))
    //       .toList();

    //   state = subPoints;
    // }
  }

  Future<bool> fillPoint(
      String subPointId, String messageId, String emoji, String userId) async {
    // DISABLED FOR MOCKUP - Just return true
    return true;

    // Future<bool> fillPoint(
    //     String subPointId, String messageId, String emoji, String userId) async {
    //   final currentSubPoint = state.firstWhere(
    //     (sp) => sp.id == subPointId,
    //     orElse: () => throw Exception('SubPoint not found'),
    //   );

    //   // Check refill frequency (default: daily)
    //   final now = DateTime.now();
    //   final lastFilled = currentSubPoint.lastFilledAt;
    //   final hoursSinceFill = now.difference(lastFilled).inHours;
    //   
    //   // Default refill frequency: 24 hours
    //   if (hoursSinceFill < 24) {
    //     return false; // Cannot fill yet
    //   }

    //   // Update sub-point
    //   final updatedHistory = [...currentSubPoint.fillHistory, now];

    //   await Supabase.instance.client
    //       .from('sub_points')
    //       .update({
    //         'fill_count': currentSubPoint.fillCount + 1,
    //         'last_filled_at': now.toIso8601String(),
    //         'fill_history': updatedHistory.map((e) => e.toIso8601String()).toList(),
    //       })
    //       .eq('id', subPointId);

    //   // Increase isle mass
    //   await _increaseIsleMass(currentSubPoint.goalId);

    //   await fetchSubPoints(currentSubPoint.goalId);
    //   return true;
    // }
  }

  Future<void> _increaseIsleMass(String goalId) async {
    // DISABLED FOR MOCKUP
    // Future<void> _increaseIsleMass(String goalId) async {
    //   // Get goal to find isle_id
    //   final goalResponse = await Supabase.instance.client
    //       .from('goals')
    //       .select('isle_id')
    //       .eq('id', goalId)
    //       .single();

    //   final isleId = goalResponse['isle_id'] as String;

    //   // Get current mass
    //   final isleResponse = await Supabase.instance.client
    //       .from('isles')
    //       .select('mass')
    //       .eq('id', isleId)
    //       .single();

    //   final currentMass = isleResponse['mass'] as int;

    //   // Increment mass
    //   await Supabase.instance.client
    //       .from('isles')
    //       .update({'mass': currentMass + 1})
    //       .eq('id', isleId);
    // }
  }
}

final subPointProvider = StateNotifierProvider<SubPointNotifier, List<SubPoint>>((ref) {
  return SubPointNotifier();
});