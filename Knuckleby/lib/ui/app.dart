import 'package:flutter/material.dart';

import '../best.dart';
import '../bones/benches.dart';
import 'bones_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a tavern of benches, and one being cut.
class KnucklebyApp extends StatefulWidget {
  const KnucklebyApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this bench. A test or a screenshot
  /// passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.bone,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<KnucklebyApp> createState() => _KnucklebyAppState();
}

class _KnucklebyAppState extends State<KnucklebyApp> {
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
      title: 'Knuckleby',
      debugShowCheckedModeBanner: false,
      theme: KnucklebyApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : BonesScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (cuts) async =>
                  await widget.best
                      ?.record(Benches.at(playing).name, cuts) ??
                  false,
              onNext: () => playing + 1 < Benches.count
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
