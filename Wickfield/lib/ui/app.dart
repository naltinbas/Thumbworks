import 'package:flutter/material.dart';

import '../best.dart';
import '../wick/wicks.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'wick_screen.dart';

/// The game: a field of wicks, and one being pressed.
class WickfieldApp extends StatefulWidget {
  const WickfieldApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the field and open this wick. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.lamp,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<WickfieldApp> createState() => _WickfieldAppState();
}

class _WickfieldAppState extends State<WickfieldApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a wick should start over rather than be picked up
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
      title: 'Wickfield',
      debugShowCheckedModeBanner: false,
      theme: WickfieldApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : WickScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (presses) async =>
                  await widget.best
                      ?.record(Wicks.at(playing).name, presses) ??
                  false,
              onNext: () => playing + 1 < Wicks.count
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
