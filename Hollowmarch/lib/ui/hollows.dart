import 'package:flutter/material.dart';

import '../pegs/field.dart';
import '../pegs/play.dart';
import 'palette.dart';

/// Where everything on the board is.
///
/// The painter and the finger both use this, which is the point of it: a
/// hollow is where it is drawn, and there is no second sum that could
/// disagree with the first.
class Metrics {
  Metrics(this.field, Size room) {
    final across = (room.width - _margin * 2) / field.wide;
    final down = (room.height - _margin * 2) / field.deep;
    cell = across < down ? across : down;
    corner = Offset(
      (room.width - cell * field.wide) / 2,
      (room.height - cell * field.deep) / 2,
    );
  }

  static const _margin = 6.0;

  final Field field;

  late final double cell;
  late final Offset corner;

  Offset middleOf(int hollow) => corner +
      Offset(
        (field.columnOf(hollow) + 0.5) * cell,
        (field.rowOf(hollow) + 0.5) * cell,
      );

  /// The hollow under a point, or -1.
  int whereIs(Offset touch) {
    final column = ((touch.dx - corner.dx) / cell).floor();
    final row = ((touch.dy - corner.dy) / cell).floor();
    return field.at(row, column);
  }
}

/// The board: the wood, the hollows, and the pegs standing in them.
class Hollows extends CustomPainter {
  const Hollows({
    required this.play,
    required this.holding,
    required this.pointing,
    required this.wrong,
  });

  final Play play;

  /// A peg picked up but not yet jumped, or -1.
  final int holding;

  /// Hollows the game is pointing at.
  final List<int> pointing;

  /// Whether it is pointing at something that has gone wrong.
  final bool wrong;

  @override
  void paint(Canvas canvas, Size size) {
    final field = play.field;
    final metrics = Metrics(field, size);
    final cell = metrics.cell;

    // The wood, as one shape: every hollow's square, rounded off.
    final board = Path();
    for (var hollow = 0; hollow < field.hollows; hollow++) {
      board.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: metrics.middleOf(hollow),
            width: cell * 1.1,
            height: cell * 1.1,
          ),
          Radius.circular(cell * 0.22),
        ),
      );
    }
    canvas.drawPath(board, Paint()..color = Palette.wood);

    for (var hollow = 0; hollow < field.hollows; hollow++) {
      final middle = metrics.middleOf(hollow);
      canvas.drawCircle(
        middle,
        cell * 0.30,
        Paint()..color = Palette.hollow,
      );
      canvas.drawCircle(
        middle,
        cell * 0.30,
        Paint()
          ..color = Palette.grain
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell * 0.035,
      );

      if (!play.has(hollow)) continue;
      final onTheMove = hollow == play.carrying || hollow == holding;
      canvas.drawCircle(
        middle,
        cell * 0.32,
        Paint()..color = onTheMove ? Palette.moving : Palette.peg,
      );
      canvas.drawCircle(
        middle,
        cell * 0.32,
        Paint()
          ..color = onTheMove ? Palette.moving : Palette.pegEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell * 0.04,
      );
      if (onTheMove) {
        canvas.drawCircle(
          middle,
          cell * 0.44,
          Paint()
            ..color = Palette.moving.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.05,
        );
      }
    }

    if (pointing.isEmpty) return;
    final ring = Paint()
      ..color = wrong ? Palette.bad : Palette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell * 0.055;
    for (final hollow in pointing) {
      canvas.drawCircle(metrics.middleOf(hollow), cell * 0.42, ring);
    }
  }

  @override
  bool shouldRepaint(Hollows old) =>
      old.play != play ||
      old.holding != holding ||
      old.wrong != wrong ||
      old.pointing.length != pointing.length ||
      !old.pointing.every(pointing.contains);
}
