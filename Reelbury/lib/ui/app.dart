import 'package:flutter/material.dart';

import '../best.dart';
import '../reel/rounds.dart';
import 'palette.dart';
import 'round_screen.dart';
import 'title_screen.dart';

/// The game: a list of rounds, and one being paired up.
class ReelburyApp extends StatefulWidget {
  const ReelburyApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this round. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.caller,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ReelburyApp> createState() => _ReelburyAppState();
}

class _ReelburyAppState extends State<ReelburyApp> {
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
      title: 'Reelbury',
      debugShowCheckedModeBanner: false,
      theme: ReelburyApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : RoundScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (changes) async =>
                  await widget.best?.record(Rounds.at(playing).name, changes) ??
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
