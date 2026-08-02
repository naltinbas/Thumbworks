import 'dart:math';

import 'shapes.dart';

/// How a run ended.
enum Ending {
  /// Still going.
  none,

  /// The ball reached the ring.
  home,

  /// It touched something sharp.
  stuck,

  /// It went off the edge of the world.
  lost,

  /// It stopped moving somewhere that is not the ring.
  settled,

  /// It went on far too long.
  gaveUp,
}

/// One attempt: a ball, everything solid, and gravity.
///
/// Immutable and advanced a fixed step at a time. Nothing here knows about
/// frames, clocks or screens, and nothing in it is random — so the same drawing
/// gives the same run on any phone, which is what lets a level ship with a
/// drawing that solves it and a test that watches it happen.
class World {
  const World._({
    required this.solid,
    required this.goal,
    required this.spikes,
    required this.ball,
    required this.speed,
    required this.steps,
    required this.still,
    required this.ending,
  });

  factory World.of({
    required List<Line> solid,
    required Blob goal,
    required List<Blob> spikes,
    required Spot from,
  }) =>
      World._(
        solid: List.unmodifiable(solid),
        goal: goal,
        spikes: List.unmodifiable(spikes),
        ball: from,
        speed: Spot.zero,
        steps: 0,
        still: 0,
        ending: Ending.none,
      );

  /// How wide and tall the world is, in units. A phone is about this shape.
  static const across = 10.0;
  static const down = 20.0;

  static const ballRadius = 0.30;

  /// Seconds a step covers.
  ///
  /// A two hundred and fortieth rather than a sixtieth, and that is not
  /// fussiness. Collision here is the plain kind — move, then look for
  /// overlaps — which is only safe while the ball cannot cross something thin
  /// in a single step. At this step and the speed cap below, the ball moves at
  /// most a sixth of its own radius at a time, so there is nothing for it to
  /// pass through. The alternative is sweeping every move against every line,
  /// which is the same answer for ten times the code.
  static const stepSeconds = 1 / 240;

  static const gravity = 22.0;

  /// The fastest the ball may go, in units a second.
  ///
  /// The cap is what makes the paragraph above true. It is also kinder than it
  /// sounds: a ball dropped the whole height of the world reaches about
  /// twenty nine, so this only bites on the longest falls.
  static const topSpeed = 14.0;

  /// How much of the speed into a surface comes back out of it.
  ///
  /// Low. A chalk line is not a trampoline, and a bouncy ball turns every
  /// level into a lottery.
  static const bounce = 0.16;

  /// How much of the speed along a surface is lost to it each step.
  static const drag = 0.006;

  final List<Line> solid;
  final Blob goal;
  final List<Blob> spikes;

  final Spot ball;
  final Spot speed;
  final int steps;

  /// Steps spent barely moving. Enough of them and the run is over.
  final int still;

  final Ending ending;

  bool get isOver => ending != Ending.none;
  double get seconds => steps * stepSeconds;

  /// How slow counts as stopped, and for how long.
  static const _crawl = 0.35;
  static const _stillFor = 240;

  /// How long a run may last before it is called off.
  static const _mostSteps = 240 * 30;

  /// The world one step later.
  World step() {
    if (isOver) return this;

    var speed = this.speed + const Spot(0, gravity) * stepSeconds;
    if (speed.length > topSpeed) speed = speed.unit * topSpeed;

    var ball = this.ball + speed * stepSeconds;

    // Push out of anything solid, twice, because pushing out of one line can
    // push into another — a corner is two lines and one ball.
    for (var pass = 0; pass < 2; pass++) {
      for (final line in solid) {
        final near = line.nearestTo(ball);
        final out = ball - near;
        final gap = out.length;
        if (gap >= ballRadius) continue;

        // Straight out of the line. When the ball is exactly on it — which
        // happens on the first frame of a level drawn through the start —
        // there is no direction to push, so up is as good as any.
        final way = gap == 0 ? const Spot(0, -1) : out.unit;
        ball = near + way * ballRadius;

        final into = speed.dot(way);
        if (into < 0) {
          final along = speed - way * into;
          speed = along * (1 - drag) + way * (-into * bounce);
        }
      }
    }

    final still = speed.length < _crawl ? this.still + 1 : 0;

    return World._(
      solid: solid,
      goal: goal,
      spikes: spikes,
      ball: ball,
      speed: speed,
      steps: steps + 1,
      still: still,
      ending: _endingFor(ball, still),
    );
  }

  Ending _endingFor(Spot ball, int still) {
    // In the ring: the middle of the ball inside the circle. Touching the rim
    // is not in — a ball that clips the edge of the ring on its way past has
    // not gone in it, and ending the run there would look like a bad call.
    if (goal.holds(ball)) return Ending.home;
    for (final spike in spikes) {
      if (spike.touches(ball, ballRadius)) return Ending.stuck;
    }
    // Off the sides or out of the bottom. There is no ceiling: a ball thrown
    // upwards comes back.
    if (ball.x < -1 || ball.x > across + 1 || ball.y > down + 2) {
      return Ending.lost;
    }
    if (still >= _stillFor) return Ending.settled;
    if (steps >= _mostSteps) return Ending.gaveUp;
    return Ending.none;
  }

  /// The whole run, played out.
  World get played {
    var world = this;
    while (!world.isOver) {
      world = world.step();
    }
    return world;
  }

  /// The path the ball takes, for a picture of a run.
  List<Spot> trail({int every = 8}) {
    final spots = <Spot>[ball];
    var world = this;
    while (!world.isOver) {
      world = world.step();
      if (world.steps % every == 0) spots.add(world.ball);
    }
    spots.add(world.ball);
    return spots;
  }

  /// How far the ball fell, which is the only number a run has.
  double get fell => max(0, ball.y);
}
