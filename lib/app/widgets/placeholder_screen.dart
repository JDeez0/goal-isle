import 'package:flutter/material.dart';

/// Minimal placeholder screen used by every route in the GoRouter shell.
///
/// Later phases replace each [PlaceholderScreen] with the real screen for its
/// route. For now it just centers the route's [title] so the navigation graph
/// compiles and can be exercised end-to-end.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  /// The route name shown in the center of the screen.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
