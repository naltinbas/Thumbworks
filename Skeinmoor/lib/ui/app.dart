import 'package:flutter/material.dart';

import '../best.dart';
import '../thread/boards.dart';
import 'board_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of boards, and one being filled.
class SkeinmoorApp extends StatefulWidget {
  const SkeinmoorApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this board. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.wool.first,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<SkeinmoorApp> createState() => _SkeinmoorAppState();
}

class _SkeinmoorAppState extends State<SkeinmoorApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a board should be laid out fresh rather than picked up
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
      title: 'Skeinmoor',
      debugShowCheckedModeBanner: false,
      theme: SkeinmoorApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : BoardScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (hints) async =>
                  await widget.best?.record(Boards.at(playing).name, hints) ??
                  false,
              onNext: () => playing + 1 < Boards.count
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
