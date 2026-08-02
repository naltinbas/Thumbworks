import 'package:flutter/material.dart' hide Table;

import '../game/book.dart';
import '../game/game.dart';
import 'game_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a title and a deal.
class FanwrightApp extends StatefulWidget {
  const FanwrightApp({
    super.key,
    this.place = 0,
    this.opensPlaying = false,
    this.opening,
  });

  /// Where in the book to start. A test or a screenshot passes these; a
  /// player arrives at the first deal.
  final int place;
  final bool opensPlaying;
  final Game? opening;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.felt,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.good,
      brightness: Brightness.dark,
      surface: Palette.felt,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<FanwrightApp> createState() => _FanwrightAppState();
}

class _FanwrightAppState extends State<FanwrightApp> {
  late int _place = widget.place;
  late bool _playing = widget.opensPlaying;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Fanwright',
        debugShowCheckedModeBanner: false,
        theme: FanwrightApp.theme,
        home: _playing
            ? GameScreen(
                key: ValueKey(_place),
                number: Book.at(_place),
                opening: widget.opening,
                onLeave: () => setState(() => _playing = false),
                onNext: () => setState(() => _place++),
              )
            : TitleScreen(
                place: _place,
                onPlay: () => setState(() => _playing = true),
                onPick: (place) => setState(() => _place = place),
              ),
      );
}
