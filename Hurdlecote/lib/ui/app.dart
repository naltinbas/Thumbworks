import 'package:flutter/material.dart';

import '../best.dart';
import '../fold/greens.dart';
import 'fold_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a cote of greens, and one being fenced.
class HurdlecoteApp extends StatefulWidget {
  const HurdlecoteApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this green. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.first,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<HurdlecoteApp> createState() => _HurdlecoteAppState();
}

class _HurdlecoteAppState extends State<HurdlecoteApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a green should start over rather than be picked
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
      title: 'Hurdlecote',
      debugShowCheckedModeBanner: false,
      theme: HurdlecoteApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : FoldScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (hurdles) async =>
                  await widget.best
                      ?.record(Greens.at(playing).name, hurdles) ??
                  false,
              onNext: () => playing + 1 < Greens.count
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
