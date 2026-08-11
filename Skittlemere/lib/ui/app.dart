import 'package:flutter/material.dart';

import '../alley/frames.dart';
import '../best.dart';
import 'alley_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a lane of alleys, and one being bowled.
class SkittlemereApp extends StatefulWidget {
  const SkittlemereApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the lane and open this alley. A test or a screenshot passes
  /// it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.alley,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.skittle,
      brightness: Brightness.dark,
      surface: Palette.alley,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<SkittlemereApp> createState() => _SkittlemereAppState();
}

class _SkittlemereAppState extends State<SkittlemereApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever an alley should start over rather than be picked
  /// up where it was left.
  int _go = 0;

  void _open(int number) => setState(() {
        _playing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final playing = _playing;

    return MaterialApp(
      title: 'Skittlemere',
      debugShowCheckedModeBanner: false,
      theme: SkittlemereApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : AlleyScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Frames.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Frames.count
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
