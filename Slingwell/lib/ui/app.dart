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
          // Built on the theme's own label style rather than written from
          // nothing: a whole TextStyle here replaces that one instead of
          // merging with it, and a style with no family in it falls back to
          // whatever the platform hands out, which is a different face from
          // the rest of the game.
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
