import 'package:flutter/material.dart';

import '../game/board.dart';
import '../opponent.dart';
import 'game_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a title with two choices on it, and a board.
///
/// One widget holds which of the two is showing rather than a stack of routes,
/// so Play again after Play again does not pile up fifty boards behind the one
/// being looked at.
class ThornguardApp extends StatefulWidget {
  const ThornguardApp({
    super.key,
    this.playing = Side.guards,
    this.strength = Strength.sharp,
    this.opensPlaying = false,
  });

  /// What the title starts with chosen. A test or a screenshot passes these;
  /// a player picks them.
  final Side playing;
  final Strength strength;

  /// Skip the title and start a game. Only a screenshot does this.
  final bool opensPlaying;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.good,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<ThornguardApp> createState() => _ThornguardAppState();
}

class _ThornguardAppState extends State<ThornguardApp> {
  late Side _playing = widget.playing;
  late Strength _strength = widget.strength;
  late bool _atBoard = widget.opensPlaying;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thornguard',
      debugShowCheckedModeBanner: false,
      theme: ThornguardApp.theme,
      home: _atBoard
          ? GameScreen(
              // Keyed on the choices, so picking a different side or a
              // different opponent and playing again starts a game rather
              // than carrying on with the old one under new management.
              key: ValueKey('$_playing $_strength'),
              playing: _playing,
              strength: _strength,
              onLeave: () => setState(() => _atBoard = false),
            )
          : TitleScreen(
              playing: _playing,
              strength: _strength,
              onSide: (side) => setState(() => _playing = side),
              onStrength: (how) => setState(() => _strength = how),
              onPlay: () => setState(() => _atBoard = true),
            ),
    );
  }
}
