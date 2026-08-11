import 'package:flutter/material.dart';

import '../best.dart';
import '../garden/evenings.dart';
import 'garden_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of evenings, and one being read.
class TallowfieldApp extends StatefulWidget {
  const TallowfieldApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this evening. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.dusk,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.flame,
      brightness: Brightness.dark,
      surface: Palette.dusk,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<TallowfieldApp> createState() => _TallowfieldAppState();
}

class _TallowfieldAppState extends State<TallowfieldApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever an evening should start over rather than be picked up
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
      title: 'Tallowfield',
      debugShowCheckedModeBanner: false,
      theme: TallowfieldApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : GardenScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (slips) async =>
                  await widget.best
                      ?.record(Evenings.at(playing).name, slips) ??
                  false,
              onNext: () => playing + 1 < Evenings.count
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
