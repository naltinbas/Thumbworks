import 'package:flutter/material.dart';

import '../best.dart';
import '../hedge/hedges.dart';
import 'hedge_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a lane of hedges, and one being cut.
class WithyshawApp extends StatefulWidget {
  const WithyshawApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this hedge. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.lane,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.yours,
      brightness: Brightness.dark,
      surface: Palette.lane,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<WithyshawApp> createState() => _WithyshawAppState();
}

class _WithyshawAppState extends State<WithyshawApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a hedge should start over rather than be picked up
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
      title: 'Withyshaw',
      debugShowCheckedModeBanner: false,
      theme: WithyshawApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : HedgeScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Hedges.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Hedges.count
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
