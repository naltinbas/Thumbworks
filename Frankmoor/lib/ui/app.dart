import 'package:flutter/material.dart';

import '../best.dart';
import '../post/letters.dart';
import 'palette.dart';
import 'post_screen.dart';
import 'title_screen.dart';

/// The game: a rack of letters, and one at the counter.
class FrankmoorApp extends StatefulWidget {
  const FrankmoorApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the rack and open this letter. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.office,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.dear,
      brightness: Brightness.dark,
      surface: Palette.office,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<FrankmoorApp> createState() => _FrankmoorAppState();
}

class _FrankmoorAppState extends State<FrankmoorApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a letter should start over rather than be picked up
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
      title: 'Frankmoor',
      debugShowCheckedModeBanner: false,
      theme: FrankmoorApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : PostScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Letters.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Letters.count
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
