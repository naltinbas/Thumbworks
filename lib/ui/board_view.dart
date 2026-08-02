import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/board.dart';
import 'board_painter.dart';

/// The board, and the player's finger on it.
///
/// Pick a man up, put him down. Not drag: a drag on a board this size means a
/// thumb covering the square it is aiming at, and the squares a man may go to
/// are the thing worth seeing while choosing. Tapping shows them and keeps the
/// hand out of the way.
///
/// Tapping the man again puts him back, and tapping a different one of your
/// own picks that one up instead, which is what a player expects and saves a
/// tap on the empty board between them.
class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.board,
    required this.picked,
    required this.onPick,
    required this.onPlay,
    this.last,
    this.dimmed = false,
    this.frozen = false,
  });

  final Board board;

  /// The man picked up, if any.
  final Square? picked;

  /// Pick a man up, or put him back down by passing null.
  final ValueChanged<Square?> onPick;

  final ValueChanged<Move> onPlay;

  final Move? last;
  final bool dimmed;

  /// True while it is not the player's move, so the board looks at but does
  /// not answer.
  final bool frozen;

  /// Where the picked-up man may go.
  List<Square> get destinations => picked == null
      ? const []
      : [
          for (final move in board.moves)
            if (move.from == picked) move.to,
        ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final metrics = Metrics(Size(box.maxWidth, box.maxHeight));
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: frozen ? null : (details) => _tapped(metrics, details.localPosition),
          child: CustomPaint(
            size: Size(box.maxWidth, box.maxHeight),
            painter: BoardPainter(
              board: board,
              metrics: metrics,
              picked: picked,
              canGo: destinations,
              last: last,
              dimmed: dimmed,
            ),
          ),
        );
      },
    );
  }

  void _tapped(Metrics metrics, Offset at) {
    final square = metrics.under(at);
    if (square == null) return;

    if (picked != null) {
      if (square == picked) {
        onPick(null);
        return;
      }
      final move = Move(picked!, square);
      if (board.allows(move)) {
        HapticFeedback.selectionClick();
        onPlay(move);
        return;
      }
    }

    final man = board.at(square);
    if (man != null && board.turn.owns(man)) {
      HapticFeedback.selectionClick();
      onPick(square);
      return;
    }
    // A tap on an empty square with nothing picked up, or on the other side's
    // man: put down whatever was in hand rather than leaving it lit.
    if (picked != null) onPick(null);
  }
}
