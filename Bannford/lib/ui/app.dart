import 'package:flutter/material.dart';

import '../banns/parties.dart';
import '../best.dart';
import 'banns_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a hall of parties, and one being wed.
class BannfordApp extends StatefulWidget {
  const BannfordApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the hall and open this party. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.hall,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.face,
      brightness: Brightness.dark,
      surface: Palette.hall,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<BannfordApp> createState() => _BannfordAppState();
}

class _BannfordAppState extends State<BannfordApp> {
  late int? _playing = widget.opensAt;

  /// Bumped whenever a party should start over rather than be picked up
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
      title: 'Bannford',
      debugShowCheckedModeBanner: false,
      theme: BannfordApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : BannsScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (askings) async =>
                  await widget.best
                      ?.record(Parties.at(playing).name, askings) ??
                  false,
              onNext: () => playing + 1 < Parties.count
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
