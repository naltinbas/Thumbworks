import 'package:flutter/rendering.dart';

import '../sim/journey.dart';
import 'palette.dart';

/// How the world maps onto the screen.
///
/// The runner stays at a fixed place across the screen and the world slides
/// past. Putting them a third of the way in rather than in the middle is what
/// gives a player something to react to: half a second of what is coming is
/// worth more than a view of where they have been.
class Metrics {
  factory Metrics(Size space) {
    // Thirteen tiles across. Measured from the width and not the height,
    // because what matters is how much of what is coming a player can see, and
    // that is a question about the width. Sized from the height it came out at
    // four tiles across, which is a runner that is all reflex and no reading.
    final tile = space.width / 11;
    return Metrics._(
      tile: tile,
      space: space,
      floor: space.height * 0.80,
      runnerAt: space.width * 0.30,
    );
  }

  const Metrics._({
    required this.tile,
    required this.space,
    required this.floor,
    required this.runnerAt,
  });

  /// How big one tile is on screen.
  final double tile;

  final Size space;

  /// Where the ground sits, measured down from the top.
  final double floor;

  /// Where across the screen the runner is.
  final double runnerAt;

  /// How many tiles fit across.
  int get across => (space.width / tile).ceil() + 2;

  /// Where a tile lands on screen, given where the runner is in the world.
  double screenX(double worldX, double runnerX) =>
      runnerAt + (worldX - runnerX) * tile;

  /// How high above the floor something at [y] tiles is drawn.
  double screenY(double y) => floor - y * tile;
}

/// Draws the world and the runner on it.
///
/// Nothing to load. The ground is rectangles, the spikes are triangles and the
/// runner is a rounded square, so it is sharp at any size and the app ships no
/// art at all.
class WorldPainter extends CustomPainter {
  WorldPainter({required this.journey, required this.metrics});

  final Journey journey;
  final Metrics metrics;

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);
    _paintFar(canvas);
    _paintGround(canvas);
    _paintRunner(canvas);
  }

  /// Something in the distance, going by more slowly.
  ///
  /// Without it the sky is a flat wash and the only thing that says the runner
  /// is moving is the ground under it — which, on a long flat stretch, says
  /// nothing at all. A row of far-off shapes at a third of the speed is the
  /// cheapest way there is to make a still picture look like a run.
  void _paintFar(Canvas canvas) {
    final run = journey.run;
    final wide = metrics.tile * 1.6;
    final at = run.x * 0.34;
    final from = (at - metrics.runnerAt / wide).floor() - 1;
    final paint = Paint()..color = Palette.far;

    for (var i = from; i < from + (metrics.space.width / wide).ceil() + 3; i++) {
      // A height from the number itself, so the skyline is the same every time
      // the runner comes past and there is nothing to store.
      final high = 1.1 + ((i * 2654435761) % 7) * 0.42;
      final left = metrics.runnerAt + (i - at) * wide;
      final top = metrics.floor - high * metrics.tile;
      canvas.drawRect(
        Rect.fromLTWH(left, top, wide + 0.5, metrics.space.height - top),
        paint,
      );
    }
  }

  void _paintSky(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Palette.sky, Palette.skyLow],
        ).createShader(Offset.zero & size),
    );
  }

  void _paintGround(Canvas canvas) {
    final run = journey.run;
    final ground = run.ground;
    final from = (run.x - metrics.runnerAt / metrics.tile).floor() - 1;

    final solid = Paint()..color = Palette.ground;
    final edge = Paint()..color = Palette.edge;
    final spike = Paint()..color = Palette.spike;

    for (var at = from; at < from + metrics.across; at++) {
      if (at < 0) continue;
      final tile = ground.at(at);
      if (tile.isPit) continue;

      final left = metrics.screenX(at.toDouble(), run.x);
      final top = metrics.screenY(tile.top.toDouble());

      canvas.drawRect(
        Rect.fromLTWH(left, top, metrics.tile + 0.5, metrics.space.height - top),
        solid,
      );
      // A lit line along the top, so a step reads as a step.
      canvas.drawRect(
        Rect.fromLTWH(left, top, metrics.tile + 0.5, metrics.tile * 0.06),
        edge,
      );

      if (!tile.spiked) continue;
      final middle = left + metrics.tile / 2;
      canvas.drawPath(
        Path()
          ..moveTo(middle, top - metrics.tile * 0.62)
          ..lineTo(left + metrics.tile * 0.92, top)
          ..lineTo(left + metrics.tile * 0.08, top)
          ..close(),
        spike,
      );
    }
  }

  void _paintRunner(Canvas canvas) {
    final run = journey.run;
    final side = metrics.tile * 0.62;
    final box = Rect.fromLTWH(
      metrics.runnerAt - side / 2,
      metrics.screenY(run.y) - side,
      side,
      side,
    );

    // A lean forwards while in the air, which is the only animation there is
    // and the only one worth having: it says at a glance whether the runner is
    // on the ground.
    canvas.save();
    canvas.translate(box.center.dx, box.center.dy);
    canvas.rotate(run.onGround ? 0 : 0.28);
    canvas.translate(-box.center.dx, -box.center.dy);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        box.translate(0, side * 0.06),
        Radius.circular(side * 0.24),
      ),
      Paint()..color = Palette.runnerDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(side * 0.24)),
      Paint()..color = Palette.runner,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(WorldPainter old) => true;
}
