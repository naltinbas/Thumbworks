import 'package:flutter/material.dart';

import '../best.dart';
import '../ring/watches.dart';
import 'palette.dart';
import 'ring_screen.dart';
import 'title_screen.dart';

/// The game: a marsh of watches, and one being set.
class RingmarshApp extends StatefulWidget {
  const RingmarshApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the marsh and open this watch. A test or a screenshot passes
  /// it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.marsh,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.lamp,
      brightness: Brightness.dark,
      surface: Palette.marsh,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<RingmarshApp> createState() => _RingmarshAppState();
}

class _RingmarshAppState extends State<RingmarshApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a watch should start over rather than be picked up
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
      title: 'Ringmarsh',
      debugShowCheckedModeBanner: false,
      theme: RingmarshApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : RingScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Watches.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Watches.count
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
