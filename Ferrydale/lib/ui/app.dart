import 'package:flutter/material.dart';

import '../best.dart';
import '../ferry/ferries.dart';
import 'ferry_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a dale of ferries, and one being rowed.
class FerrydaleApp extends StatefulWidget {
  const FerrydaleApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the dale and open this ferry. A test or a screenshot passes
  /// it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.boatRim,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<FerrydaleApp> createState() => _FerrydaleAppState();
}

class _FerrydaleAppState extends State<FerrydaleApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a river should start over rather than be picked
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
      title: 'Ferrydale',
      debugShowCheckedModeBanner: false,
      theme: FerrydaleApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : FerryScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (crossings) async =>
                  await widget.best
                      ?.record(Ferries.at(playing).name, crossings) ??
                  false,
              onNext: () => playing + 1 < Ferries.count
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
