import 'package:flutter_test/flutter_test.dart';
import 'package:emberlane/sim/field.dart';
import 'package:emberlane/sim/kinds.dart';
import 'package:emberlane/sim/plan.dart';
import 'package:emberlane/sim/run.dart';
import 'package:emberlane/sim/waves.dart';

/// Steps a run on until [until] says stop, or it runs out of patience.
Run runOn(Run run, bool Function(Run) until, {int most = 60000}) {
  var at = run;
  for (var i = 0; i < most; i++) {
    if (until(at)) return at;
    at = at.step();
  }
  return at;
}

/// The same, but calling every wave as it comes up, which is what a player
/// does and what a run needs to get anywhere.
Run runThrough(Run run, bool Function(Run) until, {int most = 400000}) {
  var at = run;
  for (var i = 0; i < most; i++) {
    if (until(at)) return at;
    at = at.waiting ? at.callWave() : at.step();
    if (at.waiting && at.nextWave == null) return at;
  }
  return at;
}

void main() {
  group('the field', () {
    test('is one unbroken path with no diagonals in it', () {
      final path = Field.only.path;
      expect(path.length, greaterThan(20));
      for (var i = 1; i < path.length; i++) {
        final gap = (path[i].col - path[i - 1].col).abs() +
            (path[i].row - path[i - 1].row).abs();
        expect(gap, 1, reason: 'between ${path[i - 1]} and ${path[i]}');
      }
      expect(path.toSet(), hasLength(path.length),
          reason: 'it never crosses itself');
    });

    test('comes in at the top and leaves at the bottom', () {
      expect(Field.only.entrance.row, 0);
      expect(Field.only.exit.row, Field.rows - 1);
    });

    test('nothing may be built on the path', () {
      for (final cell in Field.only.path) {
        expect(Field.only.canBuildOn(cell), isFalse, reason: '$cell');
      }
      expect(Field.only.canBuildOn(const Cell(0, 0)), isTrue);
      expect(Field.only.canBuildOn(const Cell(-1, 0)), isFalse);
    });

    test('a walker slides between the middles of cells', () {
      final start = Field.only.at(0);
      final half = Field.only.at(0.5);
      final one = Field.only.at(1);
      expect(start.x, Field.only.path.first.col + 0.5);
      expect(half.y, closeTo((start.y + one.y) / 2, 1e-9));
      expect(Field.only.at(9999).x, Field.only.exit.col + 0.5,
          reason: 'past the end it stays at the end');
    });
  });

  group('building', () {
    test('costs embers and refuses what cannot be paid for', () {
      final run = Run.fresh();
      expect(run.embers, Run.startingEmbers);

      final after = run.build(Tower.spark, const Cell(0, 0));
      expect(after.built, hasLength(1));
      expect(after.embers, Run.startingEmbers - Tower.spark.cost);

      // A forge costs more than the game starts with.
      expect(run.build(Tower.forge, const Cell(0, 0)).built, isEmpty);
    });

    test('refuses the path and squares already taken', () {
      final run = Run.fresh();
      expect(run.build(Tower.spark, Field.only.path[5]).built, isEmpty);

      final one = run.build(Tower.spark, const Cell(0, 0));
      expect(one.build(Tower.spark, const Cell(0, 0)).built, hasLength(1));
    });

    test('upgrades once and no more, and sells for two thirds', () {
      var run = Run.fresh(embers: 1000).build(Tower.spark, const Cell(0, 0));

      run = run.upgrade(const Cell(0, 0));
      expect(run.towerOn(const Cell(0, 0))!.level, 2);
      expect(run.towerOn(const Cell(0, 0))!.canUpgrade, isFalse);

      final again = run.upgrade(const Cell(0, 0));
      expect(again.towerOn(const Cell(0, 0))!.level, 2);
      expect(again.embers, run.embers, reason: 'and it costs nothing');

      final sold = run.sell(const Cell(0, 0));
      expect(sold.built, isEmpty);
      expect(
        sold.embers - run.embers,
        (Tower.spark.cost + Tower.spark.upgradeCost) * 2 ~/ 3,
      );
    });
  });

  group('a wave', () {
    test('does not start until it is called', () {
      var run = Run.fresh();
      expect(run.waiting, isTrue);
      run = runOn(run, (at) => at.steps > 600);
      expect(run.walking, isEmpty, reason: 'nothing comes until it is called');

      run = run.callWave();
      run = runOn(run, (at) => at.walking.isNotEmpty);
      expect(run.walking, isNotEmpty);
    });

    test('lets its walkers out at the times the table says', () {
      var run = Run.fresh().callWave();
      final wave = Waves.all.first;

      run = runOn(run, (at) => at.seconds >= 0.1);
      expect(run.walking, hasLength(1), reason: 'the first is out at once');

      run = runOn(run, (at) => at.seconds >= wave.groups.first.every + 0.1);
      expect(run.walking, hasLength(2));
    });

    test('pays when it is held, and waits for the next to be called', () {
      var run = Run.fresh(embers: 1000)
          .build(Tower.forge, const Cell(3, 1))
          .build(Tower.forge, const Cell(5, 1))
          .build(Tower.forge, const Cell(3, 3));
      final before = run.embers;
      run = run.callWave();
      run = runOn(run, (at) => at.wave > 0 || at.steps > 40000);

      expect(run.wave, 1, reason: 'the first wave was held');
      expect(
        run.embers - before,
        Waves.all.first.pays +
            Waves.all.first.walkers * Walker.drifter.worth,
        reason: 'paid for the walkers and for holding the wave',
      );
      expect(run.waiting, isTrue);
      expect(run.keep, Run.startingKeep, reason: 'nothing got out');
      expect(run.isOver, isFalse);
    });
  });

  group('walkers', () {
    test('cost the keep when they get out', () {
      // Nothing built, so the whole first wave walks through.
      var run = Run.fresh().callWave();
      run = runOn(run, (at) => at.wave > 0 || at.steps > 40000);

      expect(run.wave, 1);
      expect(run.keep, Run.startingKeep - Waves.all.first.walkers,
          reason: 'six drifters at one keep each');
    });

    test('are worth embers when they are put down', () {
      var run = Run.fresh(embers: 1000).build(Tower.forge, const Cell(3, 1));
      final before = run.embers;
      run = run.callWave();
      run = runOn(run, (at) => at.embers > before);
      expect(run.embers - before, Walker.drifter.worth);
    });

    test('a warded one shrugs off part of every hit', () {
      // Played rather than worked out: a test that recomputes the formula the
      // code uses agrees with it however wrong they both are.
      final onDrifter = _firstHitOn(wave: 0, kind: Walker.drifter);
      final onWarded = _firstHitOn(wave: 7, kind: Walker.warded);

      expect(onDrifter, Tower.spark.hits);
      expect(onWarded, lessThan(onDrifter));
      expect(onWarded, (Tower.spark.hits * (1 - Walker.warded.shrugs)).round());
    });

    test('a frost tower halves the pace of what it hits', () {
      final quick = _howFarIn(2.0, withFrost: false);
      final slowed = _howFarIn(2.0, withFrost: true);
      expect(slowed, lessThan(quick * 0.8),
          reason: 'frost should be plainly visible in the distance walked');
    });
  });

  group('towers', () {
    test('shoot whichever walker in reach is furthest along', () {
      // Two walkers, one well ahead. The tower should take the one about to
      // get out, because that is the one worth shooting.
      var run = Run.fresh(embers: 1000).callWave();
      run = runOn(run, (at) => at.walking.length >= 2);
      final ahead = run.walking.reduce((a, b) => a.along > b.along ? a : b);

      // A spark, not a forge: a forge puts a drifter down in one shot and a
      // walker that is gone cannot be asked who shot it.
      run = run.build(Tower.spark, _nearestBuildableTo(ahead.along));
      // A tower winds up before its first shot, so this waits for it.
      run = runOn(run, (at) => at.shots.isNotEmpty);
      expect(run.shots, isNotEmpty);

      final hurt = run.walking.firstWhere((w) => w.life < w.kind.life);
      expect(hurt.id, ahead.id);
    });

    test('do not shoot what is out of reach', () {
      var run = Run.fresh(embers: 1000);
      // Far from the path at the bottom, while the walkers are at the top.
      run = run.build(Tower.spark, const Cell(8, 9)).callWave();
      run = runOn(run, (at) => at.walking.isNotEmpty);
      run = runOn(run, (at) => at.seconds > 2);
      expect(run.walking.every((w) => w.life == w.kind.life), isTrue);
    });
  });

  group('a whole run', () {
    test('is the same twice, because nothing in it is random', () {
      final once = Plan.held.play();
      final again = Plan.held.play();
      expect(once.steps, again.steps);
      expect(once.wave, again.wave);
      expect(once.keep, again.keep);
      expect(once.embers, again.embers);
    });

    test('ends when the keep falls', () {
      // Nothing built and twenty waves of walkers: the keep goes.
      final run = runThrough(Run.fresh(), (at) => at.isOver);
      expect(run.ending, Ending.fell);
      expect(run.keep, 0);
    });
  });

  group('the balance', () {
    // A defence game's difficulty is an emergent property of about forty
    // numbers, and playing it by hand after every change is not something
    // anybody does often enough. The simulation has no randomness in it, so a
    // plan plus the wave table is a whole run, and a run takes a tenth of a
    // second.
    test('a careful player gets through, and only just', () {
      final run = Plan.held.play();
      expect(run.wave, Waves.count, reason: 'the careful plan should hold');
      expect(run.ending, Ending.held);
      expect(run.keep, lessThan(Run.startingKeep ~/ 2),
          reason: 'and it should cost them something to do it');
    });

    test('half a plan dies somewhere in the middle', () {
      final run = Plan.thin.play();
      expect(run.wave, greaterThan(5), reason: 'it is not a bad plan');
      expect(run.wave, lessThan(Waves.count),
          reason: 'but one corner is not a defence');
    });

    test('a careless player dies early', () {
      // A game the careless player also wins is a game with nothing in it.
      expect(Plan.silly.play().wave, lessThan(5));
    });

    test('the waves get harder, more or less', () {
      // Not strictly — a wave of one lumberer is easier than the fifteen
      // runners before it, and that is the point of it — but the trend has to
      // be up or the last ten waves are the first ten again.
      final early = Waves.all.take(5).fold(0, (sum, w) => sum + w.walkers);
      final late = Waves.all.skip(15).fold(0, (sum, w) => sum + w.walkers);
      expect(late, greaterThan(early * 2));
      expect(Waves.all.last.pays, greaterThan(Waves.all.first.pays * 3));
    });
  });
}

/// What one spark shot takes off the first walker of [kind] in a wave.
///
/// A spark rather than a forge, because a forge puts a drifter down in one and
/// a walker that is gone cannot be asked how much it lost.
int _firstHitOn({required int wave, required Walker kind}) {
  var run = Run.fresh(embers: 1000, wave: wave)
      .build(Tower.spark, _nearestBuildableTo(1))
      .callWave();
  run = runOn(
    run,
    (at) => at.walking.any((w) => w.kind == kind && w.life < kind.life),
  );
  final hit = run.walking.firstWhere((w) => w.kind == kind);
  return kind.life - hit.life;
}

/// How far a drifter walks in [seconds], with or without a frost tower on it.
double _howFarIn(double seconds, {required bool withFrost}) {
  var run = Run.fresh(embers: 1000);
  if (withFrost) {
    run = run.build(Tower.frost, _nearestBuildableTo(1));
  }
  run = run.callWave();
  run = runOn(run, (at) => at.walking.isNotEmpty);
  final start = run.steps;
  run = runOn(run, (at) => (at.steps - start) * Run.stepSeconds >= seconds);
  return run.walking.isEmpty ? 0 : run.walking.first.along;
}

/// A buildable cell as close as possible to a point on the path.
Cell _nearestBuildableTo(double along) {
  final at = Field.only.at(along);
  Cell? best;
  var nearest = double.infinity;
  for (var col = 0; col < Field.columns; col++) {
    for (var row = 0; row < Field.rows; row++) {
      final cell = Cell(col, row);
      if (!Field.only.canBuildOn(cell)) continue;
      final gap = (Spot(col + 0.5, row + 0.5) - at).length;
      if (gap < nearest) {
        nearest = gap;
        best = cell;
      }
    }
  }
  return best!;
}

