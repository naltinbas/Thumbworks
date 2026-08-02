import 'package:flutter/material.dart';

import '../music.dart';
import '../tune/tune.dart';
import 'palette.dart';
import 'play_screen.dart';
import 'title_screen.dart';

/// The game: a list of tunes, and one being played.
class ChimefallApp extends StatefulWidget {
  const ChimefallApp({
    super.key,
    this.opensWith,
    this.music,
    this.silent = false,
  });

  /// Skip the list and play this. A test or a screenshot passes it.
  final Tune? opensWith;
  final Music? music;

  /// Run without sound, off a plain clock. Only a test does this.
  final bool silent;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.perfect,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ChimefallApp> createState() => _ChimefallAppState();
}

class _ChimefallAppState extends State<ChimefallApp> {
  late Tune? _playing = widget.opensWith;

  /// Bumped by Again, so the same tune starts over rather than carrying on.
  int _go = 0;

  @override
  Widget build(BuildContext context) {
    final tune = _playing;
    return MaterialApp(
      title: 'Chimefall',
      debugShowCheckedModeBanner: false,
      theme: ChimefallApp.theme,
      home: tune == null
          ? TitleScreen(onPlay: (picked) => setState(() => _playing = picked))
          : PlayScreen(
              key: ValueKey('${tune.name} $_go'),
              tune: tune,
              music: widget.music,
              silent: widget.silent,
              onLeave: () => setState(() => _playing = null),
              onAgain: () => setState(() => _go++),
            ),
    );
  }
}
