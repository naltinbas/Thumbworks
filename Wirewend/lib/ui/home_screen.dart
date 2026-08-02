import 'package:flutter/material.dart';

import '../game/grid.dart';
import '../game/progress.dart';
import 'board_view.dart';
import 'game_screen.dart';
import 'palette.dart';

/// The menu, which is one decision: carry on, or start the first level again.
///
/// There is no level list. Levels are numbered and every one is built from
/// its number, so the only level worth offering is the one the player has
/// reached.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.progress});

  final Progress progress;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _play(int level) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            GameScreen(level: level, progress: widget.progress),
      ),
    );
    // The player may have gone several levels further while they were in
    // there, so the button has to be rebuilt from what was saved.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final reached = widget.progress.reached;

    return Scaffold(
      backgroundColor: Palette.backdrop,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Emblem(),
                  const SizedBox(height: 40),
                  const Text(
                    'Wirewend',
                    style: TextStyle(
                      color: Palette.ink,
                      fontSize: 38,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Turn the wire until every lamp is lit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Palette.inkDim, fontSize: 15),
                  ),
                  const SizedBox(height: 44),
                  FilledButton(
                    onPressed: () => _play(reached),
                    child: Text(
                      reached == 1 ? 'Start' : 'Continue level $reached',
                    ),
                  ),
                  if (reached > 1)
                    TextButton(
                      onPressed: () => _play(1),
                      child: const Text('Play level 1 again'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tiny solved board as the logo.
///
/// The game has no art, so the mark is the game: a source with four lamps
/// around it, wired up and lit, drawn by the same painter that draws a level.
class _Emblem extends StatelessWidget {
  const _Emblem();

  static Board _lit() => Board(
        rows: 3,
        cols: 3,
        cells: [
          Cell(kind: CellKind.empty, ends: Ends.none),
          Cell(kind: CellKind.lamp, ends: Ends.south),
          Cell(kind: CellKind.empty, ends: Ends.none),
          Cell(kind: CellKind.lamp, ends: Ends.east),
          Cell(
            kind: CellKind.source,
            ends: Ends.north | Ends.east | Ends.south | Ends.west,
          ),
          Cell(kind: CellKind.lamp, ends: Ends.west),
          Cell(kind: CellKind.empty, ends: Ends.none),
          Cell(kind: CellKind.lamp, ends: Ends.north),
          Cell(kind: CellKind.empty, ends: Ends.none),
        ],
      );

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 190,
        height: 190,
        // No tap handler, so the emblem is a picture and not a puzzle nobody
        // asked to play.
        child: BoardView(board: _lit()),
      );
}
