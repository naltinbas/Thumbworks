import 'package:flutter/material.dart';

import '../best.dart';
import '../mere/fields.dart';
import 'mere_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a mere of fields, and one being stepped.
class TussockmereApp extends StatefulWidget {
  const TussockmereApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this field. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.gold,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<TussockmereApp> createState() => _TussockmereAppState();
}

class _TussockmereAppState extends State<TussockmereApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a field should start over rather than be picked
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
      title: 'Tussockmere',
      debugShowCheckedModeBanner: false,
      theme: TussockmereApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : MereScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (steps) async =>
                  await widget.best
                      ?.record(Fields.at(playing).name, steps) ??
                  false,
              onNext: () => playing + 1 < Fields.count
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
