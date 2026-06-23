import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // DISABLED FOR MOCKUP
import 'package:goal_isle/models/isle.dart';

class IsleNotifier extends StateNotifier<List<Isle>> {
  IsleNotifier() : super([]) {
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    state = [
      Isle(
        id: '1',
        name: 'Fitness Journey',
        mainEmoji: '💪',
        mass: 45,
        createdBy: 'mock-user',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 1)),
        settings: {
          'whoCanFill': 'all_members',
          'refillFrequency': 'daily',
          'refillFrequencyValue': 1,
          'refillFrequencyUnit': 'days',
        },
      ),
      Isle(
        id: '2',
        name: 'Learning Spanish',
        mainEmoji: '📚',
        mass: 30,
        createdBy: 'mock-user',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        settings: {
          'whoCanFill': 'all_members',
          'refillFrequency': 'daily',
          'refillFrequencyValue': 1,
          'refillFrequencyUnit': 'days',
        },
      ),
      Isle(
        id: '3',
        name: 'Save for Vacation',
        mainEmoji: '🏖️',
        mass: 15,
        createdBy: 'mock-user',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
        settings: {
          'whoCanFill': 'all_members',
          'refillFrequency': 'weekly',
          'refillFrequencyValue': 1,
          'refillFrequencyUnit': 'weeks',
        },
      ),
    ];
  }

  // DISABLED FOR MOCKUP - Supabase fetch
  // Future<void> fetchIsles() async {
  //   final response = await Supabase.instance.client
  //       .from('isles')
  //       .select()
  //       .order('created_at', ascending: true);

  //   final isles = (response as List<dynamic>)
  //       .map((json) => Isle.fromJson(json as Map<String, dynamic>))
  //       .toList();

  //   state = isles;
  // }

  Future<Isle> createIsle({
    required String name,
    required String mainEmoji,
  }) async {
    // DISABLED FOR MOCKUP - No Supabase
    // final currentUser = Supabase.instance.client.auth.currentUser!;

    // Create mock isle
    final now = DateTime.now();
    final newIsle = Isle(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      mainEmoji: mainEmoji,
      mass: 1,
      createdBy: 'mock-user',
      createdAt: now,
      updatedAt: now,
      settings: {
        'whoCanFill': 'all_members',
        'refillFrequency': 'daily',
        'refillFrequencyValue': 1,
        'refillFrequencyUnit': 'days',
      },
    );

    state = [...state, newIsle];

    return newIsle;

    // DISABLED FOR MOCKUP - Supabase insert
    // final response = await Supabase.instance.client.from('isles').insert({
    //   'name': name,
    //   'main_emoji': mainEmoji,
    //   'owner_id': currentUser.id,
    //   'mass': 1,
    //   'settings': {
    //     'whoCanFill': 'all_members',
    //     'refillFrequency': 'daily',
    //     'refillFrequencyValue': 1,
    //     'refillFrequencyUnit': 'days'
    //   },
    // }).select();

    // final isleData = (response as List<dynamic>).first as Map<String, dynamic>;
    // final isle = Isle.fromJson(isleData);

    // // Refresh list
    // await fetchIsles();
    //
    // return isle;
  }
}

final isleProvider = StateNotifierProvider<IsleNotifier, List<Isle>>((ref) {
  return IsleNotifier();
});