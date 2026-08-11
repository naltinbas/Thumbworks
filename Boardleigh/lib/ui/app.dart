import 'package:flutter/material.dart';

import '../best.dart';
import '../floor/rooms.dart';
import 'floor_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a house of rooms, and one being floored.
class BoardleighApp extends StatefulWidget {
  const BoardleighApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the house and open this room. A test or a screenshot passes
  /// it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.house,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.plank,
      brightness: Brightness.dark,
      surface: Palette.house,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<BoardleighApp> createState() => _BoardleighAppState();
}

class _BoardleighAppState extends State<BoardleighApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a room should start over rather than be picked
  /// up where it was left.
  int _go = 0;

  void _open(int number) => setState(() {
        _playing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final playing = _playing;

    return MaterialApp(
      title: 'Boardleigh',
      debugShowCheckedModeBanner: false,
      theme: BoardleighApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : FloorScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Rooms.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Rooms.count
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
