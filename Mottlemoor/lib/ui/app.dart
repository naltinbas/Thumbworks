import 'package:flutter/material.dart';

import '../best.dart';
import '../herd/moors.dart';
import 'herd_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a moorland of herds, and one being settled.
class MottlemoorApp extends StatefulWidget {
  const MottlemoorApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this moor. A test or a screenshot passes
  /// it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.dusk,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.olive,
      brightness: Brightness.dark,
      surface: Palette.dusk,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<MottlemoorApp> createState() => _MottlemoorAppState();
}

class _MottlemoorAppState extends State<MottlemoorApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a moor should start over rather than be picked
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
      title: 'Mottlemoor',
      debugShowCheckedModeBanner: false,
      theme: MottlemoorApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : HerdScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (meetings) async =>
                  await widget.best
                      ?.record(Moors.at(playing).name, meetings) ??
                  false,
              onNext: () => playing + 1 < Moors.count
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
