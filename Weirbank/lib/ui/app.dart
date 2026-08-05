import 'package:flutter/material.dart';

import '../best.dart';
import '../flow/works_list.dart';
import 'palette.dart';
import 'title_screen.dart';
import 'works_screen.dart';

/// The game: a list of works, and one being set.
class WeirbankApp extends StatefulWidget {
  const WeirbankApp({super.key, this.best, this.opensAt});

  final Best? best;

  /// Skip the list and open this works. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.water,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<WeirbankApp> createState() => _WeirbankAppState();
}

class _WeirbankAppState extends State<WeirbankApp> {
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
      title: 'Weirbank',
      debugShowCheckedModeBanner: false,
      theme: WeirbankApp.theme,
      home: playing == null
          ? TitleScreen(best: widget.best, onPlay: _open)
          : WorksScreen(
              key: ValueKey('$playing $_go'),
              number: playing,
              onDone: (turns) async =>
                  await widget.best
                      ?.record(Waterworks.at(playing).name, turns) ??
                  false,
              onNext: () => playing + 1 < Waterworks.count
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
