import 'package:flutter/material.dart';

import '../best.dart';
import '../hold/consignments.dart';
import 'hold_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a yard of consignments, and one being stacked.
class FairholdApp extends StatefulWidget {
  const FairholdApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the yard and open this consignment. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.yard,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.paints[2],
      brightness: Brightness.dark,
      surface: Palette.yard,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<FairholdApp> createState() => _FairholdAppState();
}

class _FairholdAppState extends State<FairholdApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a consignment should start over rather than be
  /// picked up where it was left.
  int _go = 0;

  void _open(int number) => setState(() {
        _playing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final playing = _playing;

    return MaterialApp(
      title: 'Fairhold',
      debugShowCheckedModeBanner: false,
      theme: FairholdApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : HoldScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Consignments.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Consignments.count
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
