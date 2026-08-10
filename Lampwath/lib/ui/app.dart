import 'package:flutter/material.dart';

import '../best.dart';
import '../wath/bridges.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'wath_screen.dart';

/// The game: a list of bridges, and one being crossed.
class LampwathApp extends StatefulWidget {
  const LampwathApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this bridge. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.lantern,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<LampwathApp> createState() => _LampwathAppState();
}

class _LampwathAppState extends State<LampwathApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a night should start over rather than be picked up where
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
      title: 'Lampwath',
      debugShowCheckedModeBanner: false,
      theme: LampwathApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : WathScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (minutes) async =>
                  await widget.best
                      ?.record(Bridges.at(playing).name, minutes) ??
                  false,
              onNext: () => playing + 1 < Bridges.count
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
