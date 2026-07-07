import 'package:flutter/material.dart';
import '../../core/models/enums.dart';
import '../../core/models/spark_shape.dart';

/// Renders a single Isle Key (spark) — the skewed parallelogram with
/// border-radius, aura glow, and state-driven appearance.
///
/// The shape: Transform(skewX(-14deg)) + animated BorderRadius.
/// The emoji inside is counter-skewed to stay upright.
/// State shows only by color/glow/saturation — shape stays fixed.
class SparkWidget extends StatelessWidget {
  const SparkWidget({
    super.key,
    required this.emoji,
    required this.state,
    this.shape = SparkShape.rhomboid,
    this.size = 64,
    this.streak,
    this.showSparkles = true,
  });

  final String emoji;
  final SparkState state;
  final SparkShape shape;
  final double size;
  final int? streak;
  final bool showSparkles;

  static const _skewAngle = -0.244; // ~14 degrees in radians
  static const _counterSkew = 0.244;

  @override
  Widget build(BuildContext context) {
    final isLit = state == SparkState.lit || state == SparkState.streaked;
    final isGreyed = state == SparkState.greyed;
    final showBadge = isLit && (streak ?? 0) >= 2;

    final bodySize = size * 0.74; // body is 74% of total (leaves room for aura)
    final radius = shape.toBorderRadius(bodySize);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Aura — blurred glow behind
          Positioned.fill(
            child: _Aura(state: state, size: bodySize, shape: shape),
          ),
          // Body — the skewed parallelogram
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.skewX(_skewAngle),
            child: Container(
              width: bodySize,
              height: bodySize,
              decoration: BoxDecoration(
                borderRadius: radius,
                color: _bodyColor(isLit, isGreyed),
                border: isLit
                    ? Border.all(color: const Color(0xFF3B82F6), width: 1.5)
                    : isGreyed
                        ? null
                        : Border.all(
                            color: const Color(0x101F2937), width: 1),
                boxShadow: isLit
                    ? [
                        const BoxShadow(
                          color: Color(0x383B82F6),
                          blurRadius: 22,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Emoji — counter-skewed to stay upright
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.skewX(_counterSkew),
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: bodySize * 0.52,
                        height: 1,
                        color: _emojiColor(isLit, isGreyed),
                      ),
                    ),
                  ),
                  // Sparkles (lit only)
                  if (isLit && showSparkles) ..._sparkles(bodySize),
                  // Streak badge (lit + streak >= 2)
                  if (showBadge)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.skewX(_skewAngle),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x593B82F6),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.skewX(_counterSkew),
                            child: Text(
                              '${streak!}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _bodyColor(bool isLit, bool isGreyed) {
    if (isLit) {
      return Colors.white; // lit: white with gradient tint via overlay
    }
    if (isGreyed) return const Color(0xFFE9ECEF);
    return const Color(0xFFF4F6F8); // dull
  }

  Color _emojiColor(bool isLit, bool isGreyed) {
    if (isGreyed) return const Color(0x6B1F2937); // grayscale-ish
    if (isLit) return const Color(0xFF1F2937);
    return const Color(0x801F2937); // dull desaturated
  }

  List<Widget> _sparkles(double bodySize) {
    return [
      Positioned(
        top: bodySize * 0.12,
        right: bodySize * 0.16,
        child: Transform(
          transform: Matrix4.skewX(_counterSkew),
          child: const Text(
            '✦',
            style: TextStyle(
              color: Color(0x99FBBF24),
              fontSize: 14,
              height: 1,
            ),
          ),
        ),
      ),
      Positioned(
        bottom: bodySize * 0.14,
        left: bodySize * 0.12,
        child: Transform(
          transform: Matrix4.skewX(_counterSkew),
          child: const Text(
            '✦',
            style: TextStyle(
              color: Color(0x66FBBF24),
              fontSize: 10,
              height: 1,
            ),
          ),
        ),
      ),
    ];
  }
}

/// The soft blurred glow behind a spark.
class _Aura extends StatelessWidget {
  const _Aura({
    required this.state,
    required this.size,
    required this.shape,
  });

  final SparkState state;
  final double size;
  final SparkShape shape;

  @override
  Widget build(BuildContext context) {
    final isLit = state == SparkState.lit || state == SparkState.streaked;
    final isGreyed = state == SparkState.greyed;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(-0.244),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: shape.toBorderRadius(size),
          color: isLit
              ? const Color(0x1A3B82F6) // blue glow at ~10% opacity
              : isGreyed
                  ? Colors.transparent
                  : const Color(0x1A64748B), // grey faint
        ),
      ),
    );
  }
}
