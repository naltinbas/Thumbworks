import 'package:flutter/material.dart';

import '../best.dart';
import '../ring/peals.dart';
import 'palette.dart';
import 'ring_screen.dart';
import 'title_screen.dart';

/// The game: a list of towers, and one being rung.
class TrebleswayApp extends StatefulWidget {
  const TrebleswayApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this peal. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.bronze,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<TrebleswayApp> createState() => _TrebleswayAppState();
}

class _TrebleswayAppState extends State<TrebleswayApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a peal should start over rather than be picked up where
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
      title: 'Treblesway',
      debugShowCheckedModeBanner: false,
      theme: TrebleswayApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : RingScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (hints) async =>
                  await widget.best?.record(Peals.at(playing).name, hints) ??
                  false,
              onNext: () => playing + 1 < Peals.count
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
