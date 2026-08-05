import 'package:flutter/material.dart';

import '../best.dart';
import '../fit/boxes.dart';
import 'board_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of puzzles, and one being packed.
class PackwoldApp extends StatefulWidget {
  const PackwoldApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this puzzle. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.paint[2],
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<PackwoldApp> createState() => _PackwoldAppState();
}

class _PackwoldAppState extends State<PackwoldApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a puzzle should be tipped out rather than picked up
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
      title: 'Packwold',
      debugShowCheckedModeBanner: false,
      theme: PackwoldApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : BoardScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (hints) async =>
                  await widget.best?.record(Puzzles.at(playing).name, hints) ??
                  false,
              onNext: () => playing + 1 < Puzzles.count
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
