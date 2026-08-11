import 'package:flutter/material.dart';

import '../best.dart';
import '../quay/berths.dart';
import '../quay/stow.dart';
import 'palette.dart';
import 'quay_screen.dart';
import 'title_screen.dart';

/// The game: a row of berths, and one being sailed.
class LockhitheApp extends StatefulWidget {
  const LockhitheApp({super.key, this.best, this.opensAt, this.dealt});

  final Best? best;

  /// Skip the list and open this berth. A test or a screenshot passes it.
  final int? opensAt;

  /// A stowing to deal instead of shuffling, for tests and screenshots.
  final Stow? dealt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.quay,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.you,
      brightness: Brightness.dark,
      surface: Palette.quay,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<LockhitheApp> createState() => _LockhitheAppState();
}

class _LockhitheAppState extends State<LockhitheApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a round should be dealt fresh rather than picked up
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
      title: 'Lockhithe',
      debugShowCheckedModeBanner: false,
      theme: LockhitheApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : QuayScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              dealt: widget.dealt,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Berths.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Berths.count
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
