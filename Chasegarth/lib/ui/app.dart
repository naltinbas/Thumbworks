import 'package:flutter/material.dart';

import '../best.dart';
import '../forme/chases.dart';
import 'forme_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of formes, and one on the bench.
class ChasegarthApp extends StatefulWidget {
  const ChasegarthApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this forme. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.brass,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ChasegarthApp> createState() => _ChasegarthAppState();
}

class _ChasegarthAppState extends State<ChasegarthApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a forme should start over rather than be picked up where
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
      title: 'Chasegarth',
      debugShowCheckedModeBanner: false,
      theme: ChasegarthApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : FormeScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (slides) async =>
                  await widget.best?.record(Formes.at(playing).name, slides) ??
                  false,
              onNext: () => playing + 1 < Formes.count
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
