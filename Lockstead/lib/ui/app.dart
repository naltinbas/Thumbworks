import 'package:flutter/material.dart';

import '../best.dart';
import '../lock/boards.dart';
import '../lock/marks.dart';
import 'board_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a rack of locks, and one being picked.
class LocksteadApp extends StatefulWidget {
  const LocksteadApp({
    super.key,
    this.best,
    this.opensAt,
    this.marks,
    this.secret,
  });

  final Best? best;

  /// Skip the rack and open this lock. A test or a screenshot passes it.
  final int? opensAt;

  /// A table of marks somebody has already worked out, and a code to hide.
  /// Likewise.
  final Marks? marks;
  final int? secret;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.brass,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<LocksteadApp> createState() => _LocksteadAppState();
}

class _LocksteadAppState extends State<LocksteadApp> {
  late int? _picking = widget.opensAt;

  /// Bumped whenever a lock should be set again rather than picked up where
  /// it was left.
  int _go = 0;

  void _open(int number) => setState(() {
        _picking = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final picking = _picking;

    return MaterialApp(
      title: 'Lockstead',
      debugShowCheckedModeBanner: false,
      theme: LocksteadApp.theme,
      home: picking == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : BoardScreen(
              key: ValueKey('$picking $_go'),
              number: picking,
              marks: widget.marks,
              secret: _go == 0 ? widget.secret : null,
              onOpened: (guesses) async =>
                  await widget.best
                      ?.record(Boards.at(picking).name, guesses) ??
                  false,
              onAgain: () => setState(() => _go++),
              onLeave: () => setState(() {
                _picking = null;
                _go++;
              }),
            ),
    );
  }
}
