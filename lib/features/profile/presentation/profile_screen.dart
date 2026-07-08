import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../core/repositories/mock/mock_providers.dart';
import '../../../core/repositories/supabase/supabase_client.dart';
import 'edit_profile_sheet.dart';

/// Profile — the account hub. Renders from currentUserProvider.
/// Per Language Principle: no "ritual"/"spark" words. Uses allowed verbs.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/'),
        ),
        title: const Text('You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const EditProfileSheet(),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Identity block
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 18),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0x243B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(user.avatar, style: const TextStyle(fontSize: 42)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user.handle}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                if (user.bio != null && user.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          // Navigation rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFECEFF2)),
              ),
              child: Column(
                children: [
                  _ProfileRow(
                    icon: Icons.home_outlined,
                    label: 'Your Isles',
                    onTap: () => context.go('/isles'),
                  ),
                  const Divider(height: 1, color: Color(0xFFECEFF2)),
                  _ProfileRow(
                    icon: Icons.search,
                    label: 'Discover',
                    onTap: () => context.go('/discover'),
                  ),
                  const Divider(height: 1, color: Color(0xFFECEFF2)),
                  _ProfileRow(
                    icon: Icons.edit_note,
                    label: 'Post',
                    onTap: () => context.go('/post'),
                  ),
                  const Divider(height: 1, color: Color(0xFFECEFF2)),
                  _ProfileRow(
                    icon: Icons.people_outline,
                    label: 'Friends',
                    onTap: () => context.go('/friends'),
                  ),
                  const Divider(height: 1, color: Color(0xFFECEFF2)),
                  _ProfileRow(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => context.go('/appsettings'),
                  ),
                  const Divider(height: 1, color: Color(0xFFECEFF2)),
                  _ProfileRow(
                    icon: Icons.logout,
                    label: 'Sign out',
                    isDanger: true,
                    onTap: () {
                      SupabaseConfig.client.auth.signOut();
                      ref.read(currentUserProvider.notifier).reset();
                      ref.read(islesProvider.notifier).reset();
                      ref.read(membershipsProvider.notifier).reset();
                      ref.read(friendsProvider.notifier).reset();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Icon(icon, size: 20,
                  color: isDanger ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDanger ? const Color(0xFFEF4444) : const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}
