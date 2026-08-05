import 'package:flutter/material.dart';

import '../best.dart';
import '../churn/dairies.dart';
import 'churn_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of mornings, and one being measured out.
class ChurnwickApp extends StatefulWidget {
  const ChurnwickApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this morning. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.milk,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ChurnwickApp> createState() => _ChurnwickAppState();
}

class _ChurnwickAppState extends State<ChurnwickApp> {
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
      title: 'Churnwick',
      debugShowCheckedModeBanner: false,
      theme: ChurnwickApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : ChurnScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (goes) async =>
                  await widget.best?.record(Mornings.at(playing).name, goes) ??
                  false,
              onNext: () => playing + 1 < Mornings.count
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
