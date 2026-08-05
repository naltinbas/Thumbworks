import 'package:flutter/material.dart';

import '../best.dart';
import '../round/parishes.dart';
import 'palette.dart';
import 'round_screen.dart';
import 'title_screen.dart';

/// The game: a list of parishes, and one being gritted.
class RimeworthApp extends StatefulWidget {
  const RimeworthApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this parish. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.lorry,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<RimeworthApp> createState() => _RimeworthAppState();
}

class _RimeworthAppState extends State<RimeworthApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a parish should be started over rather than picked up
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
      title: 'Rimeworth',
      debugShowCheckedModeBanner: false,
      theme: RimeworthApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : RoundScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (runs) async =>
                  await widget.best?.record(Grittings.at(playing).name, runs) ??
                  false,
              onNext: () => playing + 1 < Grittings.count
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
