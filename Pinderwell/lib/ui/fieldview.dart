import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../drive/cold.dart';
import '../drive/play.dart';
import 'palette.dart';

/// Where everything stands, shared by the painter and the hit-testing, so
/// where a square is drawn is exactly where a square is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    final field = play.field;
    cell = math.min(room.width / field.across, room.height / field.down);
    final wide = cell * field.across;
    final high = cell * field.down;
    corner = Offset((room.width - wide) / 2, (room.height - high) / 2);
    board = Rect.fromLTWH(corner.dx, corner.dy, wide, high);
  }

  final Play play;

  late final double cell;
  late final Offset corner;
  late final Rect board;

  /// The square so many paces east and north of the pen. The pen is the
  /// bottom-left corner of the board.
  Rect squareRect(int east, int north) => Rect.fromLTWH(
        corner.dx + east * cell,
        corner.dy + (play.field.down - 1 - north) * cell,
        cell,
        cell,
      );

  Offset middleOf(int east, int north) => squareRect(east, north).center;

  /// The square under a touch, or null off the board.
  (int, int)? squareAt(Offset touch) {
    if (!board.contains(touch)) return null;
    final east = ((touch.dx - corner.dx) / cell).floor();
    final row = ((touch.dy - corner.dy) / cell).floor();
    final north = play.field.down - 1 - row;
    if (east < 0 || north < 0 ||
        east >= play.field.across || north >= play.field.down) {
      return null;
    }
    return (east, north);
  }
}

/// The field, drawn.
class FieldView extends CustomPainter {
  FieldView({
    required this.play,
    required this.pointing,
    required this.showRungs,
  });

  final Play play;

  /// The square being pointed at, or null.
  final (int, int)? pointing;

  /// Whether to mark the ladder on the grass.
  final bool showRungs;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    _grass(canvas, metrics);
    if (showRungs) _rungs(canvas, metrics);
    _pen(canvas, metrics);
    if (play.theirFrom != null) _theirPush(canvas, metrics);
    if (pointing != null) _point(canvas, metrics);
    if (!play.isOver) _ewe(canvas, metrics);
    _wall(canvas, metrics);
  }

  void _grass(Canvas canvas, Metrics metrics) {
    for (var east = 0; east < play.field.across; east++) {
      for (var north = 0; north < play.field.down; north++) {
        canvas.drawRect(
          metrics.squareRect(east, north),
          Paint()
            ..color =
                (east + north).isEven ? Palette.grass : Palette.grassLight,
        );
      }
    }
  }

  void _wall(Canvas canvas, Metrics metrics) {
    canvas.drawRect(
      metrics.board.deflate(0.8),
      Paint()
        ..color = Palette.wall
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    // Stones along the wall, so it reads as laid rather than ruled.
    final stone = Paint()
      ..color = Palette.wall.withValues(alpha: 0.55)
      ..strokeWidth = 1.2;
    final board = metrics.board;
    for (var along = metrics.cell * 0.7;
        along < board.width - 2;
        along += metrics.cell * 0.7) {
      canvas.drawLine(Offset(board.left + along, board.top),
          Offset(board.left + along, board.top + 3.5), stone);
      canvas.drawLine(Offset(board.left + along, board.bottom),
          Offset(board.left + along, board.bottom - 3.5), stone);
    }
    for (var along = metrics.cell * 0.7;
        along < board.height - 2;
        along += metrics.cell * 0.7) {
      canvas.drawLine(Offset(board.left, board.top + along),
          Offset(board.left + 3.5, board.top + along), stone);
      canvas.drawLine(Offset(board.right, board.top + along),
          Offset(board.right - 3.5, board.top + along), stone);
    }
  }

  void _pen(Canvas canvas, Metrics metrics) {
    final square = metrics.squareRect(0, 0).deflate(metrics.cell * 0.1);
    final hurdle = Paint()
      ..color = Palette.pen
      ..strokeWidth = math.max(1.6, metrics.cell * 0.055)
      ..strokeCap = StrokeCap.round;

    // Three bars along the two open sides; the wall pens the others.
    for (var bar = 0; bar < 3; bar++) {
      final away = square.height * (0.18 + 0.28 * bar);
      canvas.drawLine(
        Offset(square.left, square.top + away),
        Offset(square.right - square.width * 0.06, square.top + away),
        hurdle,
      );
      canvas.drawLine(
        Offset(square.left + away, square.top),
        Offset(square.left + away, square.bottom - square.height * 0.06),
        hurdle,
      );
    }

    if (play.isOver) {
      // The ewe in the pen, smaller, done.
      _sheep(canvas, metrics.squareRect(0, 0).deflate(metrics.cell * 0.26));
    }
  }

  void _rungs(Canvas canvas, Metrics metrics) {
    for (var east = 0; east < play.field.across; east++) {
      for (var north = 0; north < play.field.down; north++) {
        // The pen is the ladder's foot, and the hurdles already say so.
        if (east == 0 && north == 0) continue;
        if (!Cold.isCold(east, north)) continue;
        final square = metrics.squareRect(east, north);
        final tuft = Paint()
          ..color = Palette.rung
          ..strokeWidth = math.max(1.6, metrics.cell * 0.06)
          ..strokeCap = StrokeCap.round;
        final middle = square.center;
        final reach = square.width * 0.16;
        // A tuft of three blades, and a ring to make it unmissable.
        for (final lean in const [-0.5, 0.0, 0.5]) {
          canvas.drawLine(
            middle + Offset(lean * reach * 0.8, reach * 0.7),
            middle + Offset(lean * reach, -reach * 0.8),
            tuft,
          );
        }
        canvas.drawCircle(
          middle,
          square.width * 0.34,
          Paint()
            ..color = Palette.rung.withValues(alpha: 0.75)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }
  }

  void _theirPush(Canvas canvas, Metrics metrics) {
    final from = metrics.middleOf(play.theirFrom!.$1, play.theirFrom!.$2);
    final to = metrics.middleOf(play.east, play.north);
    final push = Paint()
      ..color = Palette.pinder.withValues(alpha: 0.85)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final way = (to - from);
    final length = way.distance;
    if (length < 1) return;
    final step = way / length;
    // Margins small enough that a one-pace push still keeps a shaft.
    final start = from + step * (metrics.cell * 0.16);
    final end = to - step * (metrics.cell * 0.34);
    canvas.drawLine(start, end, push);

    // The head.
    final side = Offset(-step.dy, step.dx);
    canvas.drawLine(end, end - step * 7 + side * 5, push);
    canvas.drawLine(end, end - step * 7 - side * 5, push);
  }

  void _point(Canvas canvas, Metrics metrics) {
    final square = metrics.squareRect(pointing!.$1, pointing!.$2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        square.deflate(metrics.cell * 0.08),
        Radius.circular(metrics.cell * 0.18),
      ),
      Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  void _ewe(Canvas canvas, Metrics metrics) {
    _sheep(canvas,
        metrics.squareRect(play.east, play.north).deflate(metrics.cell * 0.16));
  }

  /// A ewe filling [room], facing the pen.
  void _sheep(Canvas canvas, Rect room) {
    final body = Paint()..color = Palette.fleece;
    final shade = Paint()..color = Palette.fleeceShade;
    final dark = Paint()..color = Palette.muzzle;

    final middle = room.center;
    final wide = room.width;

    // Legs first, so the fleece sits over them.
    final leg = Paint()
      ..color = Palette.muzzle
      ..strokeWidth = math.max(1.4, wide * 0.06)
      ..strokeCap = StrokeCap.round;
    for (final at in const [-0.22, -0.05, 0.12, 0.28]) {
      canvas.drawLine(
        middle + Offset(wide * at, wide * 0.1),
        middle + Offset(wide * at, wide * 0.34),
        leg,
      );
    }

    // The fleece: a few woolly lobes.
    canvas.drawCircle(middle + Offset(wide * 0.1, 0), wide * 0.30, shade);
    canvas.drawCircle(middle + Offset(-wide * 0.12, -wide * 0.04),
        wide * 0.26, body);
    canvas.drawCircle(middle + Offset(0.0, -wide * 0.12), wide * 0.24, body);
    canvas.drawCircle(middle + Offset(wide * 0.16, -wide * 0.06),
        wide * 0.24, body);

    // Head toward the pen, down-left, with an ear.
    final head = middle + Offset(-wide * 0.34, wide * 0.02);
    canvas.drawCircle(head, wide * 0.13, dark);
    canvas.drawOval(
      Rect.fromCenter(
        center: head + Offset(wide * 0.02, -wide * 0.12),
        width: wide * 0.14,
        height: wide * 0.08,
      ),
      shade,
    );
  }

  @override
  bool shouldRepaint(FieldView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showRungs != showRungs;
}
