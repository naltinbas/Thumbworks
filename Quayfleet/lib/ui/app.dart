import 'package:flutter/material.dart';

import '../berth/quays.dart';
import '../best.dart';
import 'berth_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of days, and one being worked.
class QuayfleetApp extends StatefulWidget {
  const QuayfleetApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this day. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.berthed,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<QuayfleetApp> createState() => _QuayfleetAppState();
}

class _QuayfleetAppState extends State<QuayfleetApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a day should be started over rather than picked up where
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
      title: 'Quayfleet',
      debugShowCheckedModeBanner: false,
      theme: QuayfleetApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : BerthScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (ships) async =>
                  await widget.best?.record(Days.at(playing).name, ships) ??
                  false,
              onNext: () => playing + 1 < Days.count
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
