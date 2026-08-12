import 'package:flutter/material.dart';

import '../best.dart';
import '../show/shows.dart';
import 'palette.dart';
import 'show_screen.dart';
import 'title_screen.dart';

/// The game: a den of benches, and one being judged.
class MarrowdenApp extends StatefulWidget {
  const MarrowdenApp({super.key, this.best, this.opensAt, this.dealsFor});

  final Best? best;

  /// Skip the list and open this bench. A test or a screenshot
  /// passes it.
  final int? opensAt;

  /// Written-out sittings per bench, for tests; left null, each
  /// bench shuffles its own.
  final List<List<int>>? Function(int number)? dealsFor;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.rosette,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<MarrowdenApp> createState() => _MarrowdenAppState();
}

class _MarrowdenAppState extends State<MarrowdenApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a bench should start over rather than be picked
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
      title: 'Marrowden',
      debugShowCheckedModeBanner: false,
      theme: MarrowdenApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : ShowScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              deals: widget.dealsFor?.call(playing),
              onDone: (sittings) async =>
                  await widget.best
                      ?.record(Shows.at(playing).name, sittings) ??
                  false,
              onNext: () => playing + 1 < Shows.count
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
