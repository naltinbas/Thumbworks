import 'package:flutter/material.dart';

import '../best_score.dart';
import '../game/lexicon.dart';
import 'game_screen.dart';
import 'palette.dart';

/// The whole app: one screen, over one round.
class LatchwordApp extends StatelessWidget {
  const LatchwordApp({super.key, required this.lexicon, required this.best});

  final Lexicon lexicon;
  final BestScore best;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Latchword',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: GameScreen(lexicon: lexicon, best: best),
      );

  /// One dark theme, taken from the colours the board is drawn in, so the
  /// words around a round look like they belong to it.
  static final ThemeData theme = _build();

  static ThemeData _build() {
    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Palette.trace,
        brightness: Brightness.dark,
        surface: Palette.backdrop,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: Palette.backdrop,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Palette.word,
          foregroundColor: Palette.backdrop,
          // Wide and tall enough to be the obvious thing to hit with a thumb
          // on a screen the player is already touching.
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
            letterSpacing: 1.4,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Palette.inkDim,
          minimumSize: const Size(0, 48),
          textStyle: base.textTheme.titleMedium?.copyWith(fontSize: 15),
        ),
      ),
    );
  }
}
