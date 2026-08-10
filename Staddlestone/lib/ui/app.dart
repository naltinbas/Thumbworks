import 'package:flutter/material.dart';

import '../best.dart';
import '../mill/yards.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'yard_screen.dart';

/// The game: a list of yards, and one being worked.
class StaddlestoneApp extends StatefulWidget {
  const StaddlestoneApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this yard. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.liftedStone,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<StaddlestoneApp> createState() => _StaddlestoneAppState();
}

class _StaddlestoneAppState extends State<StaddlestoneApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a yard should start over rather than be picked up where
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
      title: 'Staddlestone',
      debugShowCheckedModeBanner: false,
      theme: StaddlestoneApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : YardScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (moves) async =>
                  await widget.best?.record(Yards.at(playing).name, moves) ??
                  false,
              onNext: () => playing + 1 < Yards.count
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
