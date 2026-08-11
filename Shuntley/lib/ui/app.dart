import 'package:flutter/material.dart';

import '../best.dart';
import '../shunt/trays.dart';
import 'palette.dart';
import 'shunt_screen.dart';
import 'title_screen.dart';

/// The game: a bench of trays, and one being shunted.
class ShuntleyApp extends StatefulWidget {
  const ShuntleyApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the bench and open this tray. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.bench,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.tile,
      brightness: Brightness.dark,
      surface: Palette.bench,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ShuntleyApp> createState() => _ShuntleyAppState();
}

class _ShuntleyAppState extends State<ShuntleyApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a tray should start over rather than be picked up
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
      title: 'Shuntley',
      debugShowCheckedModeBanner: false,
      theme: ShuntleyApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : ShuntScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (shunts) async =>
                  await widget.best
                      ?.record(Trays.at(playing).name, shunts) ??
                  false,
              onNext: () => playing + 1 < Trays.count
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
