import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/enums.dart';
import '../../../core/repositories/mock/mock_providers.dart';
import '../../../app/widgets/spark_widget.dart';

/// Home — the signature screen. Shows active Isles as tinted territories
/// on the water, each with its main-key face floating inside.
///
/// Three layout laws (spec §9):
/// 1. Territories are soft tinted regions (no hard coastline).
/// 2. Only active Isles (≥1 key) appear. Every Isle is created with an
///    auto-key (see spec §2 and `SupabaseRepository.createIsle`), so all
///    isles are active by design and all of the user's isles appear.
/// 3. Poisson-disk dispersion — stable, evenly spaced, no overlaps.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isles = ref.watch(islesProvider);
    final activeIsles = isles.where((i) => i.isActive).toList();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Compute layout once (stable per active count)
            final layout = _HomeLayout.compute(activeIsles, constraints);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // You avatar (top-right)
                Positioned(
                  top: 8,
                  right: 14,
                  child: GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFECEFF2)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x141F2937), blurRadius: 3),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          ref.watch(currentUserProvider).avatar,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
                // Territory regions + faces
                ...List.generate(activeIsles.length, (i) {
                  final isle = activeIsles[i];
                  final pos = layout[i];
                  return _TerritoryFace(
                    isle: isle,
                    x: pos.dx,
                    y: pos.dy,
                    onTap: () {
                      ref.read(activeIsleIdProvider.notifier).state = isle.id;
                      context.go('/isle');
                    },
                  );
                }),
                // Create button (bottom-right)
                Positioned(
                  bottom: 24,
                  right: 22,
                  child: GestureDetector(
                    onTap: () => context.go('/isles'),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.skewX(-0.244),
                      child: Container(
                        width: 58, height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF94A3B8),
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.skewX(0.244),
                          child: const Center(
                            child: Text(
                              '?',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A single Isle's territory + all its sparks on Home.
///
/// Renders the isle's territory region (soft tinted circle) with ALL the
/// isle's sparks floating inside it. The main spark is at center; other
/// sparks are arranged around it in a ring. Per spec §9: "each Isle
/// appears as a soft colored region on the water, with its sparks
/// floating on it."
class _TerritoryFace extends StatelessWidget {
  const _TerritoryFace({
    required this.isle,
    required this.x,
    required this.y,
    required this.onTap,
  });

  final Isle isle;
  final double x; // 0.0–1.0 fraction of width (territory center)
  final double y; // 0.0–1.0 fraction of height (territory center)
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _isleColor(isle.color);
    final sparks = isle.sparks;
    final mainSpark = sparks.where((s) => s.isMain).firstOrNull;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cx = x * w;
        final cy = y * h;

        // Territory radius scales with spark count
        final nonMainSparks = sparks.where((s) => !s.isMain).toList();
        final territoryRadius = 50.0 + (nonMainSparks.length * 12.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Territory region — soft radial wash
            Positioned(
              left: cx - territoryRadius,
              top: cy - territoryRadius,
              child: Container(
                width: territoryRadius * 2,
                height: territoryRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.045),
                ),
              ),
            ),
            // Main spark — at center
            if (mainSpark != null)
              Positioned(
                left: cx - 32,
                top: cy - 32,
                child: GestureDetector(
                  onTap: onTap,
                  child: SparkWidget(
                    emoji: isle.emoji,
                    state: mainSpark.state,
                    size: 64,
                    streak: mainSpark.state == SparkState.lit ||
                            mainSpark.state == SparkState.streaked
                        ? mainSpark.streak
                        : null,
                  ),
                ),
              ),
            // Other sparks — arranged in a ring around the main spark
            ...List.generate(nonMainSparks.length, (i) {
              final spark = nonMainSparks[i];
              final n = nonMainSparks.length;
              // Distribute evenly on a circle
              final angle = (i / n) * 2 * pi - pi / 2;
              final ringR = territoryRadius * 0.72;
              final sx = cx + cos(angle) * ringR;
              final sy = cy + sin(angle) * ringR;
              return Positioned(
                left: sx - 20,
                top: sy - 20,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to spark details
                    onTap.call();
                  },
                  child: SparkWidget(
                    emoji: spark.emoji,
                    state: spark.state,
                    size: 40,
                    streak: spark.state == SparkState.lit ||
                            spark.state == SparkState.streaked
                        ? spark.streak
                        : null,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Color _isleColor(String name) {
    return switch (name) {
      'blue' => const Color(0xFF3B82F6),
      'green' => const Color(0xFF10B981),
      'amber' => const Color(0xFFF59E0B),
      'violet' => const Color(0xFF8B5CF6),
      'rose' => const Color(0xFFF472B6),
      'teal' => const Color(0xFF14B8A6),
      'orange' => const Color(0xFFF97316),
      'indigo' => const Color(0xFF6366F1),
      _ => const Color(0xFF3B82F6),
    };
  }
}

/// Even-spaced grid layout for Home.
///
/// Places isle territories in a stable grid that guarantees even distribution
/// on any screen size. Lit isles are placed in the top rows, greyed isles in
/// the bottom rows. Positions are deterministic (same isles = same layout).
///
/// For 1–8 isles (the common case) this gives a clean grid. For 9+ isles it
/// falls back to a denser grid. There is no random component — layouts are
/// purely determined by isle count and lit/greyed count.
class _HomeLayout {
  static List<Offset> compute(List<Isle> isles, BoxConstraints constraints) {
    final n = isles.length;
    if (n == 0) return [];

    // Usable area (leave margins so territories don't clip)
    const xMin = 0.12, yMin = 0.08;
    const uW = 0.76, uH = 0.72;

    // Split into lit (top) and greyed (bottom)
    final lit = <int>[];
    final greyed = <int>[];
    for (var i = 0; i < n; i++) {
      if (_faceStateOf(isles[i]) == SparkState.greyed) {
        greyed.add(i);
      } else {
        lit.add(i);
      }
    }

    // Determine grid columns based on total count
    final cols = n <= 3 ? n : (n <= 6 ? 3 : 4);
    final cellW = uW / cols;

    final result = List<Offset>.filled(n, const Offset(0.5, 0.5));

    // Place lit isles (top rows)
    for (var idx = 0; idx < lit.length; idx++) {
      final i = lit[idx];
      final row = idx ~/ cols;
      final col = idx % cols;
      final rowsHere = ((lit.length + cols - 1) ~/ cols).clamp(1, 10);
      final cellH = (uH * 0.65) / rowsHere;
      result[i] = Offset(
        xMin + cellW * (col + 0.5),
        yMin + cellH * (row + 0.5),
      );
    }

    // Place greyed isles (bottom rows, below lit)
    for (var idx = 0; idx < greyed.length; idx++) {
      final i = greyed[idx];
      final row = idx ~/ cols;
      final col = idx % cols;
      final rowsHere = ((greyed.length + cols - 1) ~/ cols).clamp(1, 10);
      final cellH = (uH * 0.30) / rowsHere;
      result[i] = Offset(
        xMin + cellW * (col + 0.5),
        yMin + uH * 0.70 + cellH * (row + 0.5),
      );
    }

    return result;
  }

  static SparkState _faceStateOf(Isle isle) {
    final main = isle.sparks.where((s) => s.isMain).firstOrNull;
    return main?.state ?? SparkState.dull;
  }
}
