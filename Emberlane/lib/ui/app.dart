import 'package:flutter/material.dart';

import '../sim/run.dart';
import 'palette.dart';
import 'run_screen.dart';
import 'title_screen.dart';

/// The game: a title and a run.
///
/// One widget holds which is showing rather than a stack of routes, so Another
/// run after Another run does not pile up behind the one being played.
class EmberlaneApp extends StatefulWidget {
  const EmberlaneApp({super.key, this.opening, this.opensPlaying = false});

  /// A run to start at, and whether to skip the title. Only a test or a
  /// screenshot passes either.
  final Run? opening;
  final bool opensPlaying;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.ember,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<EmberlaneApp> createState() => _EmberlaneAppState();
}

class _EmberlaneAppState extends State<EmberlaneApp> {
  late bool _playing = widget.opensPlaying;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Emberlane',
        debugShowCheckedModeBanner: false,
        theme: EmberlaneApp.theme,
        home: _playing
            ? RunScreen(
                opening: widget.opening,
                onLeave: () => setState(() => _playing = false),
              )
            : TitleScreen(onPlay: () => setState(() => _playing = true)),
      );
}
