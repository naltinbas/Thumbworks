import 'package:flutter/material.dart';

import '../best_score.dart';
import '../game/board.dart';
import '../game/lexicon.dart';
import 'board_painter.dart';
import 'chrome.dart';
import 'palette.dart';
import 'tracer.dart';

/// The screen the game opens on.
///
/// There is one decision here and it is Play, so everything else on the
/// screen is the game explaining itself: a word already traced, in the
/// colours the real board uses, so a player who has never seen it knows what
/// they are about to do with their thumb.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final BestScore best;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, space) => SingleChildScrollView(
          // Anchored at the bottom and scrolling upwards. At the largest
          // system text setting the words here are taller than a small phone,
          // and the one thing on this screen that has to be reachable is the
          // button at the end of them. With room to spare the column fills
          // the screen instead and looks centred.
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: space.maxHeight - 56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Emblem(),
                const SizedBox(height: 34),
                // The name is a mark rather than something to read, so it
                // shrinks to the width it has instead of wrapping onto three
                // lines at a large text setting.
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Latchword',
                    maxLines: 1,
                    style: TextStyle(
                      color: Palette.ink,
                      fontSize: 40,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Drag across touching letters, diagonals and all.\n'
                  'Long words are worth far more.',
                  textAlign: TextAlign.center,
                  style: noteStyle,
                ),
                const SizedBox(height: 30),
                Text(
                  bestLine(best.points, best.seed),
                  textAlign: TextAlign.center,
                  style: best.hasRound
                      ? labelStyle.copyWith(color: Palette.stale)
                      : labelStyle,
                ),
                const SizedBox(height: 34),
                FilledButton(onPressed: onPlay, child: const Text('Play')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small board with a word traced across it, as the mark for the game.
///
/// There is no art to load, so the logo is the game: the same painter, the
/// same colours, and a trace sitting in the green that means the word counts.
class _Emblem extends StatelessWidget {
  const _Emblem();

  static final Board _board = Board(
    size: 3,
    letters: 'latwchord'.split(''),
    lexicon: Lexicon.of(const ['latch']),
  );

  static const _latch = [
    Spot(0, 0),
    Spot(0, 1),
    Spot(0, 2),
    Spot(1, 1),
    Spot(1, 2),
  ];

  /// A trace that is finished and going nowhere. It is a still picture, so
  /// nothing here ever changes value.
  static final ValueNotifier<Trace> _held = ValueNotifier(
    Trace(spots: _latch, word: _board.wordFor(_latch), verdict: Refusal.none),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: CustomPaint(
        size: const Size.square(190),
        painter: BoardPainter(
          board: _board,
          live: _held,
          settle: const AlwaysStoppedAnimation(0),
          letters: DefaultTextStyle.of(context).style,
        ),
      ),
    );
  }
}
