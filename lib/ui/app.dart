import 'package:flutter/material.dart';

import '../done.dart';
import '../sim/levels.dart';
import '../sim/stroke.dart';
import 'board_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of levels, and one being drawn on.
class ChalkwayApp extends StatefulWidget {
  const ChalkwayApp({super.key, this.done, this.opensAt, this.opening});

  /// What has been solved. Null in a test that does not care.
  final Done? done;

  /// Skip the list and open this level. A test or a screenshot passes it.
  final int? opensAt;

  /// A drawing to open that level with. Likewise.
  final Drawing? opening;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.slateDeep,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.ring,
      brightness: Brightness.dark,
      surface: Palette.slateDeep,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ChalkwayApp> createState() => _ChalkwayAppState();
}

class _ChalkwayAppState extends State<ChalkwayApp> {
  late int? _playing = widget.opensAt;

  /// Bumped when a level is opened again, so the board starts empty rather
  /// than keeping the drawing that has just failed.
  int _go = 0;

  void _open(int number) => setState(() {
        _playing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final playing = _playing;

    return MaterialApp(
      title: 'Chalkway',
      debugShowCheckedModeBanner: false,
      theme: ChalkwayApp.theme,
      home: playing == null
          ? TitleScreen(done: widget.done, onPlay: _open)
          : BoardScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              opening: _go == 0 ? widget.opening : null,
              onSolved: (chalk) =>
                  widget.done?.record(Levels.at(playing).name, chalk),
              onLeave: () => setState(() => _playing = null),
              // Past the last one there is nowhere to go but back to the list.
              onNext: () => playing + 1 < Levels.count
                  ? _open(playing + 1)
                  : setState(() => _playing = null),
            ),
    );
  }
}
