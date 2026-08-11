import 'package:flutter/material.dart';

import '../best.dart';
import '../toss/wagers.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'toss_screen.dart';

/// The game: a room of tables, and one being played.
class PennygillApp extends StatefulWidget {
  const PennygillApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the room and open this table. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.taproom,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.head,
      brightness: Brightness.dark,
      surface: Palette.taproom,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<PennygillApp> createState() => _PennygillAppState();
}

class _PennygillAppState extends State<PennygillApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a table should be dealt fresh rather than picked up
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
      title: 'Pennygill',
      debugShowCheckedModeBanner: false,
      theme: PennygillApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : TossScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (conceded) async =>
                  await widget.best
                      ?.record(Wagers.at(playing).name, conceded) ??
                  false,
              onNext: () => playing + 1 < Wagers.count
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
