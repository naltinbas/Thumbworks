import 'package:flutter/material.dart';

import '../best.dart';
import '../web/webs.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'web_screen.dart';

/// The game: a mere of webs, and one being woven.
class TanglemereApp extends StatefulWidget {
  const TanglemereApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this web. A test or a screenshot passes
  /// it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.mineThread,
      brightness: Brightness.dark,
      surface: Palette.dark,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<TanglemereApp> createState() => _TanglemereAppState();
}

class _TanglemereAppState extends State<TanglemereApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a web should start over rather than be picked
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
      title: 'Tanglemere',
      debugShowCheckedModeBanner: false,
      theme: TanglemereApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : WebScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Webs.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Webs.count
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
