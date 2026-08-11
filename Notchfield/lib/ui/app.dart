import 'package:flutter/material.dart';

import '../best.dart';
import '../ruler/cuts.dart';
import 'palette.dart';
import 'ruler_screen.dart';
import 'title_screen.dart';

/// The game: a drawer of rulers, and one being cut.
class NotchfieldApp extends StatefulWidget {
  const NotchfieldApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the drawer and open this ruler. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.slate,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.notch,
      brightness: Brightness.dark,
      surface: Palette.slate,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<NotchfieldApp> createState() => _NotchfieldAppState();
}

class _NotchfieldAppState extends State<NotchfieldApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a ruler should start over rather than be picked
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
      title: 'Notchfield',
      debugShowCheckedModeBanner: false,
      theme: NotchfieldApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : RulerScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Cuts.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Cuts.count
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
