import 'package:flutter/material.dart';

import '../best.dart';
import '../ring/rings.dart';
import 'dip_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of rings, and one being dipped.
class DipthorneApp extends StatefulWidget {
  const DipthorneApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this ring. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.dusk,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.you,
      brightness: Brightness.dark,
      surface: Palette.dusk,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<DipthorneApp> createState() => _DipthorneAppState();
}

class _DipthorneAppState extends State<DipthorneApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a dip should start over rather than be picked up
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
      title: 'Dipthorne',
      debugShowCheckedModeBanner: false,
      theme: DipthorneApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : DipScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Rings.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Rings.count
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
