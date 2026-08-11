import 'package:flutter/material.dart';

import '../best.dart';
import '../plot/plots.dart';
import 'palette.dart';
import 'plot_screen.dart';
import 'title_screen.dart';

/// The game: a garden of plots, and one being shaded.
class ShadewellApp extends StatefulWidget {
  const ShadewellApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the garden and open this plot. A test or a screenshot passes
  /// it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.shade,
      brightness: Brightness.dark,
      surface: Palette.paper,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ShadewellApp> createState() => _ShadewellAppState();
}

class _ShadewellAppState extends State<ShadewellApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a plot should start over rather than be picked up
  /// where it was left.
  int _go = 0;

  void _open(int number) => setState(() {
        _playing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final playing = _playing;

    return MaterialApp(
      title: 'Shadewell',
      debugShowCheckedModeBanner: false,
      theme: ShadewellApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : PlotScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Plots.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Plots.count
                  ? _open(playing + 1)
                  : setState(() => _playing = null),
              onLeave: () => setState(() {
                _playing = null;
                _go++;
              }),
            ),
    );
  }
}
