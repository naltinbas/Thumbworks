import 'package:flutter/material.dart';

import '../best.dart';
import '../round/rounds_list.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'round_screen.dart';

/// The game: a list of works, and one being set.
class CarterfenApp extends StatefulWidget {
  const CarterfenApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this works. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.road,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<CarterfenApp> createState() => _CarterfenAppState();
}

class _CarterfenAppState extends State<CarterfenApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a works should be emptied rather than picked up where it
  /// was left.
  int _go = 0;

  void _open(int number) => setState(() {
        _playing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final playing = _playing;

    return MaterialApp(
      title: 'Carterfen',
      debugShowCheckedModeBanner: false,
      theme: CarterfenApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : RoundScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (furlongs) async =>
                  await widget.best
                      ?.record(Rounds.at(playing).name, furlongs) ??
                  false,
              onNext: () => playing + 1 < Rounds.count
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
