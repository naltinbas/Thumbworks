import 'package:flutter/material.dart';

import '../best.dart';
import '../book/days.dart';
import 'book_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a ledger of days, and one being kept.
class HirebeckApp extends StatefulWidget {
  const HirebeckApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the ledger and open this day. A test or a screenshot passes
  /// it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.ledger,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.bookedEdge,
      brightness: Brightness.dark,
      surface: Palette.ledger,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<HirebeckApp> createState() => _HirebeckAppState();
}

class _HirebeckAppState extends State<HirebeckApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a day should start over rather than be picked up
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
      title: 'Hirebeck',
      debugShowCheckedModeBanner: false,
      theme: HirebeckApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : BookScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Days.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Days.count
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
