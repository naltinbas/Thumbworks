import 'package:flutter/material.dart';

import '../best.dart';
import '../ley/greens.dart';
import 'ley_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a moor of greens, and one being raised.
class LeystoneApp extends StatefulWidget {
  const LeystoneApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this green. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.done,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<LeystoneApp> createState() => _LeystoneAppState();
}

class _LeystoneAppState extends State<LeystoneApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a green should start over rather than be picked
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
      title: 'Leystone',
      debugShowCheckedModeBanner: false,
      theme: LeystoneApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : LeyScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Greens.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Greens.count
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
