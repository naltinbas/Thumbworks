import 'package:flutter/material.dart';

import '../best.dart';
import '../row/levels.dart';
import 'palette.dart';
import 'row_screen.dart';
import 'title_screen.dart';

/// The game: a stack of shelves, and one being set.
class SpanhamApp extends StatefulWidget {
  const SpanhamApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this shelf. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.floor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.blocks[3],
      brightness: Brightness.dark,
      surface: Palette.floor,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<SpanhamApp> createState() => _SpanhamAppState();
}

class _SpanhamAppState extends State<SpanhamApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a shelf should start over rather than be picked up
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
      title: 'Spanham',
      debugShowCheckedModeBanner: false,
      theme: SpanhamApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : RowScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Levels.at(playing).name, askings) ??
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
