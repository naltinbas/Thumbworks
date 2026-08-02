import 'ground.dart';

/// How a run ended.
enum Ending {
  /// Still going.
  none,

  /// Fell into a pit.
  fell,

  /// Ran into the side of a step.
  hit,

  /// Landed on a spike.
  spiked,

  /// Reached the end of the stretch. Only a verified stretch ever does; the
  /// game itself is endless.
  through,
}

/// One run, advanced a fixed step at a time.
///
/// Nothing here knows about frames, clocks or screens, and there is no
/// randomness in it at all. A run is a pure function of the stretch and the
/// steps on which the button was held — which is what lets the verifier search
/// over button presses and be talking about the same game the player is
/// playing.
class Run {
  const Run._({
    required this.ground,
    required this.steps,
    required this.x,
    required this.y,
    required this.rise,
    required this.held,
    required this.ending,
  });

  factory Run.on(Ground ground) => Run._(
        ground: ground,
        steps: 0,
        x: 0.5,
        y: 0,
        rise: 0,
        held: 0,
        ending: Ending.none,
      );

  /// Seconds a step covers. Fixed on purpose: a runner that advances by
  /// however long the last frame took is a runner whose jumps clear a gap on
  /// one phone and not on another.
  static const stepSeconds = 1 / 120;

  /// Tiles a second, forwards. Constant — the only thing the player controls
  /// is when to leave the ground.
  ///
  /// Seven and a half is not a feel, it is arithmetic: at a hundred and twenty
  /// steps a second it is exactly a sixteenth of a tile a step. That makes
  /// [stepsPerTile] a whole number, which is what makes joining one proved
  /// stretch to the next exact rather than nearly right.
  ///
  /// With any other pace the runner enters each stretch at a different point
  /// within a tile, so the presses that proved that stretch land a fraction of
  /// a tile early or late, and a tight jump that was proved becomes a jump
  /// that usually works. That is not a promise worth making.
  static const pace = 7.5;

  /// How many steps it takes to cross one tile. Exactly sixteen.
  static const stepsPerTile = 16;

  /// Downward pull, in tiles a second squared.
  static const gravity = 62.0;

  /// The push a jump starts with, in tiles a second.
  static const leap = 15.5;

  /// The extra push each step the button is still held, and for how many
  /// steps it lasts.
  ///
  /// This is what makes the button worth more than one bit. A tap clears a two
  /// tile gap and a hold clears a four tile one, so the same button asks a
  /// different question every time.
  static const lift = 62.0;
  static const liftSteps = 14;

  /// How far above the ground counts as standing on it.
  static const _touching = 0.02;

  final Ground ground;
  final int steps;

  /// Where the runner is, in tiles. [y] is the feet.
  final double x;
  final double y;

  /// Upward speed, in tiles a second.
  final double rise;

  /// How many steps the button has been held for, this jump.
  final int held;

  final Ending ending;

  bool get isOver => ending != Ending.none;
  double get seconds => steps * stepSeconds;

  int get column => x.floor();

  /// Whether the runner is standing on something.
  bool get onGround {
    final under = ground.at(column);
    if (under.isPit) return false;
    return rise <= 0 && (y - under.top).abs() <= _touching;
  }

  /// The run one step on, with the button [holding] or not.
  Run step({bool holding = false}) {
    if (isOver) return this;

    var rise = this.rise;
    var held = this.held;

    if (onGround) {
      // A press only starts a jump from the ground. Holding the button in the
      // air does nothing at all, which is what stops a player mashing it.
      if (holding) {
        rise = leap;
        held = 1;
      } else {
        rise = 0;
        held = 0;
      }
    } else if (holding && held > 0 && held < liftSteps) {
      rise += lift * stepSeconds;
      held += 1;
    } else if (held > 0) {
      // Let go, and that is the end of the extra push for this jump: pressing
      // again halfway up would be a second jump, which this game does not
      // have.
      held = holding ? held : 0;
    }

    rise -= gravity * stepSeconds;

    final nextX = x + pace * stepSeconds;
    var nextY = y + rise * stepSeconds;

    final was = ground.at(column);
    final now = ground.at(nextX.floor());

    // Into the side of a step: the runner was below its top and has arrived
    // at it going forwards.
    if (!now.isPit && y < now.top - _touching && now.top > was.top) {
      return _copy(x: nextX, y: nextY, rise: rise, held: held, ending: Ending.hit);
    }

    if (now.isPit) {
      if (nextY <= -3) {
        return _copy(
          x: nextX,
          y: nextY,
          rise: rise,
          held: held,
          ending: Ending.fell,
        );
      }
    } else if (nextY <= now.top) {
      // Landed.
      if (now.spiked) {
        return _copy(
          x: nextX,
          y: now.top.toDouble(),
          rise: 0,
          held: 0,
          ending: Ending.spiked,
        );
      }
      nextY = now.top.toDouble();
      rise = 0;
    }

    if (nextX >= ground.length) {
      return _copy(
        x: nextX,
        y: nextY,
        rise: rise,
        held: held,
        ending: Ending.through,
      );
    }

    return _copy(x: nextX, y: nextY, rise: rise, held: held);
  }

  /// The same run, on more ground.
  ///
  /// The world is made by joining stretches on ahead of the runner, and the
  /// runner does not notice: the ground under and behind is unchanged, so this
  /// is the same run with more of the world worked out.
  Run onMore(Ground more) => Run._(
        ground: more,
        steps: steps,
        x: x,
        y: y,
        rise: rise,
        held: held,
        ending: ending,
      );

  Run _copy({
    required double x,
    required double y,
    required double rise,
    required int held,
    Ending? ending,
  }) =>
      Run._(
        ground: ground,
        steps: steps + 1,
        x: x,
        y: y,
        rise: rise,
        held: held,
        ending: ending ?? this.ending,
      );
}
