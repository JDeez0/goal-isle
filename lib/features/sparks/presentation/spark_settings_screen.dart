import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets/spark_widget.dart';
import '../../../core/models/spark.dart';
import '../../../core/models/spark_shape.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// Spark Settings — rename, reshape the silhouette (4 corner sliders with a
/// live preview), and delete the spark.
class SparkSettingsScreen extends ConsumerStatefulWidget {
  const SparkSettingsScreen({super.key});

  @override
  ConsumerState<SparkSettingsScreen> createState() =>
      _SparkSettingsScreenState();
}

class _SparkSettingsScreenState extends ConsumerState<SparkSettingsScreen> {
  final _nameCtrl = TextEditingController();
  String? _loadedSparkId;
  double _tl = 0.4, _tr = 0.12, _br = 0.4, _bl = 0.12;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _ensureLoaded(Spark? spark) {
    if (spark == null) return;
    // Re-seed whenever the spark changes (handles screen reuse)
    if (_loadedSparkId == spark.id) return;
    _nameCtrl.text = spark.title ?? '';
    _tl = spark.shape.tl;
    _tr = spark.shape.tr;
    _br = spark.shape.br;
    _bl = spark.shape.bl;
    _loadedSparkId = spark.id;
  }

  void _save(Spark spark) {
    final updated = spark.copyWith(
      title: _nameCtrl.text.trim().isEmpty ? spark.title : _nameCtrl.text.trim(),
      shape: SparkShape(tl: _tl, tr: _tr, br: _br, bl: _bl),
    );
    ref.read(islesProvider.notifier).updateSpark(spark.isleId, updated);
    context.go('/spark');
  }

  Future<void> _delete(Spark spark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${spark.title ?? 'spark'}?'),
        content: const Text(
            'This removes the key from its Isle. This can’t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    ref.read(islesProvider.notifier).removeSpark(spark.isleId, spark.id);
    ref.read(activeSparkIdProvider.notifier).state = null;
    if (mounted) context.go('/isle');
  }

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
            onPressed: () => context.go('/spark'),
          ),
          title: const Text('Settings'),
        ),
        body: const Center(
          child: Text('Spark not found',
              style: TextStyle(color: Color(0xFF94A3B8))),
        ),
      );
    }

    // Seed local controllers once the spark is available.
    _ensureLoaded(spark);

    final previewShape = SparkShape(tl: _tl, tr: _tr, br: _br, bl: _bl);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/spark'),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          // Name section.
          const _SectionLabel('Name'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _Panel(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
              child: TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Spark name',
                  hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Shape section — live preview + 4 corner sliders.
          const _SectionLabel('Shape'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _Panel(children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 22, 0, 8),
                child: SparkWidget(
                  emoji: spark.emoji,
                  state: spark.state,
                  shape: previewShape,
                  size: 88,
                ),
              ),
            ),
            _ShapeSlider(
              label: 'Top-left',
              value: _tl,
              onChanged: (v) => setState(() => _tl = v),
            ),
            const Divider(height: 1, color: Color(0xFFECEFF2)),
            _ShapeSlider(
              label: 'Top-right',
              value: _tr,
              onChanged: (v) => setState(() => _tr = v),
            ),
            const Divider(height: 1, color: Color(0xFFECEFF2)),
            _ShapeSlider(
              label: 'Bottom-right',
              value: _br,
              onChanged: (v) => setState(() => _br = v),
            ),
            const Divider(height: 1, color: Color(0xFFECEFF2)),
            _ShapeSlider(
              label: 'Bottom-left',
              value: _bl,
              onChanged: (v) => setState(() => _bl = v),
            ),
          ]),

          const SizedBox(height: 24),

          // Danger zone.
          const _SectionLabel('Danger zone'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _Panel(children: [
            _DangerRow(label: 'Delete', onTap: () => _delete(spark)),
          ]),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => _save(spark),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Done',
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

class _ShapeSlider extends StatelessWidget {
  const _ShapeSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 8, 6),
      child: Row(children: [
        SizedBox(
          width: 96,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 0.5,
            divisions: 50,
            activeColor: const Color(0xFF3B82F6),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 38,
          child: Text((value * 100).round().toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
        ),
      ]),
    );
  }
}

class _DangerRow extends StatelessWidget {
  const _DangerRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(children: [
            Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
            SizedBox(width: 14),
            Text('Delete',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444))),
          ]),
        ),
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
