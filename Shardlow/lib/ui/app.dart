import 'package:flutter/material.dart';

import '../best.dart';
import '../drop/ladders.dart';
import 'drop_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: the yard, and one ladder being worked.
class ShardlowApp extends StatefulWidget {
  const ShardlowApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the yard and open this ladder. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.pot,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ShardlowApp> createState() => _ShardlowAppState();
}

class _ShardlowAppState extends State<ShardlowApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a morning should start over rather than be picked up
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
      title: 'Shardlow',
      debugShowCheckedModeBanner: false,
      theme: ShardlowApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : DropScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (drops) async =>
                  await widget.best?.record(Ladders.at(playing).name, drops) ??
                  false,
              onNext: () => playing + 1 < Ladders.count
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
