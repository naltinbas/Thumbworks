import 'package:flutter/material.dart';

import '../assay/boxes.dart';
import '../best.dart';
import 'assay_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of boxes, and one being assayed.
class PyxholmApp extends StatefulWidget {
  const PyxholmApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this box. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.beam,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<PyxholmApp> createState() => _PyxholmAppState();
}

class _PyxholmAppState extends State<PyxholmApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a box should start over rather than be picked up where it
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
      title: 'Pyxholm',
      debugShowCheckedModeBanner: false,
      theme: PyxholmApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : AssayScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (weighings) async =>
                  await widget.best
                      ?.record(Boxes.at(playing).name, weighings) ??
                  false,
              onNext: () => playing + 1 < Boxes.count
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
