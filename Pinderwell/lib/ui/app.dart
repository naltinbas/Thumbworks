import 'package:flutter/material.dart';

import '../best.dart';
import '../drive/fields.dart';
import 'drive_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of fields, and one being driven.
class PinderwellApp extends StatefulWidget {
  const PinderwellApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this field. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.moor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.rung,
      brightness: Brightness.dark,
      surface: Palette.moor,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<PinderwellApp> createState() => _PinderwellAppState();
}

class _PinderwellAppState extends State<PinderwellApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a drive should start over rather than be picked up
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
      title: 'Pinderwell',
      debugShowCheckedModeBanner: false,
      theme: PinderwellApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : DriveScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (pushes) async =>
                  await widget.best
                      ?.record(Fields.at(playing).name, pushes) ??
                  false,
              onNext: () => playing + 1 < Fields.count
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
