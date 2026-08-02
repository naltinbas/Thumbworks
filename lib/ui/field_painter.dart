import 'dart:math';

import 'package:flutter/rendering.dart';

import '../sim/field.dart';
import '../sim/kinds.dart';
import '../sim/run.dart';
import 'palette.dart';

/// Where the cells are on the screen.
///
/// One object works it out, and the painter, the finger and the tests all ask
/// it. Working it out twice is how a tower goes up on a square the thumb was
/// not on.
class Metrics {
  factory Metrics(Size space) {
    final cell = min(space.width / Field.columns, space.height / Field.rows);
    return Metrics._(
      cell: cell,
      origin: Offset(
        (space.width - cell * Field.columns) / 2,
        (space.height - cell * Field.rows) / 2,
      ),
    );
  }

  const Metrics._({required this.cell, required this.origin});

  final double cell;
  final Offset origin;

  Rect rectOf(Cell at) => Rect.fromLTWH(
        origin.dx + at.col * cell,
        origin.dy + at.row * cell,
        cell,
        cell,
      );

  /// Where a point in the simulation's coordinates lands on the screen.
  Offset spotOf(Spot at) =>
      Offset(origin.dx + at.x * cell, origin.dy + at.y * cell);

  Rect get field => Rect.fromLTWH(
        origin.dx,
        origin.dy,
        cell * Field.columns,
        cell * Field.rows,
      );

  Cell? under(Offset at) {
    final x = at.dx - origin.dx;
    final y = at.dy - origin.dy;
    if (x < 0 || y < 0) return null;
    if (x >= cell * Field.columns || y >= cell * Field.rows) return null;
    return Cell(x ~/ cell, y ~/ cell);
  }
}

/// Draws the field, what is on it, and what is happening to it.
///
/// Nothing to load: the lane is rectangles, the towers are shapes and the
/// walkers are circles with a bar over them, so it is sharp at any size and
/// the app ships no art at all.
class FieldPainter extends CustomPainter {
  FieldPainter({
    required this.run,
    required this.metrics,
    this.placing,
    this.chosen,
  });

  final Run run;
  final Metrics metrics;

  /// The tower being placed, if the player is placing one. While they are,
  /// every square it could go on is lit.
  final Tower? placing;

  /// The square being looked at.
  final Cell? chosen;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGround(canvas);
    _paintLane(canvas);
    _paintRoom(canvas);
    _paintTowers(canvas);
    _paintShots(canvas);
    _paintWalkers(canvas);
  }

  void _paintGround(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(metrics.field, const Radius.circular(8)),
      Paint()..color = Palette.ground,
    );
  }

  void _paintLane(Canvas canvas) {
    final lane = Paint()..color = Palette.lane;
    for (final cell in Field.only.path) {
      canvas.drawRect(metrics.rectOf(cell), lane);
    }

    // A brighter mouth and tail, so which end things come in at is not
    // something to work out.
    canvas.drawRect(
      metrics.rectOf(Field.only.entrance),
      Paint()..color = Palette.laneEdge,
    );
    canvas.drawRect(
      metrics.rectOf(Field.only.exit),
      Paint()..color = Palette.keep.withValues(alpha: 0.35),
    );
  }

  void _paintRoom(Canvas canvas) {
    if (placing != null) {
      final room = Paint()..color = Palette.room;
      for (var col = 0; col < Field.columns; col++) {
        for (var row = 0; row < Field.rows; row++) {
          final cell = Cell(col, row);
          if (!run.canBuildOn(cell)) continue;
          canvas.drawRect(metrics.rectOf(cell).deflate(1), room);
        }
      }
    }

    final at = chosen;
    if (at == null) return;
    canvas.drawRect(
      metrics.rectOf(at).deflate(1),
      Paint()..color = Palette.chosen,
    );

    // The reach of whatever is there or about to be, because where a tower
    // can shoot is the whole of the decision.
    final tower = run.towerOn(at);
    final reach = tower?.reach ?? placing?.reach;
    if (reach == null) return;
    canvas.drawCircle(
      metrics.rectOf(at).center,
      reach * metrics.cell,
      Paint()
        ..color = Palette.chosen.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _paintTowers(Canvas canvas) {
    for (final tower in run.built) {
      final box = metrics.rectOf(tower.on).deflate(metrics.cell * 0.16);
      final colour = Palette.of(tower.kind);

      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(metrics.cell * 0.16)),
        Paint()..color = colour.withValues(alpha: 0.22),
      );

      // Each kind is a different shape as well as a different colour, because
      // three coloured squares on a dark field is three squares to anybody
      // who is not looking hard.
      final ink = Paint()..color = colour;
      final middle = box.center;
      final radius = box.width * 0.3;
      switch (tower.kind) {
        case Tower.spark:
          canvas.drawCircle(middle, radius, ink);
        case Tower.forge:
          canvas.drawRect(
            Rect.fromCenter(
              center: middle,
              width: radius * 1.9,
              height: radius * 1.9,
            ),
            ink,
          );
        case Tower.frost:
          canvas.drawPath(
            Path()
              ..moveTo(middle.dx, middle.dy - radius * 1.2)
              ..lineTo(middle.dx + radius * 1.2, middle.dy)
              ..lineTo(middle.dx, middle.dy + radius * 1.2)
              ..lineTo(middle.dx - radius * 1.2, middle.dy)
              ..close(),
            ink,
          );
      }

      // A second level is a ring round it rather than a number.
      if (tower.level > 1) {
        canvas.drawCircle(
          middle,
          box.width * 0.44,
          Paint()
            ..color = colour
            ..style = PaintingStyle.stroke
            ..strokeWidth = metrics.cell * 0.05,
        );
      }
    }
  }

  void _paintShots(Canvas canvas) {
    for (final shot in run.shots) {
      canvas.drawLine(
        metrics.spotOf(shot.from),
        metrics.spotOf(shot.to),
        Paint()
          ..color = Palette.of(shot.kind).withValues(alpha: 0.85 * shot.strength)
          ..strokeWidth = shot.kind == Tower.forge ? 3.2 : 1.6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintWalkers(Canvas canvas) {
    for (final walker in run.walking) {
      final at = metrics.spotOf(walker.at);
      final size = metrics.cell *
          switch (walker.kind) {
            Walker.runner => 0.16,
            Walker.lumberer => 0.30,
            _ => 0.22,
          };

      canvas.drawCircle(
        at,
        size,
        Paint()..color = Palette.ofWalker(walker.kind),
      );

      // Slowed things wear a ring, because a player needs to see that the
      // frost tower they paid for is doing something.
      if (walker.slowedFor > 0) {
        canvas.drawCircle(
          at,
          size + metrics.cell * 0.07,
          Paint()
            ..color = Palette.of(Tower.frost).withValues(alpha: 0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = metrics.cell * 0.045,
        );
      }

      // A bar over the head, and only once something has been taken off it: a
      // field of full bars is a field of clutter.
      if (walker.share >= 1) continue;
      final bar = Rect.fromLTWH(
        at.dx - size,
        at.dy - size - metrics.cell * 0.17,
        size * 2,
        metrics.cell * 0.07,
      );
      canvas.drawRect(bar, Paint()..color = Palette.night);
      canvas.drawRect(
        Rect.fromLTWH(bar.left, bar.top, bar.width * walker.share, bar.height),
        Paint()..color = Palette.good,
      );
    }
  }

  @override
  bool shouldRepaint(FieldPainter old) => true;
}
