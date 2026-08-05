import 'package:flutter/material.dart';

import '../best.dart';
import '../sift/puzzles.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'sift_screen.dart';

/// The game: a list of works, and one being set.
class WinnowmereApp extends StatefulWidget {
  const WinnowmereApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this works. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.rung,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<WinnowmereApp> createState() => _WinnowmereAppState();
}

class _WinnowmereAppState extends State<WinnowmereApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a works should be emptied rather than picked up where it
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
      title: 'Winnowmere',
      debugShowCheckedModeBanner: false,
      theme: WinnowmereApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : SiftScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (crosses) async =>
                  await widget.best
                      ?.record(Siftings.at(playing).name, crosses) ??
                  false,
              onNext: () => playing + 1 < Siftings.count
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
