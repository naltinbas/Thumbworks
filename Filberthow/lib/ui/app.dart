import 'package:flutter/material.dart';

import '../best.dart';
import '../hoard/hoards.dart';
import 'hoard_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a wood of hoards, and one being taken.
class FilberthowApp extends StatefulWidget {
  const FilberthowApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this hoard. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.wood,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.shell,
      brightness: Brightness.dark,
      surface: Palette.wood,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<FilberthowApp> createState() => _FilberthowAppState();
}

class _FilberthowAppState extends State<FilberthowApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a hoard should start over rather than be picked up
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
      title: 'Filberthow',
      debugShowCheckedModeBanner: false,
      theme: FilberthowApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : HoardScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Hoards.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Hoards.count
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
