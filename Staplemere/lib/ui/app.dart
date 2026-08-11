import 'package:flutter/material.dart';

import '../best.dart';
import '../yard/deals.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'yard_screen.dart';

/// The game: a list of mornings, and one being played.
class StaplemereApp extends StatefulWidget {
  const StaplemereApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this deal. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.yard,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.thread,
      brightness: Brightness.dark,
      surface: Palette.yard,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<StaplemereApp> createState() => _StaplemereAppState();
}

class _StaplemereAppState extends State<StaplemereApp> {
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
      title: 'Staplemere',
      debugShowCheckedModeBanner: false,
      theme: StaplemereApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : YardScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (piles) async =>
                  await widget.best
                      ?.record(Deals.at(playing).name, piles) ??
                  false,
              onNext: () => playing + 1 < Deals.count
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
