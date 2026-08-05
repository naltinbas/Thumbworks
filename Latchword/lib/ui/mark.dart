import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/lexicon.dart';
import 'board_painter.dart';
import 'palette.dart';
import 'tracer.dart';

/// The mark: a small board with a word being traced across it.
///
/// It is not a drawing of the game — it is the board painter, given a real
/// board and a real trace, so the line in the logo is a line the game would
/// draw and the word under it is a word the game would take.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onPanel;

  /// Three by three, and the trace runs L-A-T-C-H across it.
  static const letters = <String>[
    'l', 'a', 't', //
    'w', 'h', 'c', //
    'o', 'r', 'd', //
  ];

  static const traced = <Spot>[
    Spot(0, 0),
    Spot(0, 1),
    Spot(0, 2),
    Spot(1, 2),
    Spot(1, 1),
  ];

  static Board get board => Board(
        size: 3,
        letters: letters,
        lexicon: Lexicon.of(const ['latch']),
      );

  /// The trace as the painter wants it: the squares, the word they spell, and
  /// the verdict the board gives it.
  static Trace get trace => Trace(
        spots: traced,
        word: [for (final spot in traced) letters[spot.row * 3 + spot.col]]
            .join(),
        verdict: Refusal.none,
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final side = box.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onPanel)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.panel,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: BoardPainter(
                      board: board,
                      live: ValueNotifier(trace),
                      settle: const AlwaysStoppedAnimation(0),
                      letters: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: side * 0.16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
