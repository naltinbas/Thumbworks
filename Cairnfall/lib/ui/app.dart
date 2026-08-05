import 'package:flutter/material.dart';

import '../best.dart';
import '../stones/rounds.dart';
import '../stones/worth.dart';
import 'palette.dart';
import 'round_screen.dart';
import 'title_screen.dart';

/// The game: a list of rounds, and one being played.
class CairnfallApp extends StatefulWidget {
  const CairnfallApp({
    super.key,
    this.best,
    this.opensAt,
    this.showWorth = false,
    this.theirPause = const Duration(milliseconds: 750),
  });

  final Best? best;

  /// Skip the list and open this round. A test or a screenshot passes it.
  final int? opensAt;

  final bool showWorth;
  final Duration theirPause;

  /// What every cairn is worth, up to the largest one there is.
  ///
  /// Worked out here and once. It is a few hundred numbers, filled in from
  /// nothing upwards, and it is the whole of what the other player knows.
  static final worth = Worth.upTo(80);

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.going,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<CairnfallApp> createState() => _CairnfallAppState();
}

class _CairnfallAppState extends State<CairnfallApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a round should be set up again rather than picked up
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
      title: 'Cairnfall',
      debugShowCheckedModeBanner: false,
      theme: CairnfallApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : RoundScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              worth: CairnfallApp.worth,
              showWorth: widget.showWorth,
              theirPause: widget.theirPause,
              onOver: ({required bool win, required int wrong}) async =>
                  await widget.best?.record(
                    Rounds.at(playing).name,
                    win: win,
                    wrong: wrong,
                  ) ??
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
