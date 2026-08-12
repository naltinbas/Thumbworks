import 'package:flutter/material.dart';

import '../bead/rings.dart';
import '../best.dart';
import 'bead_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a stall of rings, and one being strung.
class BeadlowApp extends StatefulWidget {
  const BeadlowApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this ring. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.amber,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<BeadlowApp> createState() => _BeadlowAppState();
}

class _BeadlowAppState extends State<BeadlowApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a ring should start over rather than be picked
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
      title: 'Beadlow',
      debugShowCheckedModeBanner: false,
      theme: BeadlowApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : BeadScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (strings) async =>
                  await widget.best
                      ?.record(Rings.at(playing).name, strings) ??
                  false,
              onNext: () => playing + 1 < Rings.count
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
