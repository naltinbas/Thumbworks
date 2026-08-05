import 'package:flutter/material.dart';

import '../thread/field.dart';
import '../thread/play.dart';
import 'knots.dart';
import 'palette.dart';

/// Where everything on the board is.
///
/// The painter and the finger both use this, which is the point of it: a cell
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.field, Size box) {
    final across = (box.width - _margin * 2) / field.across;
    final down = (box.height - _margin * 2) / field.down;
    cell = across < down ? across : down;
    corner = Offset(
      (box.width - cell * field.across) / 2,
      (box.height - cell * field.down) / 2,
    );
  }

  static const _margin = 4.0;

  final Field field;

  /// The side of one cell.
  late final double cell;

  /// The top left of the board within the box.
  late final Offset corner;

  Rect get board => corner & Size(cell * field.across, cell * field.down);

  Offset middleOf(int at) => corner +
      Offset(
        (field.columnOf(at) + 0.5) * cell,
        (field.rowOf(at) + 0.5) * cell,
      );

  /// The cell under a point, or -1 off the board.
  int cellAt(Offset where) {
    final column = ((where.dx - corner.dx) / cell).floor();
    final row = ((where.dy - corner.dy) / cell).floor();
    if (column < 0 || column >= field.across) return -1;
    if (row < 0 || row >= field.down) return -1;
    return row * field.across + column;
  }
}

/// The board: the peat, the threads laid across it, and the ends.
class Weave extends CustomPainter {
  const Weave({
    required this.play,
    required this.holding,
    required this.pointing,
    required this.rubbing,
  });

  final Play play;

  /// The thread a finger is on, or -1.
  final int holding;

  /// A cell the game is pointing at, or -1.
  final int pointing;

  /// Whether what it is pointing at should come off rather than go on.
  final bool rubbing;

  @override
  void paint(Canvas canvas, Size size) {
    final field = play.field;
    final metrics = Metrics(field, size);
    final cell = metrics.cell;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        metrics.board.inflate(cell * 0.06),
        Radius.circular(cell * 0.22),
      ),
      Paint()..color = Palette.peat,
    );

    final furrow = Paint()
      ..color = Palette.furrow
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (var row = 1; row < field.down; row++) {
      final y = metrics.corner.dy + row * cell;
      canvas.drawLine(
        Offset(metrics.corner.dx, y),
        Offset(metrics.corner.dx + cell * field.across, y),
        furrow,
      );
    }
    for (var column = 1; column < field.across; column++) {
      final x = metrics.corner.dx + column * cell;
      canvas.drawLine(
        Offset(x, metrics.corner.dy),
        Offset(x, metrics.corner.dy + cell * field.down),
        furrow,
      );
    }

    for (var thread = 0; thread < field.threads; thread++) {
      _wool(canvas, metrics, thread);
    }
    for (var thread = 0; thread < field.threads; thread++) {
      final ends = field.ends[thread];
      paintKnot(canvas, metrics.middleOf(ends.$1), cell * 0.62, thread,
          held: holding == thread);
      paintKnot(canvas, metrics.middleOf(ends.$2), cell * 0.62, thread,
          held: holding == thread);
    }

    if (pointing >= 0) {
      final ring = Paint()
        ..color = rubbing ? Palette.bad : Palette.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.075;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: metrics.middleOf(pointing),
            width: cell * 0.86,
            height: cell * 0.86,
          ),
          Radius.circular(cell * 0.2),
        ),
        ring,
      );
    }
  }

  /// One thread: a line through the middles of its cells, with a round end
  /// where the drawing has got to.
  void _wool(Canvas canvas, Metrics metrics, int thread) {
    final path = play.pathOf(thread);
    final colour = Palette.woolFor(thread);
    final cell = metrics.cell;

    if (path.length > 1) {
      final line = Path()..moveTo(
          metrics.middleOf(path.first).dx, metrics.middleOf(path.first).dy);
      for (final at in path.skip(1)) {
        line.lineTo(metrics.middleOf(at).dx, metrics.middleOf(at).dy);
      }
      canvas.drawPath(
        line,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell * 0.34
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }

    // The head, unless the thread is joined up: then both its ends are pegs
    // and a cap on top of one would only make it look unfinished.
    if (!play.isJoined(thread) && path.length > 1) {
      canvas.drawCircle(
        metrics.middleOf(path.last),
        cell * 0.23,
        Paint()..color = colour,
      );
      canvas.drawCircle(
        metrics.middleOf(path.last),
        cell * 0.1,
        Paint()..color = Palette.night.withValues(alpha: 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(Weave old) =>
      old.play != play ||
      old.holding != holding ||
      old.pointing != pointing ||
      old.rubbing != rubbing;
}
