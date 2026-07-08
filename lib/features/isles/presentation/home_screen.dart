import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/enums.dart';
import '../../../core/repositories/mock/mock_providers.dart';
import '../../../app/widgets/spark_widget.dart';

/// Home — the signature screen. Shows all of the user's Isles as tinted
/// territories on the water, each with its main-key face floating inside.
///
/// Layout laws (spec §9):
/// 1. Territories are soft tinted regions (no hard coastline).
/// 2. Every Isle the user belongs to appears — both active (≥1 key) and
///    dormant (0 keys). Dormant Isles render as a smaller, fainter face
///    inside a fainter territory, signalling "needs a first key." This
///    replaces the prior v2 rule that hid empty Isles; new isles must be
///    visible on Home immediately after creation so the user can confirm
///    the action and tap to add their first key.
/// 3. Poisson-disk dispersion — stable, evenly spaced, no overlaps.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isles = ref.watch(islesProvider);
    // Show every Isle the user is a member of, including newly created
    // ones with zero keys. The visual treatment in _TerritoryFace makes
    // the dormant state unambiguous.
    final activeIsles = isles;

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

/// A single Isle's territory + face on Home.
class _TerritoryFace extends StatelessWidget {
  const _TerritoryFace({
    required this.isle,
    required this.x,
    required this.y,
    required this.onTap,
  });

  final Isle isle;
  final double x; // 0.0–1.0 fraction of width
  final double y; // 0.0–1.0 fraction of height
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _isleColor(isle.color);
    final isDormant = isle.sparks.isEmpty;
    final faceState = isDormant ? SparkState.dull : _faceState(isle);
    final faceEmoji = isle.emoji;
    final faceSize = isDormant ? 40.0 : 64.0;
    final territoryAlpha = isDormant ? 0.018 : 0.045;
    final streak = isle.sparks.where((s) => s.isMain).fold<int>(0,
        (prev, s) => s.streak > prev ? s.streak : prev);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final px = x * w;
        final py = y * h;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Territory region — soft radial wash (fainter for dormant isles)
            Positioned(
              left: px - 60,
              top: py - 60,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: territoryAlpha),
                ),
              ),
            ),
            // Face — the Isle's main spark emoji (smaller for dormant isles)
            Positioned(
              left: px - faceSize / 2,
              top: py - faceSize / 2,
              child: GestureDetector(
                onTap: onTap,
                child: isDormant
                    ? _DormantFace(emoji: faceEmoji, size: faceSize)
                    : SparkWidget(
                        emoji: faceEmoji,
                        state: faceState,
                        size: faceSize,
                        streak: faceState == SparkState.lit ||
                                faceState == SparkState.streaked
                            ? streak
                            : null,
                      ),
              ),
            ),
            // "No keys" hint under dormant faces, tap to add a first key
            if (isDormant)
              Positioned(
                left: px - 60,
                top: py + 28,
                width: 120,
                child: Center(
                  child: Text(
                    'tap to add a key',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: color.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  SparkState _faceState(Isle isle) {
    final main = isle.sparks.where((s) => s.isMain).firstOrNull;
    if (main == null) return SparkState.dull;
    return main.state;
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

/// The face for a dormant Isle (zero keys). Smaller and more transparent
/// than a SparkWidget in `dull` state, with a faint dashed ring to signal
/// "this Isle exists but has no key yet." Tapping opens the Isle Home so
/// the user can add the first key.
class _DormantFace extends StatelessWidget {
  const _DormantFace({required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Faint dashed ring — signals "draft" without breaking the
          // "no hard coastline" spec rule (it lives inside the territory,
          // not on its border).
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0x331F2937),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
          ),
          // The isle's emoji — soft, desaturated.
          Text(
            emoji,
            style: TextStyle(
              fontSize: size * 0.55,
              height: 1,
              color: const Color(0x551F2937),
            ),
          ),
        ],
      ),
    );
  }
}

/// Poisson-disk dispersion layout for Home.
/// Computes stable, evenly-spaced positions for all of the user's
/// Isles (active and dormant). All territories use the same 120×120 size
/// for layout purposes; the visual treatment of dormant isles is handled
/// inside _TerritoryFace (smaller face, fainter wash, "tap to add" hint).
class _HomeLayout {
  static List<Offset> compute(List<Isle> isles, BoxConstraints constraints) {
    final n = isles.length;
    if (n == 0) return [];

    final rng = _SeededRng(11 + n);

    // Usable area (leave margins for territories)
    const xMin = 0.15, xMax = 0.85;
    const yMin = 0.10, yMax = 0.78;
    final uW = xMax - xMin;
    final uH = yMax - yMin;

    // Min distance D (bigger gaps = smaller packing factor)
    final area = uW * uH;
    var D = sqrt(area / (n * 1.8));
    final edgeD = D * 0.5;

    final placed = <Offset>[];

    bool tooClose(double x, double y) {
      if (x - xMin < edgeD ||
          xMax - x < edgeD ||
          y - yMin < edgeD ||
          yMax - y < edgeD) return true;
      for (final p in placed) {
        final dx = x - p.dx;
        final dy = (y - p.dy) * (uW / uH);
        if (sqrt(dx * dx + dy * dy) < D) return true;
      }
      return false;
    }

    // Band lit/greyed: lit in top band, greyed in bottom band
    final litCount =
        isles.where((i) => _faceStateOf(i) != SparkState.greyed).length;
    final splitY = yMin + uH * (litCount / n);

    // Place lit/uncomp first (top band)
    for (var i = 0; i < n; i++) {
      if (_faceStateOf(isles[i]) == SparkState.greyed) continue;
      for (var t = 0; t < 2000; t++) {
        final x = xMin +
            edgeD +
            rng.nextDouble() * (uW - edgeD * 2);
        final y = yMin +
            edgeD +
            rng.nextDouble() * (splitY - yMin - edgeD * 2).clamp(0.01, uH);
        if (!tooClose(x, y)) {
          placed.add(Offset(x, y));
          break;
        }
      }
    }
    // Place greyed (bottom band)
    for (var i = 0; i < n; i++) {
      if (_faceStateOf(isles[i]) != SparkState.greyed) continue;
      for (var t = 0; t < 2000; t++) {
        final x = xMin +
            edgeD +
            rng.nextDouble() * (uW - edgeD * 2);
        final y = splitY +
            edgeD +
            rng.nextDouble() * (yMax - splitY - edgeD * 2).clamp(0.01, uH);
        if (!tooClose(x, y)) {
          placed.add(Offset(x, y));
          break;
        }
      }
    }

    // Fallback for any that didn't place
    while (placed.length < n) {
      placed.add(Offset(0.5, 0.5));
    }

    return placed;
  }

  static SparkState _faceStateOf(Isle isle) {
    final main = isle.sparks.where((s) => s.isMain).firstOrNull;
    return main?.state ?? SparkState.dull;
  }
}

/// Seeded PRNG (mulberry32) for stable layouts.
class _SeededRng {
  _SeededRng(int seed) : _a = seed;
  int _a;

  double nextDouble() {
    _a |= 0;
    _a = _a + 0x6D2B79F5;
    var t = (_a ^ (_a >> 15)) * (1 | _a);
    t = (t + (t ^ (t >> 7)) * (61 | t)) ^ t;
    return ((t ^ (t >> 14)) >>> 0) / 4294967296;
  }
}
