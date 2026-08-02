import 'dart:math';

/// A point in the world. Metres, not pixels: the view decides how big a metre
/// is on a given screen, and the simulation never knows.
class Vec {
  const Vec(this.x, this.y);

  static const zero = Vec(0, 0);

  final double x;
  final double y;

  Vec operator +(Vec o) => Vec(x + o.x, y + o.y);
  Vec operator -(Vec o) => Vec(x - o.x, y - o.y);
  Vec operator *(double k) => Vec(x * k, y * k);

  double get lengthSquared => x * x + y * y;
  double get length => sqrt(lengthSquared);

  Vec get normalised {
    final l = length;
    return l == 0 ? zero : Vec(x / l, y / l);
  }

  /// Turned a quarter anticlockwise, which is the direction a body travels
  /// when it is held in a circle to its left.
  Vec get perpendicular => Vec(-y, x);

  @override
  String toString() => '(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)})';
}

/// Something the craft can be caught by.
class Well {
  const Well({required this.at, required this.radius, this.collected = false});

  final Vec at;

  /// How close the craft must come to be caught. Also how big it looks.
  final double radius;

  /// Whether the craft has already used this one. A used well still holds,
  /// it just stops being worth points.
  final bool collected;

  Well get taken => Well(at: at, radius: radius, collected: true);
}

/// Why a run ended, which the view turns into something to read.
enum Ending {
  /// Still going.
  none,

  /// Left the playfield sideways or off the bottom with nothing holding it.
  adrift,

  /// Hit the core of a well rather than orbiting it.
  crashed,
}

/// One run of the game, advanced a fixed step at a time.
///
/// Nothing here knows about frames, clocks or screens. A run is a pure
/// function of its seed and the steps on which the player tapped, which is
/// what makes a replay exact and a test meaningful: the same seed and the same
/// taps give the same run on any machine, every time.
class World {
  World._({
    required this.seed,
    required this.craft,
    required this.velocity,
    required this.wells,
    required this.heldBy,
    required this.steps,
    required this.score,
    required this.ending,
    required this.cameraY,
    required this.ignoring,
  });

  /// A fresh run. The craft starts held by the first well, so a player who
  /// taps immediately gets a sensible launch rather than falling out of the
  /// world.
  factory World.newRun({required int seed}) {
    final wells = _wellsUpTo(seed, _wellsAhead);
    return World._(
      seed: seed,
      craft: wells.first.at + const Vec(_tether, 0),
      // The craft is already going round, so it already has the speed it
      // would leave with. Starting it at rest means a player who taps on the
      // first frame launches at nothing and hangs there, which is a hard way
      // to learn that the game wants you to wait.
      velocity: const Vec(1, 0).perpendicular * launchSpeed,
      wells: wells,
      heldBy: 0,
      steps: 0,
      score: 0,
      ending: Ending.none,
      cameraY: 0,
      ignoring: null,
    );
  }

  /// Seconds of world time each step covers. Fixed on purpose: a simulation
  /// that advances by however long the last frame took is a simulation whose
  /// answers depend on the machine it ran on.
  static const stepSeconds = 1 / 120;

  /// How many wells are worked out in advance. The world is endless, so this
  /// is only how far ahead it is drawn, and more appear as the craft climbs.
  static const _wellsAhead = 24;
  static const _gapY = 5.2;
  static const _gapYJitter = 2.4;
  static const _gapX = 3.1;

  /// How far from a well's centre the craft rides when held.
  static const _tether = 2.0;

  /// How fast the craft goes round a well it is held by, in radians a second.
  static const _spin = 2.1;

  /// Speed the craft leaves at, in metres a second.
  ///
  /// Chosen against the gravity and the spacing rather than by feel. A throw
  /// carries about speed squared over gravity, so this reaches roughly
  /// sixteen metres where wells sit eight to ten apart: comfortably far
  /// enough that a good release arrives, and not so far that a poor one does.
  static const launchSpeed = 13.5;

  /// How far to either side the craft may drift before the run ends.
  static const _edgeX = 7.0;

  /// Downward pull on a craft that is not being held, in metres a second
  /// squared.
  ///
  /// This is what makes the game a game. Without it a launch is a straight
  /// line, every release reaches something, and tapping as fast as possible
  /// is a winning strategy. With it a launch is an arc that falls short if it
  /// is thrown too early or too late, so the question the player answers is
  /// when to let go.
  static const gravity = 11.0;

  final int seed;
  final Vec craft;
  final Vec velocity;
  final List<Well> wells;

  /// The well currently holding the craft, or null when it is flying.
  final int? heldBy;

  final int steps;
  final int score;
  final Ending ending;

  /// How far the view has followed the craft up the world.
  final double cameraY;

  /// A well that may not catch the craft yet.
  ///
  /// The craft leaves a well from inside that well's own catching band, so
  /// without this it is caught again on the very next step and can never get
  /// away. The well starts holding again once the craft is properly clear of
  /// it, which is also the moment a player would say it had escaped.
  final int? ignoring;

  /// The first [count] wells of a run.
  ///
  /// Each well is a function of the seed and its own number rather than of
  /// the ones before it, so however far a player gets, the world they see is
  /// the world that seed always had. That is what lets a run be reproduced
  /// from a seed and a list of taps without recording anything else.
  static List<Well> _wellsUpTo(int seed, int count) {
    final wells = <Well>[const Well(at: Vec(0, 0), radius: 1.1)];
    var y = 0.0;
    for (var i = 1; i < count; i++) {
      final random = Random(seed * 7919 + i);
      y += _gapY + random.nextDouble() * _gapYJitter;
      final side = i.isEven ? 1.0 : -1.0;
      final x = side * (_gapX * (0.55 + random.nextDouble() * 0.45));
      wells.add(Well(at: Vec(x, y), radius: 0.9 + random.nextDouble() * 0.5));
    }
    return wells;
  }

  /// The same wells, with any already used kept used, extended far enough
  /// ahead of the craft that a player can never reach the end of the world.
  List<Well> _extended() {
    if (wells.last.at.y > craft.y + _gapY * 8) return wells;
    final grown = _wellsUpTo(seed, wells.length + 8);
    for (var i = 0; i < wells.length; i++) {
      if (wells[i].collected) grown[i] = grown[i].taken;
    }
    return grown;
  }

  bool get isOver => ending != Ending.none;
  bool get isHeld => heldBy != null;

  double get seconds => steps * stepSeconds;

  /// The run after one step, with [tapped] saying whether the player let go
  /// during it.
  ///
  /// Letting go while flying does nothing, which is deliberate: the game is
  /// about when to release, so a stray tap in the air must not be punished or
  /// rewarded.
  World step({bool tapped = false}) {
    if (isOver) return this;

    final ahead = _extended();
    if (!identical(ahead, wells)) {
      return _copy(wells: ahead).step(tapped: tapped);
    }

    if (isHeld) {
      return tapped ? _release() : _swing();
    }
    return _fly();
  }

  /// One step of riding round the well that holds the craft.
  World _swing() {
    final well = wells[heldBy!];
    final out = craft - well.at;
    final angle = atan2(out.y, out.x) + _spin * stepSeconds;
    final next = well.at + Vec(cos(angle), sin(angle)) * _tether;
    return _copy(
      craft: next,
      // The velocity it would leave with, kept up to date so releasing is
      // just a matter of stopping holding on.
      velocity: Vec(cos(angle), sin(angle)).perpendicular * launchSpeed,
      steps: steps + 1,
      cameraY: max(cameraY, next.y),
    );
  }

  /// Stop holding on, and start flying at the speed the swing had built.
  World _release() => _copy(
        heldBy: null,
        clearHeld: true,
        ignoring: heldBy,
        steps: steps + 1,
      );

  /// One step of flight: travel, then see what happened.
  World _fly() {
    final pulled = velocity + const Vec(0, -gravity) * stepSeconds;
    final next = craft + pulled * stepSeconds;

    if (next.x.abs() > _edgeX) {
      return _copy(
        craft: next,
        velocity: pulled,
        steps: steps + 1,
        ending: Ending.adrift,
      );
    }
    // Falling back below where the view has followed to means the run is
    // over, which is what stops a player drifting downwards forever.
    if (next.y < cameraY - _fallBehind) {
      return _copy(
        craft: next,
        velocity: pulled,
        steps: steps + 1,
        ending: Ending.adrift,
      );
    }

    // Once the craft is clear of the well it left, that well can hold it
    // again, so a player can come back round to one they have used.
    var stillIgnoring = ignoring;
    if (stillIgnoring != null) {
      final left = wells[stillIgnoring];
      if ((next - left.at).length > left.radius + _catchBand + _escapeBand) {
        stillIgnoring = null;
      }
    }

    for (var i = 0; i < wells.length; i++) {
      if (i == stillIgnoring) continue;
      final well = wells[i];
      final gap = (next - well.at).length;
      if (gap > well.radius + _catchBand) continue;
      if (gap < well.radius * _coreShare) {
        return _copy(
          craft: next,
          velocity: pulled,
          steps: steps + 1,
          ending: Ending.crashed,
        );
      }
      // Caught. The craft snaps to the tether distance so every swing looks
      // and behaves the same whatever angle it arrived at.
      final out = (next - well.at).normalised;
      final held = well.at + out * _tether;
      final taken = List<Well>.from(wells);
      final scored = well.collected ? 0 : 1;
      taken[i] = well.taken;
      return _copy(
        craft: held,
        wells: taken,
        heldBy: i,
        steps: steps + 1,
        score: score + scored,
        cameraY: max(cameraY, held.y),
        ignoring: null,
        clearIgnoring: true,
      );
    }

    return _copy(
      craft: next,
      velocity: pulled,
      steps: steps + 1,
      cameraY: max(cameraY, next.y),
      ignoring: stillIgnoring,
      clearIgnoring: stillIgnoring == null,
    );
  }

  /// How much further than the catching band the craft must get before the
  /// well it left will hold it again.
  static const _escapeBand = 0.6;

  /// How far outside its radius a well still catches the craft.
  static const _catchBand = 1.35;

  /// The share of a well's radius that is solid rather than catching.
  static const _coreShare = 0.42;

  /// How far below the camera the craft may fall before the run ends.
  static const _fallBehind = 9.0;

  World _copy({
    Vec? craft,
    Vec? velocity,
    List<Well>? wells,
    int? heldBy,
    bool clearHeld = false,
    int? steps,
    int? score,
    Ending? ending,
    double? cameraY,
    int? ignoring,
    bool clearIgnoring = false,
  }) =>
      World._(
        seed: seed,
        craft: craft ?? this.craft,
        velocity: velocity ?? this.velocity,
        wells: wells ?? this.wells,
        heldBy: clearHeld ? null : (heldBy ?? this.heldBy),
        steps: steps ?? this.steps,
        score: score ?? this.score,
        ending: ending ?? this.ending,
        cameraY: cameraY ?? this.cameraY,
        ignoring: clearIgnoring ? null : (ignoring ?? this.ignoring),
      );
}
