import 'package:flutter/material.dart';

import '../best.dart';
import '../walk/towns.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'walk_screen.dart';

/// The game: a shelf of towns, and one being walked.
class BridgeholmApp extends StatefulWidget {
  const BridgeholmApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the shelf and open this town. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.water,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.plank,
      brightness: Brightness.dark,
      surface: Palette.water,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<BridgeholmApp> createState() => _BridgeholmAppState();
}

class _BridgeholmAppState extends State<BridgeholmApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a town should start over rather than be picked up
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
      title: 'Bridgeholm',
      debugShowCheckedModeBanner: false,
      theme: BridgeholmApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : WalkScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Towns.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Towns.count
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
