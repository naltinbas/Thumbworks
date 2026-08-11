import 'package:flutter/material.dart';

import '../best.dart';
import '../pail/errands.dart';
import 'pail_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a shelf of errands, and one being run.
class PailsworthApp extends StatefulWidget {
  const PailsworthApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the shelf and open this errand. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.stone,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.water,
      brightness: Brightness.dark,
      surface: Palette.stone,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<PailsworthApp> createState() => _PailsworthAppState();
}

class _PailsworthAppState extends State<PailsworthApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever an errand should start over rather than be picked
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
      title: 'Pailsworth',
      debugShowCheckedModeBanner: false,
      theme: PailsworthApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : PailScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (pours) async =>
                  await widget.best
                      ?.record(Errands.at(playing).name, pours) ??
                  false,
              onNext: () => playing + 1 < Errands.count
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
