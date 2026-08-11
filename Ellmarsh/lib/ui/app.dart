import 'package:flutter/material.dart';

import '../best.dart';
import '../cloth/benches.dart';
import 'cloth_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a shop of benches, and one being cut.
class EllmarshApp extends StatefulWidget {
  const EllmarshApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this bench. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.shop,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.golden,
      brightness: Brightness.dark,
      surface: Palette.shop,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<EllmarshApp> createState() => _EllmarshAppState();
}

class _EllmarshAppState extends State<EllmarshApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a bench should start over rather than be picked up
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
      title: 'Ellmarsh',
      debugShowCheckedModeBanner: false,
      theme: EllmarshApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : ClothScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Benches.at(playing).name, askings) ??
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
