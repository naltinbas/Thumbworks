import 'package:flutter/material.dart';

import '../best.dart';
import '../code/riddles.dart';
import 'code_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a bourne of riddles, and one being answered.
class PegbourneApp extends StatefulWidget {
  const PegbourneApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this riddle. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.table,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.pegColours[3],
      brightness: Brightness.dark,
      surface: Palette.table,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<PegbourneApp> createState() => _PegbourneAppState();
}

class _PegbourneAppState extends State<PegbourneApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a riddle should start over rather than be picked
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
      title: 'Pegbourne',
      debugShowCheckedModeBanner: false,
      theme: PegbourneApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : CodeScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Riddles.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Riddles.count
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
