import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/message.dart';
import '../../../core/models/metric.dart';
import '../../../core/models/spark.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// Metric Log — a bottom sheet for logging a new value against a metric Spark.
///
/// Parses the entered number, updates the spark's metric (current/previous/trend),
/// pushes a [Message] onto the spark's thread, checks whether the target is met
/// (lighting the spark + bumping the streak), then closes the sheet.
class MetricLogSheet extends ConsumerStatefulWidget {
  const MetricLogSheet({super.key, required this.spark});

  final Spark spark;

  /// Convenience launcher — shows the sheet modally.
  static Future<void> show(BuildContext context, WidgetRef ref, Spark spark) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: MetricLogSheet(spark: spark),
      ),
    );
  }

  @override
  ConsumerState<MetricLogSheet> createState() => _MetricLogSheetState();
}

class _MetricLogSheetState extends ConsumerState<MetricLogSheet> {
  final _ctrl = TextEditingController();
  bool _hasPhoto = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _canAdd => _ctrl.text.trim().isNotEmpty;

  void _add() {
    final parsed = num.tryParse(_ctrl.text.trim());
    if (parsed == null) {
      setState(() => _error = 'Enter a number');
      return;
    }

    final spark = widget.spark;
    final metric = spark.metric;
    final me = ref.read(currentUserProvider);
    final now = DateTime.now();

    // Determine trend relative to the prior current value.
    final previous = metric?.currentValue ?? 0;
    final trend = parsed > previous
        ? 'up'
        : parsed < previous
            ? 'down'
            : 'flat';

    final newMetric = (metric ?? const Metric(template: MetricTemplate.count))
        .copyWith(
      currentValue: parsed,
      previousValue: previous,
      trend: trend,
    );

    // Target met → light the spark and bump the streak.
    final targetMet =
        newMetric.target > 0 && parsed >= newMetric.target;
    final newState = targetMet ? SparkState.lit : spark.state;
    final newStreak = targetMet ? spark.streak + 1 : spark.streak;

    // Push a log message onto the thread.
    final unit = newMetric.unit;
    final logText = unit != null && unit.isNotEmpty
        ? '$parsed $unit'
        : '$parsed';
    final msg = Message(
      id: '${spark.id}-t${now.millisecondsSinceEpoch}',
      chatId: 'thread-${spark.id}',
      senderId: me.id,
      senderName: me.name,
      senderAvatar: me.avatar,
      content: logText,
      createdAt: now,
    );

    final updated = spark.copyWith(
      metric: newMetric,
      state: newState,
      streak: newStreak,
      lastCompletedAt: targetMet ? now : spark.lastCompletedAt,
      thread: [...spark.thread, msg],
    );

    ref.read(islesProvider.notifier).updateSpark(spark.isleId, updated);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.spark.title ?? 'Log';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grab handle.
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Log · $title',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            // Number input + photo toggle.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {
                      _error = null;
                    }),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '0',
                      hintStyle: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                      errorText: _error,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFECEFF2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF3B82F6), width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => _hasPhoto = !_hasPhoto),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _hasPhoto
                          ? const Color(0xFFEFF3F8)
                          : const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasPhoto
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFECEFF2),
                      ),
                    ),
                    child: Icon(
                      _hasPhoto ? Icons.photo : Icons.photo_camera_outlined,
                      size: 22,
                      color: _hasPhoto
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _canAdd ? _add : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
