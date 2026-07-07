import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import 'router.dart';

/// Root widget for the Goal Isle app.
///
/// Builds a [MaterialApp.router] configured with the GoRouter from
/// [routerProvider] and the Goal Isle theme from [createAppTheme].
class GoalIsleApp extends ConsumerWidget {
  const GoalIsleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Goal Isle',
      debugShowCheckedModeBanner: false,
      theme: createAppTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
