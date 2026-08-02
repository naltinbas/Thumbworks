import 'package:flutter/material.dart';

import '../best.dart';
import '../yard/levels.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'yard_screen.dart';

/// The game: a list of yards, and one being worked.
class HaulyardApp extends StatefulWidget {
  const HaulyardApp({super.key, this.best, this.opensAt});

  /// The records. Null in a test that does not care.
  final Best? best;

  /// Skip the list and open this yard. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.mark,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<HaulyardApp> createState() => _HaulyardAppState();
}

class _HaulyardAppState extends State<HaulyardApp> {
  late int? _working = widget.opensAt;

  /// Bumped when a yard is opened again, so it starts over rather than
  /// keeping the position that has just been finished.
  int _go = 0;

  void _open(int number) => setState(() {
        _working = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final working = _working;

    return MaterialApp(
      title: 'Haulyard',
      debugShowCheckedModeBanner: false,
      theme: HaulyardApp.theme,
      home: working == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : YardScreen(
              key: ValueKey('$working $_go'),
              number: working,
              onDone: (shoves) async =>
                  await widget.best?.record(Levels.at(working).name, shoves) ??
                  false,
              onLeave: () => setState(() => _working = null),
              // Past the last one there is nowhere to go but back to the list.
              onNext: () => working + 1 < Levels.count
                  ? _open(working + 1)
                  : setState(() => _working = null),
            ),
    );
  }
}
