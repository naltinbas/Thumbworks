import 'package:flutter/material.dart';

import '../best.dart';
import '../fold/folds.dart';
import 'fold_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of folds, and one being watched.
class FoldburyApp extends StatefulWidget {
  const FoldburyApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this fold. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.shepherd,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<FoldburyApp> createState() => _FoldburyAppState();
}

class _FoldburyAppState extends State<FoldburyApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a night should start over rather than be picked up where
  /// it was left.
  int _go = 0;

  void _open(int number) => setState(() {
        _playing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final playing = _playing;

    return MaterialApp(
      title: 'Foldbury',
      debugShowCheckedModeBanner: false,
      theme: FoldburyApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : FoldScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (shepherds) async =>
                  await widget.best
                      ?.record(Folds.at(playing).name, shepherds) ??
                  false,
              onNext: () => playing + 1 < Folds.count
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
