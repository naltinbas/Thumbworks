import 'package:flutter/material.dart';

import '../best.dart';
import '../lamps/levels.dart';
import 'board_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of boards, and one being put out.
class WickfellApp extends StatefulWidget {
  const WickfellApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this board. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.lit,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<WickfellApp> createState() => _WickfellAppState();
}

class _WickfellAppState extends State<WickfellApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a board should be relit rather than picked up where it
  /// was left.
  int _go = 0;

  void _open(int number) => setState(() {
        _playing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final playing = _playing;

    return MaterialApp(
      title: 'Wickfell',
      debugShowCheckedModeBanner: false,
      theme: WickfellApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : BoardScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (presses) async =>
                  await widget.best
                      ?.record(Levels.at(playing).name, presses) ??
                  false,
              onNext: () => playing + 1 < Levels.count
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
