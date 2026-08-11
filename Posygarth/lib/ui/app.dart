import 'package:flutter/material.dart';

import '../best.dart';
import '../garden/garths.dart';
import 'garth_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a walled garden of garths, and one being planted.
class PosygarthApp extends StatefulWidget {
  const PosygarthApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this garth. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.dusk,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.posies[3],
      brightness: Brightness.dark,
      surface: Palette.dusk,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<PosygarthApp> createState() => _PosygarthAppState();
}

class _PosygarthAppState extends State<PosygarthApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a garth should start over rather than be picked up
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
      title: 'Posygarth',
      debugShowCheckedModeBanner: false,
      theme: PosygarthApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : GarthScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Garths.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Garths.count
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
