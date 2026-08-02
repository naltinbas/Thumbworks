import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/clues.dart';
import '../game/grid.dart';
import '../game/line.dart';
import 'board_painter.dart';
import 'metrics.dart';

/// What a stroke is doing to every square it crosses.
///
/// Named for the doing rather than the mark, because rubbing out is one of the
/// three and there is no such thing as a rubbed-out mark.
enum Marking { fill, cross, rub }

/// Which of the two marks the thumb is putting down.
enum Mode {
  /// Filling in the picture.
  fill,

  /// Crossing off where the picture is not.
  cross,
}

/// The board, and the thumb on it.
///
/// Strokes rather than taps, because a nonogram is played in runs: a clue says
/// four together and the player wants to put four together down in one go.
/// Tapping four times is four chances to miss.
///
/// Two rules make a stroke behave. The first square decides what the whole
/// stroke does — a stroke that starts on a filled square rubs out, so the way
/// to undo four squares is to draw back over them — and the stroke locks to a
/// row or a column as soon as it leaves that first square. Without the lock a
/// thumb dragging along a row wanders a square up or down on the way and
/// leaves a staircase behind it.
class BoardView extends StatefulWidget {
  const BoardView({
    super.key,
    required this.grid,
    required this.clues,
    required this.mode,
    required this.onStroke,
    required this.onMark,
    this.finished = false,
  });

  final Grid grid;
  final Clues clues;
  final Mode mode;

  /// A new stroke has begun, which is one thing to undo.
  final VoidCallback onStroke;

  /// One square has been marked.
  final void Function(int row, int col, Square to) onMark;

  final bool finished;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  /// What the stroke in progress is doing.
  Marking? _doing;

  /// Where it started, and which way it has committed to going.
  ({int row, int col})? _from;
  Axis? _along;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final metrics = Metrics(
          space: Size(box.maxWidth, box.maxHeight),
          clues: widget.clues,
        );

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: widget.finished ? null : (e) => _down(metrics, e.localPosition),
          onPointerMove: widget.finished ? null : (e) => _moved(metrics, e.localPosition),
          onPointerUp: (_) => _lift(),
          onPointerCancel: (_) => _lift(),
          child: CustomPaint(
            size: Size(box.maxWidth, box.maxHeight),
            painter: BoardPainter(
              grid: widget.grid,
              clues: widget.clues,
              metrics: metrics,
              numbers: Theme.of(context).textTheme.bodyMedium!,
              finished: widget.finished,
            ),
          ),
        );
      },
    );
  }

  void _down(Metrics metrics, Offset at) {
    final square = metrics.squareUnder(at);
    if (square == null) return;

    final was = widget.grid.at(square.row, square.col);
    final wanted = widget.mode == Mode.fill ? Square.filled : Square.blank;
    _doing = was == wanted ? Marking.rub : _paintFor(wanted);
    _from = square;
    _along = null;

    widget.onStroke();
    _mark(square.row, square.col);
    HapticFeedback.selectionClick();
  }

  void _moved(Metrics metrics, Offset at) {
    final doing = _doing;
    final from = _from;
    if (doing == null || from == null) return;

    // A little slack past the edge, so a stroke aimed at the last column does
    // not stop dead when the thumb strays off the grid.
    final square = metrics.squareUnder(at, slack: metrics.square * 0.5);
    if (square == null) return;
    if (square.row == from.row && square.col == from.col) return;

    // Which way this stroke is going, decided once, the first time it leaves
    // the square it started on.
    _along ??= square.row == from.row
        ? Axis.horizontal
        : square.col == from.col
            ? Axis.vertical
            : ((square.col - from.col).abs() >= (square.row - from.row).abs()
                ? Axis.horizontal
                : Axis.vertical);

    final row = _along == Axis.horizontal ? from.row : square.row;
    final col = _along == Axis.horizontal ? square.col : from.col;
    if (_mark(row, col)) HapticFeedback.selectionClick();
  }

  void _lift() {
    _doing = null;
    _from = null;
    _along = null;
  }

  /// Marks a square, and says whether that changed anything.
  bool _mark(int row, int col) {
    final to = switch (_doing!) {
      Marking.fill => Square.filled,
      Marking.cross => Square.blank,
      Marking.rub => Square.unknown,
    };
    if (widget.grid.at(row, col) == to) return false;
    widget.onMark(row, col, to);
    return true;
  }

  static Marking _paintFor(Square square) =>
      square == Square.filled ? Marking.fill : Marking.cross;
}
