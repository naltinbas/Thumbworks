import 'package:flutter/material.dart';

import '../best.dart';
import '../weave/meshes.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'weave_screen.dart';

/// The game: a shed of meshes, and one being woven.
class RiddlecombeApp extends StatefulWidget {
  const RiddlecombeApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the shed and open this mesh. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.shed,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.comb,
      brightness: Brightness.dark,
      surface: Palette.shed,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<RiddlecombeApp> createState() => _RiddlecombeAppState();
}

class _RiddlecombeAppState extends State<RiddlecombeApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a mesh should start over rather than be picked up
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
      title: 'Riddlecombe',
      debugShowCheckedModeBanner: false,
      theme: RiddlecombeApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : WeaveScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Meshes.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Meshes.count
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
