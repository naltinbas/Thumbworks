import 'package:flutter/material.dart';

import '../best.dart';
import '../tour/yards.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'tour_screen.dart';

/// The game: a list of yards, and one being ridden.
class ColthorpeApp extends StatefulWidget {
  const ColthorpeApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this yard. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.beyond,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.colt,
      brightness: Brightness.dark,
      surface: Palette.beyond,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ColthorpeApp> createState() => _ColthorpeAppState();
}

class _ColthorpeAppState extends State<ColthorpeApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a round should start over rather than be picked up
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
      title: 'Colthorpe',
      debugShowCheckedModeBanner: false,
      theme: ColthorpeApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : TourScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Yards.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Yards.count
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
