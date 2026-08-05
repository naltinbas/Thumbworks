import 'package:flutter/material.dart';

import '../best.dart';
import '../watch/countries.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'watch_screen.dart';

/// The game: a list of works, and one being set.
class BeaconholtApp extends StatefulWidget {
  const BeaconholtApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this works. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.lit,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<BeaconholtApp> createState() => _BeaconholtAppState();
}

class _BeaconholtAppState extends State<BeaconholtApp> {
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
      title: 'Beaconholt',
      debugShowCheckedModeBanner: false,
      theme: BeaconholtApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : WatchScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (beacons) async =>
                  await widget.best
                      ?.record(Watchlands.at(playing).name, beacons) ??
                  false,
              onNext: () => playing + 1 < Watchlands.count
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
