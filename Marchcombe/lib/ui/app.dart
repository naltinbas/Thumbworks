import 'package:flutter/material.dart';

import '../best.dart';
import '../dye/lands.dart';
import 'dye_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of estates, and one being painted.
class MarchcombeApp extends StatefulWidget {
  const MarchcombeApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this estate. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.dyes.first,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<MarchcombeApp> createState() => _MarchcombeAppState();
}

class _MarchcombeAppState extends State<MarchcombeApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a map should be wiped rather than picked up where it was
  /// left.
  int _go = 0;

  void _open(int number) => setState(() {
        _playing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final playing = _playing;

    return MaterialApp(
      title: 'Marchcombe',
      debugShowCheckedModeBanner: false,
      theme: MarchcombeApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : DyeScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (dyes) async =>
                  await widget.best?.record(Estates.at(playing).name, dyes) ??
                  false,
              onNext: () => playing + 1 < Estates.count
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
