import 'package:flutter/material.dart';

import '../best.dart';
import '../till/rounds.dart';
import 'counter_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: the counter book, and one customer being served.
class GroatsworthApp extends StatefulWidget {
  const GroatsworthApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the book and open this round. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.brass,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<GroatsworthApp> createState() => _GroatsworthAppState();
}

class _GroatsworthAppState extends State<GroatsworthApp> {
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
      title: 'Groatsworth',
      debugShowCheckedModeBanner: false,
      theme: GroatsworthApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : CounterScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (coins) async =>
                  await widget.best?.record(Rounds.at(playing).name, coins) ??
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
