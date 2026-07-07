import 'package:flutter/rendering.dart';

/// The four corner radius fractions of a spark's silhouette.
/// Each value is 0.0–0.5. Default: rhomboid squircle {0.4, 0.12, 0.4, 0.12}.
/// Per spec §2: cosmetic, editable in Spark Settings.
class SparkShape {
  const SparkShape({
    this.tl = 0.4,
    this.tr = 0.12,
    this.br = 0.4,
    this.bl = 0.12,
  });

  final double tl;
  final double tr;
  final double br;
  final double bl;

  /// The default rhomboid squircle.
  static const SparkShape rhomboid = SparkShape();

  SparkShape copyWith({
    double? tl,
    double? tr,
    double? br,
    double? bl,
  }) =>
      SparkShape(
        tl: tl ?? this.tl,
        tr: tr ?? this.tr,
        br: br ?? this.br,
        bl: bl ?? this.bl,
      );

  factory SparkShape.fromJson(Map<String, dynamic> json) => SparkShape(
        tl: (json['tl'] as num?)?.toDouble() ?? 0.4,
        tr: (json['tr'] as num?)?.toDouble() ?? 0.12,
        br: (json['br'] as num?)?.toDouble() ?? 0.4,
        bl: (json['bl'] as num?)?.toDouble() ?? 0.12,
      );

  Map<String, dynamic> toJson() => {
        'tl': tl,
        'tr': tr,
        'br': br,
        'bl': bl,
      };

  /// Convert to Flutter BorderRadius for a given size.
  /// Each fraction * size = pixel radius for that corner.
  BorderRadius toBorderRadius(double size) => BorderRadius.only(
        topLeft: Radius.circular(tl * size),
        topRight: Radius.circular(tr * size),
        bottomRight: Radius.circular(br * size),
        bottomLeft: Radius.circular(bl * size),
      );
}
