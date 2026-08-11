import 'package:flutter/material.dart';

import '../best.dart';
import '../green/greens.dart';
import 'green_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a season of greens, and one card being written.
class TurnsteadApp extends StatefulWidget {
  const TurnsteadApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this green. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.evening,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.badges[3],
      brightness: Brightness.dark,
      surface: Palette.evening,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<TurnsteadApp> createState() => _TurnsteadAppState();
}

class _TurnsteadAppState extends State<TurnsteadApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a card should start over rather than be picked up
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
      title: 'Turnstead',
      debugShowCheckedModeBanner: false,
      theme: TurnsteadApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : GreenScreen(
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
