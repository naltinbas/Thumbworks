import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../best.dart';
import '../game/odds.dart';
import '../game/play.dart';
import 'palette.dart';
import 'table_screen.dart';
import 'title_screen.dart';

/// The game: a table, and whoever is sitting at it.
class HazardwellApp extends StatefulWidget {
  const HazardwellApp({
    super.key,
    this.best,
    this.odds,
    this.opensAtTable = false,
    this.dice,
    this.opensWith,
    this.showOdds = false,
    this.theirPause = const Duration(milliseconds: 850),
  });

  final Best? best;

  /// The table of odds, if somebody has one already. A test hands one in
  /// rather than waiting a second for it to be worked out again.
  final Odds? odds;

  /// Skip the way in and sit down. A test or a screenshot passes this.
  final bool opensAtTable;

  final Random? dice;
  final Play? opensWith;
  final bool showOdds;
  final Duration theirPause;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.yours,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<HazardwellApp> createState() => _HazardwellAppState();
}

class _HazardwellAppState extends State<HazardwellApp> {
  Odds? _odds;
  late bool _sitting = widget.opensAtTable;

  /// Bumped whenever a table should be dealt again rather than picked up
  /// where it was left.
  int _game = 0;

  @override
  void initState() {
    super.initState();
    _odds = widget.odds;
    if (_odds == null) _reckon();
  }

  /// Works the table of odds out somewhere else.
  ///
  /// It is a second of arithmetic and the phone should not be holding still
  /// through it, so it happens on an isolate of its own while the way in is
  /// on screen. By the time anybody has read the rules it is done.
  Future<void> _reckon() async {
    final parts = await compute(reckonParts, null);
    if (!mounted) return;
    setState(() => _odds = Odds.fromParts(parts));
  }

  @override
  Widget build(BuildContext context) {
    final odds = _odds;

    return MaterialApp(
      title: 'Hazardwell',
      debugShowCheckedModeBanner: false,
      theme: HazardwellApp.theme,
      home: !_sitting || odds == null
          ? TitleScreen(
              best: widget.best,
              odds: odds,
              onPlay: () => setState(() => _sitting = true),
            )
          : TableScreen(
              key: ValueKey(_game),
              odds: odds,
              dice: widget.dice,
              opensWith: _game == 0 ? widget.opensWith : null,
              showOdds: widget.showOdds,
              theirPause: widget.theirPause,
              onOver: ({required bool win, required double sharpness}) async =>
                  await widget.best?.record(win: win, sharpness: sharpness) ??
                  false,
              onAgain: () => setState(() => _game++),
              // Leaving deals again as well. Coming back to a game somebody
              // walked out of halfway through is not what walking out means.
              onLeave: () => setState(() {
                _sitting = false;
                _game++;
              }),
            ),
    );
  }
}
