import 'package:flutter/material.dart';

import '../best_run.dart';
import 'game_screen.dart';
import 'palette.dart';

/// The whole app: one screen, over one run.
class SlingwellApp extends StatelessWidget {
  const SlingwellApp({super.key, required this.best});

  final BestRun best;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Slingwell',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: GameScreen(best: best),
      );

  /// One dark theme, taken from the colours the world is drawn in, so the
  /// words over a run look like they belong to it.
  static final ThemeData theme = _build();

  static ThemeData _build() {
    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Palette.well,
        brightness: Brightness.dark,
        surface: Palette.skyTop,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: Palette.skyTop,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Palette.craft,
          foregroundColor: Palette.wellCore,
          // Wide and tall enough to be the obvious thing to hit with a thumb
          // on the screen where the player is already tapping.
          minimumSize: const Size(220, 56),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
