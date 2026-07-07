import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets/spark_widget.dart';
import '../../../core/models/dependency.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/metric.dart';
import '../../../core/models/spark.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// New Spark — compose a ritual or metric Key, then add it to the active Isle.
class NewSparkScreen extends ConsumerStatefulWidget {
  const NewSparkScreen({super.key});

  @override
  ConsumerState<NewSparkScreen> createState() => _NewSparkScreenState();
}

/// The selected "kind" — drives mode + scope defaults.
enum _Kind { solo, shared, metric }

class _NewSparkScreenState extends ConsumerState<NewSparkScreen> {
  static const _emojiPool = <String>[
    '💪', '🏃', '💧', '🧘', '📚', '🥗', '😴', '✍️', '🎸', '🏋️',
    '📖', '🧠', '🔥', '🎯', '📈', '🎓', '⏱️', '🧩', '⚖️', '📝',
  ];

  int _mainEmojiIdx = 0;
  bool _mainEmojiChosen = false;
  final _nameCtrl = TextEditingController();

  // Dependency slots (ritual only).
  final List<_DepDraft> _deps = [
    _DepDraft(),
    _DepDraft(),
  ];

  _Kind _kind = _Kind.solo;

  // Metric fields.
  final _targetCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();

  TimerMode _timer = TimerMode.daily;
  bool _breaksOnMiss = false;

  bool get _isRitual => _kind != _Kind.metric;

  bool get _canCreate => _mainEmojiChosen;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _mainEmojiIdx = 0;
      _mainEmojiChosen = false;
      _nameCtrl.clear();
      _deps
        ..[0] = _DepDraft()
        ..[1] = _DepDraft();
      _kind = _Kind.solo;
      _targetCtrl.clear();
      _unitCtrl.clear();
      _timer = TimerMode.daily;
      _breaksOnMiss = false;
    });
  }

  void _cycleMain() => setState(() {
        _mainEmojiIdx = (_mainEmojiIdx + 1) % _emojiPool.length;
        _mainEmojiChosen = true;
      });

  void _cycleDep(int i) => setState(() {
        _deps[i].cycle(_emojiPool.length);
        _deps[i].active = true;
      });

  void _create() {
    if (!_canCreate) return;
    final isleId = ref.read(activeIsleIdProvider);
    if (isleId == null) return;

    final now = DateTime.now();
    final id = 'sp-${now.millisecondsSinceEpoch}';
    final emoji = _emojiPool[_mainEmojiIdx];
    final title =
        _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim();

    final Spark spark;
    if (_isRitual) {
      final scope = _kind == _Kind.shared
          ? SparkScope.shared
          : SparkScope.personal;
      final deps = <Dependency>[];
      for (final d in _deps) {
        if (!d.active) continue;
        deps.add(Dependency(
          id: '$id-d${deps.length}',
          sparkId: id,
          emoji: _emojiPool[d.idx],
          label: d.labelCtrl.text.trim().isEmpty
              ? null
              : d.labelCtrl.text.trim(),
          createdAt: now,
        ));
      }
      spark = Spark(
        id: id,
        isleId: isleId,
        emoji: emoji,
        title: title,
        mode: SparkMode.ritual,
        scope: scope,
        timerMode: _timer,
        streakBreaksOnMiss: _breaksOnMiss,
        dependencies: deps,
        createdAt: now,
      );
    } else {
      final target = num.tryParse(_targetCtrl.text.trim()) ?? 0;
      final unit = _unitCtrl.text.trim().isEmpty
          ? null
          : _unitCtrl.text.trim();
      final scope = _kind == _Kind.shared
          ? SparkScope.shared
          : SparkScope.personal;
      spark = Spark(
        id: id,
        isleId: isleId,
        emoji: emoji,
        title: title,
        mode: SparkMode.metric,
        scope: scope,
        timerMode: _timer,
        streakBreaksOnMiss: _breaksOnMiss,
        metric: Metric(
          template: MetricTemplate.count,
          target: target,
          unit: unit,
        ),
        createdAt: now,
      );
    }

    ref.read(islesProvider.notifier).addSpark(isleId, spark);
    _reset();
    context.go('/isle');
  }

  Future<void> _pickTimer() async {
    final picked = await showModalBottomSheet<TimerMode>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TimerSheet(selected: _timer),
    );
    if (picked != null && picked != _timer) {
      setState(() => _timer = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.go('/isle'),
          child: const Text('Cancel',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
        ),
        title: const Text('New Spark'),
        actions: [
          TextButton(
            onPressed: _canCreate ? _create : null,
            child: Text(
              'Create',
              style: TextStyle(
                color: _canCreate
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFCBD5E1),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Live preview.
          Center(
            child: SparkWidget(
              emoji: _emojiPool[_mainEmojiIdx],
              state: _mainEmojiChosen
                  ? SparkState.lit
                  : SparkState.dull,
              size: 80,
            ),
          ),
          const SizedBox(height: 16),

          // Main spark + name.
          const _SectionLabel('Spark'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _Panel(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
              child: Row(children: [
                GestureDetector(
                  onTap: _cycleMain,
                  child: _SkewedEmojiSlot(
                      emoji: _emojiPool[_mainEmojiIdx],
                      lit: _mainEmojiChosen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tap to cycle emoji',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF94A3B8))),
                      TextField(
                        controller: _nameCtrl,
                        onChanged: (_) => setState(() {}),
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Name (optional)',
                          hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ]),

          // Dependency slots — ritual only.
          if (_isRitual) ...[
            const SizedBox(height: 24),
            const _SectionLabel('Ingredients'),
            const Divider(height: 1, color: Color(0xFFECEFF2)),
            _Panel(children: [
              for (int i = 0; i < _deps.length; i++) ...[
                _DepRow(
                  draft: _deps[i],
                  emoji: _emojiPool[_deps[i].idx],
                  onCycle: () => _cycleDep(i),
                  onLabelChanged: (_) => setState(() {}),
                ),
                if (i < _deps.length - 1)
                  const Divider(height: 1, color: Color(0xFFECEFF2)),
              ],
            ]),
          ],

          const SizedBox(height: 24),

          // Kind picker.
          const _SectionLabel('Kind'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              Expanded(
                child: _KindCard(
                  emoji: '🙋',
                  title: 'Just you',
                  selected: _kind == _Kind.solo,
                  onTap: () => setState(() => _kind = _Kind.solo),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KindCard(
                  emoji: '🤝',
                  title: 'Add people',
                  selected: _kind == _Kind.shared,
                  onTap: () => setState(() => _kind = _Kind.shared),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KindCard(
                  emoji: '📈',
                  title: 'Track a number',
                  selected: _kind == _Kind.metric,
                  onTap: () => setState(() => _kind = _Kind.metric),
                ),
              ),
            ]),
          ),

          // Metric fields.
          if (!_isRitual) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFECEFF2)),
            _Panel(children: [
              _FieldRow(
                label: 'Target',
                controller: _targetCtrl,
                hint: '0',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
              ),
              const Divider(height: 1, color: Color(0xFFECEFF2)),
              _FieldRow(
                label: 'Unit',
                controller: _unitCtrl,
                hint: 'e.g. pts',
                onChanged: (_) => setState(() {}),
              ),
              const Divider(height: 1, color: Color(0xFFECEFF2)),
              _ScopeToggle(
                shared: _kind == _Kind.shared,
                onChanged: (v) => setState(
                    () => _kind = v ? _Kind.shared : _Kind.metric),
              ),
            ]),
          ],

          const SizedBox(height: 24),

          // Timer.
          const _SectionLabel('Timer'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _Panel(children: [
            _NavRow(
              icon: Icons.schedule,
              label: 'Resets',
              value: _timerLabel(_timer),
              onTap: _pickTimer,
            ),
          ]),

          const SizedBox(height: 24),

          // Streak + Share.
          const _SectionLabel('Behavior'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _Panel(children: [
            _ToggleRow(
              label: 'Breaks on miss',
              subtitle: 'Streak resets if you miss a cycle',
              value: _breaksOnMiss,
              onChanged: (v) => setState(() => _breaksOnMiss = v),
            ),
            const Divider(height: 1, color: Color(0xFFECEFF2)),
            _NavRow(
              icon: Icons.share_outlined,
              label: 'Share',
              value: 'Invite',
              onTap: () => context.go('/isles'),
            ),
          ]),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _canCreate ? _create : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Create Spark',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

String _timerLabel(TimerMode m) => switch (m) {
      TimerMode.instant => 'Instant',
      TimerMode.daily => 'Daily',
      TimerMode.weekly => 'Weekly',
      TimerMode.monthly => 'Monthly',
    };

/// A draft for a dependency slot — keeps its own emoji index + label field.
class _DepDraft {
  _DepDraft();
  int idx = 0;
  bool active = false;
  final TextEditingController labelCtrl = TextEditingController();

  void cycle(int poolLength) {
    idx = (idx + 1) % poolLength;
  }
}

// -----------------------------------------------------------------------------
// Small chrome widgets.
// -----------------------------------------------------------------------------

class _SkewedEmojiSlot extends StatelessWidget {
  const _SkewedEmojiSlot({required this.emoji, required this.lit});
  final String emoji;
  final bool lit;
  static const _skew = -0.244;
  static const _counter = 0.244;

  @override
  Widget build(BuildContext context) {
    const size = 52.0;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(_skew),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: lit ? Colors.white : const Color(0xFFF4F6F8),
          border: Border.all(
            color: lit
                ? const Color(0xFF3B82F6)
                : const Color(0xFFECEFF2),
            width: lit ? 1.5 : 1,
          ),
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(_counter),
          child: Center(
            child: Text(emoji,
                style: const TextStyle(fontSize: 26, height: 1)),
          ),
        ),
      ),
    );
  }
}

class _DepRow extends StatelessWidget {
  const _DepRow({
    required this.draft,
    required this.emoji,
    required this.onCycle,
    required this.onLabelChanged,
  });
  final _DepDraft draft;
  final String emoji;
  final VoidCallback onCycle;
  final ValueChanged<String> onLabelChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(children: [
        GestureDetector(
          onTap: onCycle,
          child: _SkewedEmojiSlot(emoji: emoji, lit: draft.active),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: TextField(
            controller: draft.labelCtrl,
            onChanged: onLabelChanged,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'Label (optional)',
              hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ]),
    );
  }
}

class _KindCard extends StatelessWidget {
  const _KindCard({
    required this.emoji,
    required this.title,
    required this.selected,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF5FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFECEFF2),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26, height: 1)),
            const SizedBox(height: 6),
            Text(title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF64748B),
                )),
          ],
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    required this.onChanged,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(children: [
        SizedBox(
          width: 64,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ScopeToggle extends StatelessWidget {
  const _ScopeToggle({required this.shared, required this.onChanged});
  final bool shared;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(children: [
        const SizedBox(
          width: 64,
          child: Text('Scope',
              style:
                  TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        const Spacer(),
        _Segment(
            label: 'Just me',
            selected: !shared,
            onTap: () => onChanged(false)),
        const SizedBox(width: 6),
        _Segment(
            label: 'Together',
            selected: shared,
            onTap: () => onChanged(true)),
      ]),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFECEFF2),
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : const Color(0xFF64748B))),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(children: [
            Icon(icon, size: 20, color: const Color(0xFF64748B)),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B))),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 16, color: Color(0xFF94A3B8)),
          ]),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: const Color(0xFF3B82F6),
          onChanged: onChanged,
        ),
      ],
      ),
    );
  }
}

class _TimerSheet extends StatelessWidget {
  const _TimerSheet({required this.selected});
  final TimerMode selected;

  @override
  Widget build(BuildContext context) {
    const options = TimerMode.values;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 16, 22, 8),
            child: Text('Resets',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          const Divider(color: Color(0xFFECEFF2)),
          for (final m in options)
            ListTile(
              leading: Icon(Icons.schedule, size: 20,
                  color: m == selected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF94A3B8)),
              title: Text(_timerLabel(m),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: m == selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: m == selected
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF1F2937))),
              trailing: m == selected
                  ? const Icon(Icons.check,
                      size: 18, color: Color(0xFF3B82F6))
                  : null,
              onTap: () => Navigator.of(context).pop(m),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Color(0xFF94A3B8)),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFECEFF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final c in children) c],
        ),
      ),
    );
  }
}
