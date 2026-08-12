import 'package:flutter/material.dart';

import '../best.dart';
import '../quire/quires.dart';
import 'palette.dart';
import 'quire_screen.dart';
import 'title_screen.dart';

/// The game: a bench of quires, and one being woven.
class QuirebeckApp extends StatefulWidget {
  const QuirebeckApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this quire. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.plate,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<QuirebeckApp> createState() => _QuirebeckAppState();
}

class _QuirebeckAppState extends State<QuirebeckApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a quire should start over rather than be picked
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
      title: 'Quirebeck',
      debugShowCheckedModeBanner: false,
      theme: QuirebeckApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : QuireScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (weaves) async =>
                  await widget.best
                      ?.record(Quires.at(playing).name, weaves) ??
                  false,
              onNext: () => playing + 1 < Quires.count
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
