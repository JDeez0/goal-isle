import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:goal_isle/providers/auth_provider.dart' as auth; // DISABLED FOR MOCKUP
import 'package:goal_isle/providers/isle_provider.dart';
import 'package:goal_isle/widgets/spark_button.dart';
import 'package:goal_isle/widgets/mountain_visual.dart';
import 'package:goal_isle/models/isle.dart';
import 'package:goal_isle/screens/isle/isle_modal.dart';
import 'package:goal_isle/screens/isle/isle_create_screen.dart';
// import 'package:goal_isle/screens/auth/login_screen.dart'; // DISABLED FOR MOCKUP

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      // DISABLED FOR MOCKUP - No authentication needed
      // final currentUser = ref.watch(auth.authProvider);

      final isles = ref.watch(isleProvider);

      // DISABLED FOR MOCKUP - Always show UI, no login screen
      // // If not authenticated, show login screen
      // if (currentUser == null) {
      //   return const LoginScreen();
      // }

      return Scaffold(
        backgroundColor: const Color(0xFF0A0E17),
        body: isles.isEmpty
            ? _buildBlankScreen(context, ref)
            : _buildIslesScreen(context, ref, isles),
      );
    } catch (e) {
      // Error fallback
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E17),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white54,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $e',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildBlankScreen(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Sparse line pattern background
        CustomPaint(
          size: Size.infinite,
          painter: _SparseLinesPainter(),
        ),
        
        // Mountain visual (decorative, not functional yet)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 0.2,
            child: MountainVisual(
              mass: 0,
              height: 300,
            ),
          ),
        ),
        
        // Center: Spark button
        const Center(
          child: SparkButton(),
        ),
        
        // DISABLED FOR MOCKUP - No sign out needed
        // // Sign out button (top right)
        // Positioned(
        //   top: 16,
        //   right: 16,
        //   child: IconButton(
        //     icon: const Icon(Icons.logout, color: Colors.white54),
        //     onPressed: () => _signOut(ref, context),
        //     tooltip: 'Sign Out',
        //   ),
        // ),
      ],
    );
  }

  Widget _buildIslesScreen(BuildContext context, WidgetRef ref, List<Isle> isles) {
    return Stack(
      children: [
        // Sparse line pattern background
        CustomPaint(
          size: Size.infinite,
          painter: _SparseLinesPainter(),
        ),
        
        // Mountain visual (grows with total mass)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 0.3,
            child: MountainVisual(
              mass: _calculateTotalMass(isles),
              height: 300,
            ),
          ),
        ),
        
        // Isle display (visually spaced, not a list)
        Center(
          child: _buildIslesGrid(context, isles),
        ),
        
        // Add isle button (bottom right)
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _showIsleCreate(context, ref),
            backgroundColor: const Color(0xFF60A5FA),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        
        // DISABLED FOR MOCKUP - No sign out needed
        // // Sign out button (top right)
        // Positioned(
        //   top: 16,
        //   right: 16,
        //   child: IconButton(
        //     icon: const Icon(Icons.logout, color: Colors.white54),
        //     onPressed: () => _signOut(ref, context),
        //     tooltip: 'Sign Out',
        //   ),
        // ),
      ],
    );
  }

  Widget _buildIslesGrid(BuildContext context, List<Isle> isles) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Wrap(
        spacing: 32,
        runSpacing: 32,
        alignment: WrapAlignment.center,
        children: isles.map((isle) => _buildIsleCard(context, isle)).toList(),
      ),
    );
  }

  Widget _buildIsleCard(BuildContext context, Isle isle) {
    return GestureDetector(
      onTap: () => _showIsleModal(context, isle),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1F2E),
              Color(0xFF252B3D),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF374151),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF374151).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isle.mainEmoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              isle.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Mass: ${isle.mass}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalMass(List<Isle> isles) {
    return isles.fold(0.0, (sum, isle) => sum + isle.mass.toDouble());
  }

  void _showIsleCreate(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) => const IsleCreateScreen(),
    );
  }

  void _showIsleModal(BuildContext context, Isle isle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) => IsleModal(isle: isle),
    );
  }

  // DISABLED FOR MOCKUP - No sign out needed
  // Future<void> _signOut(WidgetRef ref, BuildContext context) async {
  //   await ref.read(auth.authProvider.notifier).signOut();
  // }
}

class _SparseLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF374151).withOpacity(0.15)
      ..strokeWidth = 0.5;

    // Sparse horizontal lines
    for (double y = 0; y < size.height; y += 80) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Sparse vertical lines
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}