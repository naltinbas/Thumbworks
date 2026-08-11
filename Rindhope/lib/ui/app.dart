import 'package:flutter/material.dart';

import '../best.dart';
import '../cheese/blocks.dart';
import 'cheese_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a shelf of blocks, and one being bitten.
class RindhopeApp extends StatefulWidget {
  const RindhopeApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the shelf and open this block. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.larder,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.cheese,
      brightness: Brightness.dark,
      surface: Palette.larder,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<RindhopeApp> createState() => _RindhopeAppState();
}

class _RindhopeAppState extends State<RindhopeApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a block should start over rather than be picked up
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
      title: 'Rindhope',
      debugShowCheckedModeBanner: false,
      theme: RindhopeApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : CheeseScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (bites) async =>
                  await widget.best
                      ?.record(Blocks.at(playing).name, bites) ??
                  false,
              onNext: () => playing + 1 < Blocks.count
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
