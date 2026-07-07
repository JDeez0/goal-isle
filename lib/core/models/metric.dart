import 'enums.dart';

/// Metric — sub-object of a metric-mode Spark. Present only when mode == metric.
/// Per ISLE_SPARKS_SPEC_v2 §3.
class Metric {
  const Metric({
    required this.template,
    this.target = 0,
    this.unit,
    this.currentValue = 0,
    this.previousValue = 0,
    this.trend = 'flat',
  });

  final MetricTemplate template;
  final num target;
  final String? unit;
  final num currentValue;
  final num previousValue;
  final String trend; // 'up' | 'down' | 'flat'

  Metric copyWith({
    MetricTemplate? template,
    num? target,
    String? unit,
    num? currentValue,
    num? previousValue,
    String? trend,
  }) =>
      Metric(
        template: template ?? this.template,
        target: target ?? this.target,
        unit: unit ?? this.unit,
        currentValue: currentValue ?? this.currentValue,
        previousValue: previousValue ?? this.previousValue,
        trend: trend ?? this.trend,
      );

  factory Metric.fromJson(Map<String, dynamic> json) => Metric(
        template: enumFromString(
          MetricTemplate.values,
          json['template'] as String? ?? 'count',
        ),
        target: json['target'] as num? ?? 0,
        unit: json['unit'] as String?,
        currentValue: json['current_value'] as num? ?? 0,
        previousValue: json['previous_value'] as num? ?? 0,
        trend: json['trend'] as String? ?? 'flat',
      );

  Map<String, dynamic> toJson() => {
        'template': template.name,
        'target': target,
        if (unit != null) 'unit': unit,
        'current_value': currentValue,
        'previous_value': previousValue,
        'trend': trend,
      };
}
