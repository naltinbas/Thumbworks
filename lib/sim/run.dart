import 'field.dart';
import 'kinds.dart';
import 'waves.dart';

/// Something walking down the lane.
class Walking {
  const Walking({
    required this.id,
    required this.kind,
    required this.along,
    required this.life,
    required this.slowedFor,
  });

  final int id;
  final Walker kind;

  /// How far down the path it has got, in cells.
  final double along;

  final int life;

  /// Seconds of slowing left on it.
  final double slowedFor;

  Spot get at => Field.only.at(along);
  bool get isDown => life <= 0;
  bool get isOut => along >= Field.only.length;

  /// How much of its life is left, for the bar over its head.
  double get share => life / kind.life;

  Walking copyWith({double? along, int? life, double? slowedFor}) => Walking(
        id: id,
        kind: kind,
        along: along ?? this.along,
        life: life ?? this.life,
        slowedFor: slowedFor ?? this.slowedFor,
      );
}

/// Something built.
class Built {
  const Built({
    required this.kind,
    required this.on,
    required this.level,
    required this.since,
    this.aimedAt,
  });

  final Tower kind;
  final Cell on;

  /// One or two. Two is as far as it goes.
  final int level;

  /// Seconds since it last shot.
  final double since;

  /// What it shot at last, for the line the view draws. Not part of the
  /// simulation: nothing reads it back.
  final int? aimedAt;

  double get reach => level > 1 ? kind.upgradedReach : kind.reach;
  int get hits => level > 1 ? kind.upgradedHits : kind.hits;
  bool get canUpgrade => level < 2;
  int get upgradeCost => kind.upgradeCost;

  /// What selling it gives back: two thirds of everything put in, so a tower
  /// in the wrong place is a mistake worth undoing rather than one to live
  /// with.
  int get sellsFor =>
      ((kind.cost + (level > 1 ? kind.upgradeCost : 0)) * 2 ~/ 3);

  Spot get at => Spot(on.col + 0.5, on.row + 0.5);

  Built copyWith({int? level, double? since, int? aimedAt, bool clearAim = false}) =>
      Built(
        kind: kind,
        on: on,
        level: level ?? this.level,
        since: since ?? this.since,
        aimedAt: clearAim ? null : (aimedAt ?? this.aimedAt),
      );
}

/// A shot, for the view to draw. It lives one step and is gone.
class Shot {
  const Shot(this.from, this.to, this.kind);

  final Spot from;
  final Spot to;
  final Tower kind;
}

/// How a run ended.
enum Ending {
  /// Still going.
  none,

  /// Every wave held.
  held,

  /// The keep fell.
  fell,
}

/// One run of the game, advanced a fixed step at a time.
///
/// Nothing here knows about frames, clocks or screens. A run is a pure
/// function of the towers that were built and the step each was built on, so
/// the same decisions give the same run on any machine every time — which is
/// what makes a balance sweep worth anything and a test able to say a wave is
/// beatable rather than usually beatable.
///
/// There is no randomness at all. A defence game with a random spread on its
/// damage is a game where the same plan wins and loses, and a player cannot
/// tell a bad plan from bad luck.
class Run {
  const Run._({
    required this.steps,
    required this.wave,
    required this.waveStarted,
    required this.sent,
    required this.walking,
    required this.built,
    required this.embers,
    required this.keep,
    required this.ending,
    required this.nextId,
    required this.shots,
    required this.waiting,
  });

  /// A run about to begin.
  ///
  /// The three arguments are starting conditions rather than a way in for a
  /// cheat: a test that is about how a frost tower behaves should not have to
  /// play eight waves to afford one, and tuning a single late wave means
  /// starting at it. Nothing in the game passes anything but the defaults.
  factory Run.fresh({
    int embers = startingEmbers,
    int keep = startingKeep,
    int wave = 0,
  }) =>
      Run._(
        steps: 0,
        wave: wave,
        waveStarted: 0,
        sent: const <int>[],
        walking: const <Walking>[],
        built: const <Built>[],
        embers: embers,
        keep: keep,
        ending: Ending.none,
        nextId: 0,
        shots: const <Shot>[],
        waiting: true,
      );

  /// Seconds a step covers. Fixed on purpose: a simulation that advances by
  /// however long the last frame took is a simulation whose answers depend on
  /// the machine it ran on, and this one is asked the same question a hundred
  /// thousand times by tool/dryrun.dart.
  static const stepSeconds = 1 / 60;

  /// Enough for a Spark and a bit, so the first decision is a real one.
  static const startingEmbers = 60;

  /// How many walkers may get out before the keep falls.
  static const startingKeep = 20;

  final int steps;

  /// Which wave is on, counting from zero. Equal to [Waves.count] when they
  /// have all been sent.
  final int wave;

  /// The step the wave began on.
  final int waveStarted;

  /// How many of each group have been sent so far this wave.
  final List<int> sent;

  final List<Walking> walking;
  final List<Built> built;
  final int embers;

  /// What is left of the keep.
  final int keep;

  final Ending ending;
  final int nextId;

  /// Shots fired on the last step, for the view. Not read by the simulation.
  final List<Shot> shots;

  /// Whether the next wave is waiting to be called. Waves do not start
  /// themselves: a player who has just spent everything wants to place it
  /// before the next lot arrives, and a countdown they cannot stop turns
  /// building into a scramble.
  final bool waiting;

  bool get isOver => ending != Ending.none;
  double get seconds => steps * stepSeconds;

  /// The wave about to be called, or null if they have all been.
  Wave? get nextWave => wave < Waves.count ? Waves.all[wave] : null;

  Built? towerOn(Cell cell) {
    for (final tower in built) {
      if (tower.on == cell) return tower;
    }
    return null;
  }

  /// Whether a tower can go here.
  bool canBuildOn(Cell cell) =>
      Field.only.canBuildOn(cell) && towerOn(cell) == null;

  /// This run with a tower built, or this run if it cannot be.
  Run build(Tower kind, Cell cell) {
    if (isOver || !canBuildOn(cell) || embers < kind.cost) return this;
    return _copy(
      built: [...built, Built(kind: kind, on: cell, level: 1, since: 0)],
      embers: embers - kind.cost,
    );
  }

  Run upgrade(Cell cell) {
    final tower = towerOn(cell);
    if (isOver || tower == null || !tower.canUpgrade) return this;
    if (embers < tower.upgradeCost) return this;
    return _copy(
      built: [
        for (final one in built)
          if (one.on == cell) one.copyWith(level: one.level + 1) else one,
      ],
      embers: embers - tower.upgradeCost,
    );
  }

  Run sell(Cell cell) {
    final tower = towerOn(cell);
    if (isOver || tower == null) return this;
    return _copy(
      built: [
        for (final one in built)
          if (one.on != cell) one,
      ],
      embers: embers + tower.sellsFor,
    );
  }

  /// Call the wave that is waiting.
  Run callWave() {
    if (isOver || !waiting || wave >= Waves.count) return this;
    return _copy(
      waiting: false,
      waveStarted: steps,
      sent: List<int>.filled(Waves.all[wave].groups.length, 0),
    );
  }

  /// The run one step later.
  Run step() {
    if (isOver) return this;

    var run = _send();
    run = run._shoot();
    run = run._walk();
    return run._settle();
  }

  /// Lets out whatever the wave says is due by now.
  Run _send() {
    if (waiting || wave >= Waves.count) return this;
    final on = Waves.all[wave];
    final since = (steps - waveStarted) * stepSeconds;

    final coming = <Walking>[];
    final counted = List<int>.from(sent);
    var id = nextId;

    for (var i = 0; i < on.groups.length; i++) {
      final group = on.groups[i];
      while (counted[i] < group.count &&
          since >= group.after + group.every * counted[i]) {
        coming.add(Walking(
          id: id++,
          kind: group.walker,
          along: 0,
          life: group.walker.life,
          slowedFor: 0,
        ));
        counted[i]++;
      }
    }

    if (coming.isEmpty) return this;
    return _copy(
      walking: [...walking, ...coming],
      sent: counted,
      nextId: id,
    );
  }

  /// Every tower that is ready picks a target and fires.
  ///
  /// The target is whichever walker in reach is furthest down the path. That
  /// is the one about to get out, so it is the one worth shooting, and it is
  /// the rule a player would follow if they were aiming by hand — which
  /// matters more than any cleverer rule, because a tower that seems to shoot
  /// at random reads as broken.
  Run _shoot() {
    final hurt = <int, int>{};
    final slowed = <int, double>{};
    final fired = <Shot>[];
    final after = <Built>[];

    for (final tower in built) {
      final since = tower.since + stepSeconds;
      if (since < tower.kind.every) {
        after.add(tower.copyWith(since: since, clearAim: true));
        continue;
      }

      Walking? target;
      for (final walker in walking) {
        if (walker.isDown) continue;
        final gap = (walker.at - tower.at).length;
        if (gap > tower.reach) continue;
        if (target == null || walker.along > target.along) target = walker;
      }

      if (target == null) {
        // Kept at the ready rather than reset, so a tower that has been
        // waiting fires the instant something comes into reach instead of
        // starting its wind-up then.
        after.add(tower.copyWith(since: tower.kind.every, clearAim: true));
        continue;
      }

      final shrugged = (tower.hits * (1 - target.kind.shrugs)).round();
      hurt[target.id] = (hurt[target.id] ?? 0) + shrugged;
      if (tower.kind.slows > 0) {
        slowed[target.id] = tower.kind.slowsFor;
      }
      fired.add(Shot(tower.at, target.at, tower.kind));
      after.add(tower.copyWith(since: 0, aimedAt: target.id));
    }

    if (hurt.isEmpty && fired.isEmpty) {
      return _copy(built: after, shots: const []);
    }

    return _copy(
      built: after,
      shots: fired,
      walking: [
        for (final walker in walking)
          walker.copyWith(
            life: walker.life - (hurt[walker.id] ?? 0),
            slowedFor: slowed[walker.id] ?? walker.slowedFor,
          ),
      ],
    );
  }

  /// Everything still standing moves.
  Run _walk() => _copy(
        walking: [
          for (final walker in walking)
            if (walker.isDown)
              walker
            else
              walker.copyWith(
                along: walker.along +
                    walker.kind.pace *
                        (walker.slowedFor > 0 ? _slowedTo : 1) *
                        stepSeconds,
                slowedFor: walker.slowedFor > 0
                    ? walker.slowedFor - stepSeconds
                    : 0,
              ),
        ],
      );

  /// What a slowed walker's pace becomes. One number rather than one per
  /// tower, because two frost towers stacking to a standstill is a lane that
  /// never has to be thought about again.
  static const _slowedTo = 0.5;

  /// Clears away whatever is finished, pays for it, and sees where that
  /// leaves things.
  Run _settle() {
    var embers = this.embers;
    var keep = this.keep;
    final left = <Walking>[];

    for (final walker in walking) {
      if (walker.isDown) {
        embers += walker.kind.worth;
        continue;
      }
      if (walker.isOut) {
        keep -= walker.kind.costs;
        continue;
      }
      left.add(walker);
    }

    var wave = this.wave;
    var waiting = this.waiting;
    if (!waiting && left.isEmpty && _allSent) {
      // The wave is done. Pay for it and wait for the next to be called.
      embers += Waves.all[wave].pays;
      wave++;
      waiting = true;
    }

    final ending = keep <= 0
        ? Ending.fell
        : (wave >= Waves.count && waiting)
            ? Ending.held
            : Ending.none;

    return _copy(
      steps: steps + 1,
      walking: left,
      embers: embers,
      keep: keep < 0 ? 0 : keep,
      wave: wave,
      waiting: waiting,
      ending: ending,
    );
  }

  bool get _allSent {
    if (wave >= Waves.count) return true;
    final groups = Waves.all[wave].groups;
    for (var i = 0; i < groups.length; i++) {
      if (sent.length <= i || sent[i] < groups[i].count) return false;
    }
    return true;
  }

  Run _copy({
    int? steps,
    int? wave,
    int? waveStarted,
    List<int>? sent,
    List<Walking>? walking,
    List<Built>? built,
    int? embers,
    int? keep,
    Ending? ending,
    int? nextId,
    List<Shot>? shots,
    bool? waiting,
  }) =>
      Run._(
        steps: steps ?? this.steps,
        wave: wave ?? this.wave,
        waveStarted: waveStarted ?? this.waveStarted,
        sent: sent ?? this.sent,
        walking: walking ?? this.walking,
        built: built ?? this.built,
        embers: embers ?? this.embers,
        keep: keep ?? this.keep,
        ending: ending ?? this.ending,
        nextId: nextId ?? this.nextId,
        shots: shots ?? this.shots,
        waiting: waiting ?? this.waiting,
      );
}
