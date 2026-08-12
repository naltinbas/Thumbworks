import 'package:flutter/material.dart';

import '../best.dart';
import '../ford/reaches.dart';
import 'ford_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a stream of reaches, and one being waded.
class FarthingfordApp extends StatefulWidget {
  const FarthingfordApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this reach. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.stone,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<FarthingfordApp> createState() => _FarthingfordAppState();
}

class _FarthingfordAppState extends State<FarthingfordApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a reach should start over rather than be picked
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
      title: 'Farthingford',
      debugShowCheckedModeBanner: false,
      theme: FarthingfordApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : FordScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (wades) async =>
                  await widget.best
                      ?.record(Reaches.at(playing).name, wades) ??
                  false,
              onNext: () => playing + 1 < Reaches.count
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
