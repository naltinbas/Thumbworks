import 'package:flutter/material.dart';

import '../best.dart';
import '../game/field.dart';
import '../game/plots.dart';
import 'palette.dart';
import 'plot_screen.dart';
import 'title_screen.dart';

/// The game: a list of plots, and one being dug.
class CinderplotApp extends StatefulWidget {
  const CinderplotApp({super.key, this.best, this.opensAt, this.opening});

  /// The records. Null in a test that does not care.
  final Best? best;

  /// Skip the list and open this plot. A test or a screenshot passes it.
  final int? opensAt;

  /// A board to play instead of laying one out. Likewise.
  final Field? opening;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.ember,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<CinderplotApp> createState() => _CinderplotAppState();
}

class _CinderplotAppState extends State<CinderplotApp> {
  late int? _digging = widget.opensAt;

  /// Bumped for Another one, so the plot lays out a board nobody has seen
  /// rather than the one just finished.
  int _board = 0;

  @override
  Widget build(BuildContext context) {
    final digging = _digging;

    return MaterialApp(
      title: 'Cinderplot',
      debugShowCheckedModeBanner: false,
      theme: CinderplotApp.theme,
      home: digging == null
          ? TitleScreen(
              best: widget.best,
              onPlay: (which) => setState(() {
                _digging = which;
                _board++;
              }),
            )
          : PlotScreen(
              key: ValueKey('$digging $_board'),
              which: digging,
              seed: _board,
              opening: _board <= 1 ? widget.opening : null,
              onCleared: (seconds) async =>
                  await widget.best?.record(Plots.at(digging).name, seconds) ??
                  false,
              onAgain: () => setState(() => _board++),
              onLeave: () => setState(() => _digging = null),
            ),
    );
  }
}
