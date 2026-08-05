import 'package:flutter/material.dart';

import '../best.dart';
import '../chase/maps.dart';
import 'chase_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of maps, and one being chased across.
class WarrenshawApp extends StatefulWidget {
  const WarrenshawApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this map. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.seeker,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<WarrenshawApp> createState() => _WarrenshawAppState();
}

class _WarrenshawAppState extends State<WarrenshawApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a map should start over rather than be picked up where
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
      title: 'Warrenshaw',
      debugShowCheckedModeBanner: false,
      theme: WarrenshawApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : ChaseScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (moves) async =>
                  await widget.best?.record(Warrens.at(playing).name, moves) ??
                  false,
              onNext: () => playing + 1 < Warrens.count
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
