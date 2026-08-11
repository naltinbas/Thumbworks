import 'package:flutter/material.dart';

import '../best.dart';
import '../moor/moors.dart';
import 'moor_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a run of moors, and one being set.
class MillgreaveApp extends StatefulWidget {
  const MillgreaveApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this moor. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.sky,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.sail,
      brightness: Brightness.dark,
      surface: Palette.sky,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<MillgreaveApp> createState() => _MillgreaveAppState();
}

class _MillgreaveAppState extends State<MillgreaveApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a moor should start over rather than be picked up
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
      title: 'Millgreave',
      debugShowCheckedModeBanner: false,
      theme: MillgreaveApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : MoorScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Moors.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Moors.count
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
