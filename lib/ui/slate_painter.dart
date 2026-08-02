import 'dart:math';

import 'package:flutter/rendering.dart';

import '../sim/levels.dart';
import '../sim/shapes.dart';
import '../sim/stroke.dart';
import '../sim/world.dart';
import 'palette.dart';

/// Where the world is on the screen.
///
/// The world is ten units across and twenty down whatever phone it is on, so
/// a level looks the same everywhere and a drawing that works on one screen
/// works on all of them. That is worth more than filling the glass: a puzzle
/// whose geometry depends on the phone is a different puzzle on every phone.
class Metrics {
  factory Metrics(Size space) {
    final scale = space.width / World.across < space.height / World.down
        ? space.width / World.across
        : space.height / World.down;
    return Metrics._(
      scale: scale,
      origin: Offset(
        (space.width - World.across * scale) / 2,
        (space.height - World.down * scale) / 2,
      ),
      space: space,
    );
  }

  const Metrics._({
    required this.scale,
    required this.origin,
    required this.space,
  });

  /// How many pixels one unit is.
  final double scale;

  final Offset origin;
  final Size space;

  Offset toScreen(Spot spot) =>
      origin + Offset(spot.x * scale, spot.y * scale);

  Spot toWorld(Offset at) => Spot(
        (at.dx - origin.dx) / scale,
        (at.dy - origin.dy) / scale,
      );

  Rect get board => Rect.fromLTWH(
        origin.dx,
        origin.dy,
        World.across * scale,
        World.down * scale,
      );
}

/// Draws the board, the chalk and the ball.
class SlatePainter extends CustomPainter {
  SlatePainter({
    required this.level,
    required this.drawing,
    required this.metrics,
    this.world,
    this.drawingNow,
    this.trail = const [],
  });

  final Level level;
  final Drawing drawing;
  final Metrics metrics;

  /// The run, while one is going. Null while the player is still drawing.
  final World? world;

  /// The stroke under the finger this second.
  final Stroke? drawingNow;

  /// Where the ball has been, this run.
  final List<Spot> trail;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Palette.slateDeep);
    canvas.drawRect(metrics.board, Paint()..color = Palette.slate);

    _paintRing(canvas);
    _paintSpikes(canvas);
    _paintLines(canvas, level.solid, Palette.fixed, 0.13);
    _paintTrail(canvas);
    _paintLines(canvas, drawing.lines, Palette.chalk, 0.16);
    if (drawingNow != null) {
      _paintLines(canvas, drawingNow!.lines, Palette.wet, 0.16);
    }
    _paintBall(canvas);
  }

  void _paintLines(Canvas canvas, List<Line> lines, Color colour, double wide) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = wide * metrics.scale
      ..strokeCap = StrokeCap.round;
    for (final line in lines) {
      canvas.drawLine(
        metrics.toScreen(line.from),
        metrics.toScreen(line.to),
        paint,
      );
    }
  }

  void _paintRing(Canvas canvas) {
    canvas.drawCircle(
      metrics.toScreen(level.goal.at),
      level.goal.radius * metrics.scale,
      Paint()..color = Palette.ring.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      metrics.toScreen(level.goal.at),
      level.goal.radius * metrics.scale,
      Paint()
        ..color = Palette.ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.09 * metrics.scale,
    );
  }

  void _paintSpikes(Canvas canvas) {
    for (final spike in level.spikes) {
      final middle = metrics.toScreen(spike.at);
      final size = spike.radius * metrics.scale;
      // A burst rather than a circle: round things on this board are the ball
      // and the ring, and the one thing that ends a run should not look like
      // either of them.
      final path = Path();
      for (var i = 0; i < 16; i++) {
        final turn = i * pi / 8;
        final reach = i.isEven ? size : size * 0.5;
        final point = Offset(
          middle.dx + reach * cos(turn),
          middle.dy + reach * sin(turn),
        );
        i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = Palette.spike);
    }
  }

  void _paintTrail(Canvas canvas) {
    if (trail.length < 2) return;
    final path = Path()
      ..moveTo(metrics.toScreen(trail.first).dx,
          metrics.toScreen(trail.first).dy);
    for (final spot in trail.skip(1)) {
      final at = metrics.toScreen(spot);
      path.lineTo(at.dx, at.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Palette.ball.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.06 * metrics.scale,
    );
  }

  void _paintBall(Canvas canvas) {
    // A won run stops the instant the middle of the ball is inside the ring,
    // which leaves it drawn perched on the rim — a picture of a near miss at
    // the end of the one run that was not one. So it is drawn where it has in
    // every sense arrived: in the middle of the ring. The trail still ends
    // where the ball actually was.
    final at = world?.ending == Ending.home
        ? level.goal.at
        : world?.ball ?? level.start;
    canvas.drawCircle(
      metrics.toScreen(at),
      World.ballRadius * metrics.scale,
      Paint()..color = Palette.ball,
    );
  }

  @override
  bool shouldRepaint(SlatePainter old) => true;
}
