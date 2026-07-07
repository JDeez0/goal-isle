/// All v2 enums — shared across models.
/// Per ISLE_SPARKS_SPEC_v2 §2-§6.
library;

/// Look up an enum value by its `.name`. Falls back to the first value.
T enumFromString<T extends Enum>(List<T> values, String value) =>
    values.firstWhere((e) => e.name == value, orElse: () => values.first);

enum IsleVisibility { public, private }

enum SparkMode { ritual, metric }

enum SparkScope { shared, personal }

enum SparkState { dull, lit, streaked, greyed }

enum TimerMode { instant, daily, weekly, monthly }

enum MembershipRole { creator, member }

enum MetricTemplate { count, sum, avgImprove, threshold }
