import 'package:flutter/material.dart';

import '../best.dart';
import '../hall/halls.dart';
import 'hall_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a keep of halls, and one being warded.
class WardhallApp extends StatefulWidget {
  const WardhallApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this hall. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.lit,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<WardhallApp> createState() => _WardhallAppState();
}

class _WardhallAppState extends State<WardhallApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a hall should start over rather than be picked
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
      title: 'Wardhall',
      debugShowCheckedModeBanner: false,
      theme: WardhallApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : HallScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Halls.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Halls.count
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
