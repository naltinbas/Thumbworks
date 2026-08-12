import 'package:flutter/material.dart';

import '../best.dart';
import '../wall/pitches.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'wall_screen.dart';

/// The game: a fell of pitches, and one being walled.
class CopestoneApp extends StatefulWidget {
  const CopestoneApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this pitch. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.sand,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<CopestoneApp> createState() => _CopestoneAppState();
}

class _CopestoneAppState extends State<CopestoneApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a pitch should start over rather than be picked
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
      title: 'Copestone',
      debugShowCheckedModeBanner: false,
      theme: CopestoneApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : WallScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Pitches.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Pitches.count
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
