import 'dependency.dart';
import 'enums.dart';
import 'message.dart';
import 'metric.dart';
import 'spark_shape.dart';

/// Spark (aka Key) — the core ritual/metric object.
/// Per ISLE_SPARKS_SPEC_v2 §2.
class Spark {
  const Spark({
    required this.id,
    required this.isleId,
    required this.emoji,
    this.title,
    required this.mode,
    required this.scope,
    this.shape = SparkShape.rhomboid,
    this.state = SparkState.dull,
    this.streak = 0,
    required this.timerMode,
    this.streakBreaksOnMiss = true,
    this.dependencies = const [],
    this.metric,
    this.isMain = false,
    this.thread = const [],
    this.lastCompletedAt,
    this.cycleDueAt,
    required this.createdAt,
  });

  final String id;
  final String isleId;
  final String emoji;
  final String? title;
  final SparkMode mode;
  final SparkScope scope;
  final SparkShape shape;
  final SparkState state;
  final int streak;
  final TimerMode timerMode;
  final bool streakBreaksOnMiss;
  final List<Dependency> dependencies;
  final Metric? metric;
  final bool isMain;
  final List<Message> thread;
  final DateTime? lastCompletedAt;
  final DateTime? cycleDueAt;
  final DateTime createdAt;

  Spark copyWith({
    String? id,
    String? isleId,
    String? emoji,
    String? title,
    SparkMode? mode,
    SparkScope? scope,
    SparkShape? shape,
    SparkState? state,
    int? streak,
    TimerMode? timerMode,
    bool? streakBreaksOnMiss,
    List<Dependency>? dependencies,
    Metric? metric,
    bool? isMain,
    List<Message>? thread,
    DateTime? lastCompletedAt,
    DateTime? cycleDueAt,
    DateTime? createdAt,
  }) =>
      Spark(
        id: id ?? this.id,
        isleId: isleId ?? this.isleId,
        emoji: emoji ?? this.emoji,
        title: title ?? this.title,
        mode: mode ?? this.mode,
        scope: scope ?? this.scope,
        shape: shape ?? this.shape,
        state: state ?? this.state,
        streak: streak ?? this.streak,
        timerMode: timerMode ?? this.timerMode,
        streakBreaksOnMiss: streakBreaksOnMiss ?? this.streakBreaksOnMiss,
        dependencies: dependencies ?? this.dependencies,
        metric: metric ?? this.metric,
        isMain: isMain ?? this.isMain,
        thread: thread ?? this.thread,
        lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
        cycleDueAt: cycleDueAt ?? this.cycleDueAt,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Spark.fromJson(Map<String, dynamic> json) => Spark(
        id: json['id'] as String,
        isleId: json['isle_id'] as String,
        emoji: json['main_emoji'] as String,
        title: json['title'] as String?,
        mode: enumFromString(
          SparkMode.values,
          json['mode'] as String? ?? 'ritual',
        ),
        scope: enumFromString(
          SparkScope.values,
          json['scope'] as String? ?? 'shared',
        ),
        shape: json['shape'] is Map<String, dynamic>
            ? SparkShape.fromJson(json['shape'] as Map<String, dynamic>)
            : SparkShape.rhomboid,
        state: enumFromString(
          SparkState.values,
          json['state'] as String? ?? 'dull',
        ),
        streak: json['streak'] as int? ?? 0,
        timerMode: enumFromString(
          TimerMode.values,
          json['timer_mode'] as String? ?? 'instant',
        ),
        streakBreaksOnMiss: json['streak_breaks_on_miss'] as bool? ?? true,
        dependencies: (json['dependencies'] as List<dynamic>?)
                ?.map((e) => Dependency.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        metric: json['metric'] is Map<String, dynamic>
            ? Metric.fromJson(json['metric'] as Map<String, dynamic>)
            : null,
        isMain: json['is_main'] as bool? ?? false,
        thread: (json['thread'] as List<dynamic>?)
                ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        lastCompletedAt: json['last_completed_at'] is String
            ? DateTime.parse(json['last_completed_at'] as String)
            : null,
        cycleDueAt: json['cycle_due_at'] is String
            ? DateTime.parse(json['cycle_due_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isle_id': isleId,
        'main_emoji': emoji,
        if (title != null) 'title': title,
        'mode': mode.name,
        'scope': scope.name,
        'shape': shape.toJson(),
        'state': state.name,
        'streak': streak,
        'timer_mode': timerMode.name,
        'streak_breaks_on_miss': streakBreaksOnMiss,
        'dependencies': dependencies.map((e) => e.toJson()).toList(),
        if (metric != null) 'metric': metric!.toJson(),
        'is_main': isMain,
        'thread': thread.map((e) => e.toJson()).toList(),
        if (lastCompletedAt != null)
          'last_completed_at': lastCompletedAt!.toIso8601String(),
        if (cycleDueAt != null) 'cycle_due_at': cycleDueAt!.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
