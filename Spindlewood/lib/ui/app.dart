import 'package:flutter/material.dart';

import '../best.dart';
import '../tower/spindles.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'tower_screen.dart';

/// The game: a bench of towers, and one being raised.
class SpindlewoodApp extends StatefulWidget {
  const SpindlewoodApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the bench and open this tower. A test or a screenshot passes
  /// it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.bench,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.rounds.first,
      brightness: Brightness.dark,
      surface: Palette.bench,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<SpindlewoodApp> createState() => _SpindlewoodAppState();
}

class _SpindlewoodAppState extends State<SpindlewoodApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a tower should start over rather than be picked up
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
      title: 'Spindlewood',
      debugShowCheckedModeBanner: false,
      theme: SpindlewoodApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : TowerScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (moves) async =>
                  await widget.best
                      ?.record(Spindles.at(playing).name, moves) ??
                  false,
              onNext: () => playing + 1 < Spindles.count
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
