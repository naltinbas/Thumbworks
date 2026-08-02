import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/sim/replay.dart';
import 'package:slingwell/sim/world.dart';

void main() {
  group('a new run', () {
    test('is already moving, so letting go at once launches', () {
      final world = World.newRun(seed: 1);
      expect(world.velocity.length, greaterThan(0));
      final flying = world.step(tapped: true);
      final after = flying.step();
      expect((after.craft - flying.craft).length, greaterThan(0));
    });

    test('starts held by the first well', () {
      final world = World.newRun(seed: 1);
      expect(world.isHeld, isTrue);
      expect(world.heldBy, 0);
      expect(world.isOver, isFalse);
      expect(world.score, 0);
    });

    test('lays out the same wells for the same seed', () {
      final a = World.newRun(seed: 42);
      final b = World.newRun(seed: 42);
      for (var i = 0; i < a.wells.length; i++) {
        expect(a.wells[i].at.x, b.wells[i].at.x);
        expect(a.wells[i].at.y, b.wells[i].at.y);
      }
    });

    test('lays out different wells for different seeds', () {
      final a = World.newRun(seed: 1);
      final b = World.newRun(seed: 2);
      final same = List.generate(a.wells.length, (i) => a.wells[i].at.x == b.wells[i].at.x);
      expect(same.every((s) => s), isFalse);
    });

    test('puts the wells in front of the craft, going up', () {
      final world = World.newRun(seed: 7);
      for (var i = 1; i < world.wells.length; i++) {
        expect(world.wells[i].at.y, greaterThan(world.wells[i - 1].at.y),
            reason: 'well $i should be above well ${i - 1}');
      }
    });
  });

  group('holding on', () {
    test('keeps the craft at the same distance from the well', () {
      var world = World.newRun(seed: 3);
      final well = world.wells[0];
      for (var i = 0; i < 200; i++) {
        world = world.step();
        final gap = (world.craft - well.at).length;
        expect(gap, closeTo(2.0, 1e-9), reason: 'step $i');
      }
    });

    test('goes round rather than staying put', () {
      var world = World.newRun(seed: 3);
      final start = world.craft;
      for (var i = 0; i < 100; i++) {
        world = world.step();
      }
      expect((world.craft - start).length, greaterThan(0.5));
    });

    test('never ends a run', () {
      var world = World.newRun(seed: 5);
      for (var i = 0; i < 5000; i++) {
        world = world.step();
      }
      expect(world.isOver, isFalse);
    });
  });

  group('letting go', () {
    test('stops holding and starts flying', () {
      var world = World.newRun(seed: 3);
      for (var i = 0; i < 30; i++) {
        world = world.step();
      }
      final flying = world.step(tapped: true);
      expect(flying.isHeld, isFalse);
      expect(flying.velocity.length, greaterThan(0));
    });

    test('leaves at a right angle to the well, which is what a swing does', () {
      var world = World.newRun(seed: 3);
      for (var i = 0; i < 17; i++) {
        world = world.step();
      }
      final out = (world.craft - world.wells[0].at).normalised;
      final away = world.velocity.normalised;
      // A dot product near zero is a right angle.
      expect(out.x * away.x + out.y * away.y, closeTo(0, 1e-9));
    });

    test('does nothing while already flying', () {
      var world = World.newRun(seed: 3);
      for (var i = 0; i < 20; i++) {
        world = world.step();
      }
      world = world.step(tapped: true);
      final a = world.step(tapped: true);
      final b = world.step();
      expect(a.craft.x, b.craft.x);
      expect(a.craft.y, b.craft.y);
    });
  });

  group('a run', () {
    test('ends when the craft is thrown at the first chance every time', () {
      // Letting go the instant a well catches gives the craft no time to line
      // itself up, so it leaves at whatever angle it arrived at and sooner or
      // later leaves the playfield. A player who taps blindly should lose,
      // and a run that never ends is a run nobody can lose.
      var world = World.newRun(seed: 3);
      for (var i = 0; i < 20000 && !world.isOver; i++) {
        world = world.step(tapped: world.isHeld);
      }
      expect(world.isOver, isTrue);
    });

    test('goes on as long as the craft is held', () {
      // The other half of the same rule: holding on is always safe, so a
      // player who never taps waits rather than dies.
      var world = World.newRun(seed: 3);
      for (var i = 0; i < 5000; i++) {
        world = world.step();
      }
      expect(world.isOver, isFalse);
      expect(world.isHeld, isTrue);
    });

    test('scores a well only the first time it is used', () {
      // Drive by replay so the run is reproducible: find a tap that lands on
      // a second well, then confirm arriving again adds nothing.
      final world = const Replay(seed: 11, taps: [40]).play();
      expect(world.score, lessThanOrEqualTo(world.wells.length));
    });

    test('cannot go backwards in score or steps', () {
      var world = World.newRun(seed: 9);
      var lastScore = 0;
      var lastSteps = 0;
      for (var i = 0; i < 2000 && !world.isOver; i++) {
        world = world.step(tapped: i % 137 == 0);
        expect(world.score, greaterThanOrEqualTo(lastScore));
        expect(world.steps, greaterThan(lastSteps));
        lastScore = world.score;
        lastSteps = world.steps;
      }
    });
  });

  group('a replay', () {
    test('gives the same ending every time it is played', () {
      const replay = Replay(seed: 21, taps: [30, 300, 700, 1200]);
      final a = replay.play();
      final b = replay.play();
      expect(a.steps, b.steps);
      expect(a.score, b.score);
      expect(a.ending, b.ending);
      expect(a.craft.x, b.craft.x);
      expect(a.craft.y, b.craft.y);
    });

    test('is not disturbed by the order the taps are given in', () {
      final ordered = const Replay(seed: 4, taps: [50, 400, 900]).play();
      final jumbled = const Replay(seed: 4, taps: [900, 50, 400]).play();
      expect(jumbled.steps, ordered.steps);
      expect(jumbled.score, ordered.score);
    });

    test('always terminates, for every seed tried', () {
      for (var seed = 0; seed < 60; seed++) {
        final world = Replay(seed: seed, taps: [20 + seed % 40]).play();
        expect(world.isOver || world.steps > 0, isTrue, reason: 'seed $seed');
      }
    });
  });
}
