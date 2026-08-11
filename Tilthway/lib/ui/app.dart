import 'package:flutter/material.dart';

import '../best.dart';
import '../tilth/tilths.dart';
import 'palette.dart';
import 'tilth_screen.dart';
import 'title_screen.dart';

/// The game: a field of tilths, and one being sown.
class TilthwayApp extends StatefulWidget {
  const TilthwayApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the field and open this tilth. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.field,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.seed,
      brightness: Brightness.dark,
      surface: Palette.field,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<TilthwayApp> createState() => _TilthwayAppState();
}

class _TilthwayAppState extends State<TilthwayApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a tilth should start over rather than be picked up
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
      title: 'Tilthway',
      debugShowCheckedModeBanner: false,
      theme: TilthwayApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : TilthScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Tilths.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Tilths.count
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
