import 'package:flutter/material.dart';

import '../best.dart';
import '../griddle/batches.dart';
import 'griddle_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of batches, and one on the griddle.
class ShrovehamApp extends StatefulWidget {
  const ShrovehamApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this batch. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.iron,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.cake,
      brightness: Brightness.dark,
      surface: Palette.iron,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ShrovehamApp> createState() => _ShrovehamAppState();
}

class _ShrovehamAppState extends State<ShrovehamApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a batch should start over rather than be picked up
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
      title: 'Shroveham',
      debugShowCheckedModeBanner: false,
      theme: ShrovehamApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : GriddleScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (flips) async =>
                  await widget.best
                      ?.record(Batches.at(playing).name, flips) ??
                  false,
              onNext: () => playing + 1 < Batches.count
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
