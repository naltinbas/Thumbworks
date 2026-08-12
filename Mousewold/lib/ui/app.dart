import 'package:flutter/material.dart';

import '../best.dart';
import '../chase/grounds.dart';
import 'chase_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a wold of grounds, and one being chased.
class MousewoldApp extends StatefulWidget {
  const MousewoldApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this ground. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.cat,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<MousewoldApp> createState() => _MousewoldAppState();
}

class _MousewoldAppState extends State<MousewoldApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a ground should start over rather than be picked
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
      title: 'Mousewold',
      debugShowCheckedModeBanner: false,
      theme: MousewoldApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : ChaseScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (rounds) async =>
                  await widget.best
                      ?.record(Grounds.at(playing).name, rounds) ??
                  false,
              onNext: () => playing + 1 < Grounds.count
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
