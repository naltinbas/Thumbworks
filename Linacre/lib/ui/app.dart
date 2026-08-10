import 'package:flutter/material.dart';

import '../best.dart';
import '../wire/rounds.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'wire_screen.dart';

/// The game: a list of rounds, and one being played.
class LinacreApp extends StatefulWidget {
  const LinacreApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this round. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.braced,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<LinacreApp> createState() => _LinacreAppState();
}

class _LinacreAppState extends State<LinacreApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a round should start over rather than be picked up where
  /// it was left.
  int _go = 0;

  void _open(int number) => setState(() {
        _playing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final playing = _playing;

    return MaterialApp(
      title: 'Linacre',
      debugShowCheckedModeBanner: false,
      theme: LinacreApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : WireScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (moves) async =>
                  await widget.best?.record(Rounds.at(playing).name, moves) ??
                  false,
              onNext: () => playing + 1 < Rounds.count
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
