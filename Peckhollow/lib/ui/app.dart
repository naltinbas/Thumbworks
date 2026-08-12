import 'package:flutter/material.dart';

import '../best.dart';
import '../yard/yards.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'yard_screen.dart';

/// The game: a hollow of yards, and one being flipped.
class PeckhollowApp extends StatefulWidget {
  const PeckhollowApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this yard. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.crown,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<PeckhollowApp> createState() => _PeckhollowAppState();
}

class _PeckhollowAppState extends State<PeckhollowApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a yard should start over rather than be picked
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
      title: 'Peckhollow',
      debugShowCheckedModeBanner: false,
      theme: PeckhollowApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : YardScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (flips) async =>
                  await widget.best
                      ?.record(Yards.at(playing).name, flips) ??
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
