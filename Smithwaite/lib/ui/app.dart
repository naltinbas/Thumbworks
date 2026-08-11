import 'package:flutter/material.dart';

import '../best.dart';
import '../forge/puzzles.dart';
import 'forge_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a bench of puzzles, and one in hand.
class SmithwaiteApp extends StatefulWidget {
  const SmithwaiteApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the bench and open this puzzle. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.soot,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.ring,
      brightness: Brightness.dark,
      surface: Palette.soot,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<SmithwaiteApp> createState() => _SmithwaiteAppState();
}

class _SmithwaiteAppState extends State<SmithwaiteApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a puzzle should start over rather than be picked up
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
      title: 'Smithwaite',
      debugShowCheckedModeBanner: false,
      theme: SmithwaiteApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : ForgeScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (moves) async =>
                  await widget.best
                      ?.record(Puzzles.at(playing).name, moves) ??
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
