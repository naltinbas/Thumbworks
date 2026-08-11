import 'package:flutter/material.dart';

import '../best.dart';
import '../charm/charms.dart';
import 'charm_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a hearth of charms, and one being set.
class CharmsteadApp extends StatefulWidget {
  const CharmsteadApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the hearth and open this charm. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.hearth,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.coin,
      brightness: Brightness.dark,
      surface: Palette.hearth,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<CharmsteadApp> createState() => _CharmsteadAppState();
}

class _CharmsteadAppState extends State<CharmsteadApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a charm should start over rather than be picked
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
      title: 'Charmstead',
      debugShowCheckedModeBanner: false,
      theme: CharmsteadApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : CharmScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Charms.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Charms.count
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
