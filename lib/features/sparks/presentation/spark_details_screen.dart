import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets/spark_widget.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/membership.dart';
import '../../../core/models/spark.dart';
import '../../../core/repositories/mock/mock_providers.dart';
import '../../../core/utils/debug_label.dart';
import 'metric_log_sheet.dart';

/// Spark Details — the drill-in for a single Key. A tappable hero card that
/// collapses/expands, plus the action rows for completing, logging, viewing
/// the thread, and listing members.
class SparkDetailsScreen extends ConsumerStatefulWidget {
  const SparkDetailsScreen({super.key});

  @override
  ConsumerState<SparkDetailsScreen> createState() =>
      _SparkDetailsScreenState();
}

class _SparkDetailsScreenState extends ConsumerState<SparkDetailsScreen> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isleId = ref.watch(activeIsleIdProvider);
    final sparkId = ref.watch(activeSparkIdProvider);
    final isles = ref.watch(islesProvider);
    final isle = isles.where((i) => i.id == isleId).firstOrNull;
    final Spark? spark =
        isle?.sparks.where((s) => s.id == sparkId).firstOrNull;

    if (spark == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
            onPressed: () => context.go('/isle'),
          ).labeled('SD-00'),
        ),
        body: const Center(
          child: Text('Spark not found',
              style: TextStyle(color: Color(0xFF94A3B8))),
        ).labeled('SD-00-err'),
      );
    }

    final isRitual = spark.mode == SparkMode.ritual;
    final isLit = spark.state == SparkState.lit ||
        spark.state == SparkState.streaked;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/isle'),
        ).labeled('SD-01'),
        title: Text(spark.title ?? 'Untitled key').labeled('SD-02'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF3B82F6)),
            onPressed: () => context.go('/sparksettings'),
          ).labeled('SD-03'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _HeroCard(
            spark: spark,
            expanded: _expanded,
            onToggle: () => setState(() => _expanded = !_expanded),
          ).labeled('SD-04'),
          const SizedBox(height: 16),
          _ActionRows(
            spark: spark,
            isRitual: isRitual,
            isLit: isLit,
            onDone: () => _markLit(spark),
            onLog: () => MetricLogSheet.show(context, ref, spark),
          ).labeled('SD-05'),
        ],
      ),
    );
  }

  void _markLit(Spark spark) {
    final updated = spark.copyWith(
      state: SparkState.lit,
      streak: spark.streak + 1,
      lastCompletedAt: DateTime.now(),
    );
    ref.read(islesProvider.notifier).updateSpark(spark.isleId, updated);
  }
}

// -----------------------------------------------------------------------------
// Hero card — collapsed (spark + meta) or expanded (recipe / metric panel).
// -----------------------------------------------------------------------------

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.spark,
    required this.expanded,
    required this.onToggle,
  });
  final Spark spark;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEFF2)),
      ),
      child: Column(
        children: [
          // Tappable top — spark + meta + expand chevron.
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                child: Row(children: [
                  SparkWidget(
                    emoji: spark.emoji,
                    state: spark.state,
                    shape: spark.shape,
                    size: 72,
                    streak: spark.state == SparkState.lit ||
                            spark.state == SparkState.streaked
                        ? spark.streak
                        : null,
                  ).labeled('SD-hero-spark'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(spark.title ?? 'Untitled key',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700)).labeled('SD-hero-title'),
                        const SizedBox(height: 6),
                        _MetaRow(spark: spark).labeled('SD-hero-meta'),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF94A3B8),
                  ).labeled('SD-hero-expand'),
                ]).labeled('SD-hero-row'),
              ),
            ),
          ),
          // Expanded content.
          if (expanded) ...[
            const Divider(height: 1, color: Color(0xFFECEFF2)).labeled('SD-hero-divider'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: DebugLabel(
                label: 'SD-hero-body',
                child: spark.mode == SparkMode.ritual
                    ? _RecipeBody(spark: spark)
                    : _MetricBody(spark: spark),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.spark});
  final Spark spark;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (spark.streak > 0) ...[
          const Text('🔥', style: TextStyle(fontSize: 13)).labeled('SD-meta-fire'),
          Text('${spark.streak} streak',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF97316))).labeled('SD-meta-streak'),
        ],
        const Icon(Icons.schedule, size: 13, color: Color(0xFF94A3B8)).labeled('SD-meta-schedule'),
        Text(spark.timerMode.name,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF94A3B8))).labeled('SD-meta-timer'),
      ],
    ).labeled('SD-meta-row');
  }
}

// -----------------------------------------------------------------------------
// Expanded bodies.
// -----------------------------------------------------------------------------

/// Ritual recipe — dependencies stacked above an `=`, hero below.
class _RecipeBody extends StatelessWidget {
  const _RecipeBody({required this.spark});
  final Spark spark;

  @override
  Widget build(BuildContext context) {
    final deps = spark.dependencies;
    return Column(
      children: [
        if (deps.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No ingredients yet.',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          ).labeled('SD-recipe-empty')
        else
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              for (final d in deps)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(d.emoji, style: const TextStyle(fontSize: 30)).labeled('SD-recipe-dep-emoji'),
                    if (d.label != null && d.label!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(d.label!,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8))).labeled('SD-recipe-dep-label'),
                      ),
                  ],
                ).labeled('SD-recipe-dep-${deps.indexOf(d)}'),
            ],
          ).labeled('SD-recipe-deps'),
        const SizedBox(height: 10),
        const Text('=',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                color: Color(0xFF94A3B8))).labeled('SD-recipe-equals'),
        const SizedBox(height: 10),
        SparkWidget(
          emoji: spark.emoji,
          state: spark.state,
          shape: spark.shape,
          size: 80,
        ).labeled('SD-recipe-result'),
      ],
    ).labeled('SD-recipe-body');
  }
}

/// Metric panel — current value big, prior value faint, trend arrow, target.
class _MetricBody extends StatelessWidget {
  const _MetricBody({required this.spark});
  final Spark spark;

  @override
  Widget build(BuildContext context) {
    final m = spark.metric;
    final unit = m?.unit;
    final target = m?.target ?? 0;

    String valueLabel(num v) =>
        unit != null && unit.isNotEmpty ? '$v $unit' : '$v';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              m != null ? valueLabel(m.currentValue) : '—',
              style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                  height: 1),
            ).labeled('SD-metric-value'),
            const SizedBox(width: 6),
            if (m != null) _TrendArrow(trend: m.trend).labeled('SD-metric-arrow'),
          ],
        ).labeled('SD-metric-row'),
        const SizedBox(height: 4),
        Text(
          m != null
              ? 'was ${valueLabel(m.previousValue)}'
              : 'no value yet',
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF94A3B8)),
        ).labeled('SD-metric-previous'),
        if (target > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Target ${valueLabel(target)}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B)),
            ),
          ).labeled('SD-metric-target'),
        ],
      ],
    ).labeled('SD-metric-body');
  }
}

class _TrendArrow extends StatelessWidget {
  const _TrendArrow({required this.trend});
  final String trend;

  @override
  Widget build(BuildContext context) {
    final color = trend == 'up'
        ? const Color(0xFF10B981)
        : trend == 'down'
            ? const Color(0xFFEF4444)
            : const Color(0xFF94A3B8);
    final icon = trend == 'up'
        ? Icons.arrow_upward
        : trend == 'down'
            ? Icons.arrow_downward
            : Icons.remove;
    return Icon(icon, size: 18, color: color).labeled('SD-trend-icon');
  }
}

// -----------------------------------------------------------------------------
// Action rows.
// -----------------------------------------------------------------------------

class _ActionRows extends StatelessWidget {
  const _ActionRows({
    required this.spark,
    required this.isRitual,
    required this.isLit,
    required this.onDone,
    required this.onLog,
  });
  final Spark spark;
  final bool isRitual;
  final bool isLit;
  final VoidCallback onDone;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary action.
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isRitual
                  ? (isLit ? null : onDone)
                  : onLog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                disabledForegroundColor: const Color(0xFF94A3B8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                isRitual
                    ? (isLit ? 'Completed' : 'Done')
                    : 'Log',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ).labeled('SD-action-primary-label'),
            ).labeled('SD-action-primary'),
          ),
          const SizedBox(height: 10),
          // Secondary actions.
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/sparkthread'),
                  icon: const Icon(Icons.chat_bubble_outline,
                      size: 18, color: Color(0xFF64748B)),
                  label: const Text('Thread',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFECEFF2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ).labeled('SD-action-thread'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => _showMembers(context, ref),
                  icon: const Icon(Icons.group_outlined,
                      size: 18, color: Color(0xFF64748B)),
                  label: const Text('Members',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFECEFF2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ).labeled('SD-action-members'),
              ),
            ),
          ]).labeled('SD-action-secondary'),
        ],
      ).labeled('SD-actions');
    });
  }

  void _showMembers(BuildContext context, WidgetRef ref) {
    final isleId = ref.read(activeIsleIdProvider);
    if (isleId == null) return;
    final members = ref.read(membershipsProvider)[isleId] ??
        const <Membership>[];
    final isleName =
        ref.read(islesProvider).where((i) => i.id == isleId).firstOrNull;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '${isleName?.name ?? 'Isle'} · ${members.length} members',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ).labeled('SD-modal-title'),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFECEFF2)).labeled('SD-modal-divider'),
              for (final m in members)
                ListTile(
                  leading: Text(m.userAvatar,
                      style: const TextStyle(fontSize: 22)).labeled('SD-modal-avatar'),
                  title: Text(m.userName,
                      style: const TextStyle(fontSize: 14)).labeled('SD-modal-name'),
                  subtitle: Text(
                    m.role == 'creator' ? 'Creator' : 'Member',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8)),
                  ).labeled('SD-modal-role'),
                ).labeled('SD-modal-${members.indexOf(m)}'),
            ],
          ).labeled('SD-modal-body'),
        ).labeled('SD-modal'),
      ),
    );
  }
}
