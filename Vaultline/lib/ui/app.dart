import 'package:flutter/material.dart';

import '../best.dart';
import '../sim/journey.dart';
import 'palette.dart';
import 'run_screen.dart';
import 'title_screen.dart';

/// The game: a title and a run.
class VaultlineApp extends StatefulWidget {
  const VaultlineApp({
    super.key,
    required this.best,
    this.opensRunning = false,
    this.seed = 1,
    this.opening,
  });

  final Best best;

  /// Skip the title and start a run, with this seed. A test or a screenshot
  /// passes these; a player arrives at the title.
  final bool opensRunning;
  final int seed;
  final Journey? opening;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.sky,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.good,
      brightness: Brightness.dark,
      surface: Palette.sky,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<VaultlineApp> createState() => _VaultlineAppState();
}

class _VaultlineAppState extends State<VaultlineApp> {
  late bool _running = widget.opensRunning;
  late int _seed = widget.seed;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Vaultline',
        debugShowCheckedModeBanner: false,
        theme: VaultlineApp.theme,
        home: _running
            ? RunScreen(
                key: ValueKey(_seed),
                seed: _seed,
                best: widget.best,
                opening: widget.opening,
                onLeave: () => setState(() => _running = false),
                onAgain: () => setState(() => _seed++),
              )
            : TitleScreen(
                best: widget.best,
                onPlay: () => setState(() => _running = true),
              ),
      );
}
