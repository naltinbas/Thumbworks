import 'package:flutter/material.dart';

import '../best.dart';
import '../board/puzzles.dart';
import 'board_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of puzzles, and one being solved.
class RookvaleApp extends StatefulWidget {
  const RookvaleApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this puzzle. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.picked,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<RookvaleApp> createState() => _RookvaleAppState();
}

class _RookvaleAppState extends State<RookvaleApp> {
  late int? _solving = widget.opensAt;

  /// Bumped whenever a puzzle should be set up again rather than picked up
  /// where it was left.
  int _go = 0;

  void _open(int number) => setState(() {
        _solving = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final solving = _solving;

    return MaterialApp(
      title: 'Rookvale',
      debugShowCheckedModeBanner: false,
      theme: RookvaleApp.theme,
      home: solving == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : BoardScreen(
              key: ValueKey('$solving $_go'),
              number: solving,
              onDone: ({required bool clean}) async =>
                  await widget.best
                      ?.record(Puzzles.at(solving).name, clean: clean) ??
                  false,
              onNext: () => solving + 1 < Puzzles.count
                  ? _open(solving + 1)
                  : setState(() => _solving = null),
              onLeave: () => setState(() {
                _solving = null;
                _go++;
              }),
            ),
    );
  }
}
