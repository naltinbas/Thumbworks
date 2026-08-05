import 'package:flutter/material.dart';

import '../best.dart';
import '../raise/frames.dart';
import 'palette.dart';
import 'raise_screen.dart';
import 'title_screen.dart';

/// The game: a list of frames, and one being raised.
class TrestlewickApp extends StatefulWidget {
  const TrestlewickApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this frame. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.chosen,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<TrestlewickApp> createState() => _TrestlewickAppState();
}

class _TrestlewickAppState extends State<TrestlewickApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a frame should start over rather than be picked up where
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
      title: 'Trestlewick',
      debugShowCheckedModeBanner: false,
      theme: TrestlewickApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : RaiseScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (days) async =>
                  await widget.best?.record(Frames.at(playing).name, days) ??
                  false,
              onNext: () => playing + 1 < Frames.count
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
