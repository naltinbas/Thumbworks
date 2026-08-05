import 'package:flutter/material.dart';

import '../best.dart';
import '../link/parishes.dart';
import 'link_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of parishes, and one being joined up.
class TrodstowApp extends StatefulWidget {
  const TrodstowApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this parish. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.trod,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<TrodstowApp> createState() => _TrodstowAppState();
}

class _TrodstowAppState extends State<TrodstowApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a parish should start over rather than be picked up where
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
      title: 'Trodstow',
      debugShowCheckedModeBanner: false,
      theme: TrodstowApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : LinkScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (yards) async =>
                  await widget.best?.record(Rounds.at(playing).name, yards) ??
                  false,
              onNext: () => playing + 1 < Rounds.count
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
