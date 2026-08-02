import 'package:flutter_test/flutter_test.dart';
import 'package:vaultline/sim/ground.dart';
import 'package:vaultline/sim/journey.dart';
import 'package:vaultline/sim/library.dart';
import 'package:vaultline/sim/maker.dart';
import 'package:vaultline/sim/passable.dart';
import 'package:vaultline/sim/runner.dart';

/// Runs a stretch with the button never touched.
Run neverPress(Ground ground) {
  var run = Run.on(ground);
  while (!run.isOver) {
    run = run.step();
  }
  return run;
}

void main() {
  group('the ground', () {
    test('reads back what it was written as', () {
      final ground = Ground.of('.._^3.');
      expect(ground.length, 6);
      expect(ground.at(0), Tile.flat);
      expect(ground.at(2).isPit, isTrue);
      expect(ground.at(3).spiked, isTrue);
      expect(ground.at(4).top, 3);
      expect('$ground', '.._^3.');
    });

    test('is flat past its end, so a finished run does not fall through', () {
      expect(Ground.of('...').at(99), Tile.flat);
      expect(Ground.of('...').at(-1), Tile.flat);
    });
  });

  group('the runner', () {
    test('runs on without being touched, on flat ground', () {
      final run = neverPress(Ground.of('.' * 20));
      expect(run.ending, Ending.through);
      expect(run.y, 0);
    });

    test('falls into a pit', () {
      expect(neverPress(Ground.of('...___...')).ending, Ending.fell);
    });

    test('lands on a spike', () {
      expect(neverPress(Ground.of('...^.....')).ending, Ending.spiked);
    });

    test('runs into the side of a step', () {
      expect(neverPress(Ground.of('...222...')).ending, Ending.hit);
    });

    test('is the same run twice, because nothing in it is random', () {
      final ground = Ground.of('...__...^...');
      final once = playWith(ground, const [40, 41, 42]);
      final again = playWith(ground, const [40, 41, 42]);
      expect(once.steps, again.steps);
      expect(once.x, again.x);
      expect(once.y, again.y);
      expect(once.ending, again.ending);
    });

    group('the button', () {
      test('does nothing in the air, so mashing it is not a second jump', () {
        // Held from the start and never let go: one jump, not a flight.
        final ground = Ground.of('.' * 30);
        final held = playWith(ground, [for (var i = 0; i < 300; i++) i]);
        expect(held.ending, Ending.through);
        expect(held.y, 0, reason: 'it came back down');
      });

      test('held longer jumps higher', () {
        double highest(List<int> holds) {
          var run = Run.on(Ground.of('.' * 40));
          final held = holds.toSet();
          var top = 0.0;
          while (!run.isOver) {
            run = run.step(holding: held.contains(run.steps));
            if (run.y > top) top = run.y;
          }
          return top;
        }

        final tapped = highest(const [0]);
        final held = highest([for (var i = 0; i < Run.liftSteps; i++) i]);
        expect(tapped, greaterThan(0.5));
        expect(held, greaterThan(tapped * 1.4),
            reason: 'a hold should be plainly higher than a tap, '
                'or the button is one bit');
      });
    });
  });

  group('the verifier', () {
    test('gets through what can be got through, and says how', () {
      final ground = Ground.of('...__......');
      final found = const Verifier().check(ground);

      expect(found.through, isTrue);
      expect(found.needsJumping, isTrue);
      expect(playWith(ground, found.holds).ending, Ending.through,
          reason: 'the line it found has to play out');
    });

    test('needs no button on flat ground', () {
      final found = const Verifier().check(Ground.of('.' * 16));
      expect(found.through, isTrue);
      expect(found.holds, isEmpty,
          reason: 'it should find the laziest way, not the busiest');
    });

    test('says so when a gap is too wide to clear', () {
      // A full hold carries about four tiles. Six is not a jump, it is a
      // decision somebody made badly.
      final found = const Verifier().check(Ground.of('....______......'));
      expect(found.through, isFalse);
      expect(found.gaveUp, isFalse,
          reason: 'it should run out of states, not out of patience');
    });

    test('and when a step is too high to clear', () {
      final found = const Verifier().check(Ground.of('....44444.......'));
      expect(found.through, isFalse);
      expect(found.gaveUp, isFalse);
    });

    test('leaves the runner standing at the end, not in the air', () {
      // This is what makes one stretch safe to join to the next: a runner who
      // leaves a stretch mid-jump arrives in the next one somewhere its own
      // proof knows nothing about.
      for (final written in const [
        '...__......',
        '...^...11...',
        '...___...^......',
      ]) {
        final ground = Ground.of(written);
        final found = const Verifier().check(ground);
        expect(found.through, isTrue, reason: written);

        // Replay to the last tile and check the runner is on the floor.
        var run = Run.on(ground);
        final held = found.holds.toSet();
        while (!run.isOver && run.column < ground.length - 1) {
          run = run.step(holding: held.contains(run.steps));
        }
        expect(run.onGround, isTrue, reason: '$written ended in the air');
      }
    });
  });

  group('the maker', () {
    test('gives the same stretch for the same seed', () {
      final once = const Maker().make(seed: 4, obstacles: 2);
      final again = const Maker().make(seed: 4, obstacles: 2);
      expect(once!.written, again!.written);
      expect(once.holds, again.holds);
    });

    test('never hands over one that cannot be got through', () {
      // The property the whole maker exists for. Every stretch it makes is
      // replayed here through the rules, which is a different thing from
      // asking the verifier again.
      for (var obstacles = 1; obstacles <= 3; obstacles++) {
        for (var seed = 0; seed < 6; seed++) {
          final stretch = const Maker().make(seed: seed, obstacles: obstacles);
          expect(stretch, isNotNull, reason: 'seed $seed, $obstacles obstacles');
          expect(
            playWith(stretch!.ground, stretch.holds).ending,
            Ending.through,
            reason: stretch.written,
          );
        }
      }
    });

    test('never hands over one nobody has to jump on', () {
      for (var seed = 0; seed < 8; seed++) {
        final stretch = const Maker().make(seed: seed, obstacles: 1)!;
        expect(stretch.jumps, greaterThan(0), reason: stretch.written);
        expect(neverPress(stretch.ground).ending, isNot(Ending.through),
            reason: '${stretch.written} can be walked, which is not a stretch');
      }
    });

    test('more obstacles means more presses', () {
      double pressesFor(int obstacles) {
        var total = 0, made = 0;
        for (var seed = 0; seed < 8; seed++) {
          final stretch = const Maker().make(seed: seed, obstacles: obstacles);
          if (stretch == null) continue;
          total += stretch.jumps;
          made++;
        }
        return total / made;
      }

      expect(pressesFor(3), greaterThan(pressesFor(1)));
    });

    test('starts and ends flat, so one joins to the next', () {
      for (var seed = 0; seed < 8; seed++) {
        final stretch = const Maker().make(seed: seed, obstacles: 2)!;
        final ground = stretch.ground;
        for (var at = 0; at < 3; at++) {
          expect(ground.at(at).isFlat, isTrue, reason: stretch.written);
        }
        for (var at = ground.length - 3; at < ground.length; at++) {
          expect(ground.at(at).isFlat, isTrue, reason: stretch.written);
        }
      }
    });
  });

  group('the library', () {
    test('holds a few hundred stretches, every one already got through', () {
      expect(Library.count, greaterThan(200));
      for (final piece in Library.all) {
        expect(piece.jumps, greaterThan(0), reason: piece.written);
        expect(
          playWith(piece.ground, piece.holds).ending,
          Ending.through,
          reason: '${piece.written} does not play out',
        );
      }
    });

    test('hands out harder stretches the further the run goes', () {
      expect(Library.reachFor(0), 1);
      expect(Library.reachFor(400), greaterThan(Library.reachFor(40)));
      expect(Library.reachFor(100000), Library.hardest,
          reason: 'and stops when it runs out of harder ones');
    });
  });

  group('a journey', () {
    test('never runs out of ground in front of the runner', () {
      var journey = Journey.begin(seed: 1);
      // Held all the way, which dies quickly, so this only checks the world
      // is there — the next test checks it can be got through.
      for (var i = 0; i < 20000 && !journey.isOver; i++) {
        journey = journey.step();
        expect(journey.made, greaterThan(journey.run.x),
            reason: 'the world ran out at ${journey.run.x}');
      }
    });

    test('is the same journey twice, for the same seed and presses', () {
      Journey play(List<int> holds) {
        final held = holds.toSet();
        var journey = Journey.begin(seed: 7);
        for (var i = 0; i < 600 && !journey.isOver; i++) {
          journey = journey.step(holding: held.contains(journey.run.steps));
        }
        return journey;
      }

      final once = play(const [10, 11, 12]);
      final again = play(const [10, 11, 12]);
      expect(once.run.x, again.run.x);
      expect(once.run.y, again.run.y);
      expect(once.isOver, again.isOver);
    });

    test('can be got right through, played by nothing but the stored proofs',
        () {
      // The claim the whole game rests on, checked end to end.
      //
      // Every piece was proved on its own, from a standing start on its first
      // tile. The runner crosses a tile in exactly sixteen steps, so a piece
      // laid at tile t has its proof's step s at the run's step s + 16t. This
      // presses the button on exactly those steps and on no others, and gets
      // a very long way — which is what says that joining proved pieces
      // really does give a run that can be got through, rather than one that
      // nearly can.
      var journey = Journey.begin(seed: 3);
      final held = <int>{};
      var known = 0;

      for (var i = 0; i < 12000 && !journey.isOver; i++) {
        // Learn the presses for any piece laid since last time.
        for (; known < journey.laid.length; known++) {
          held.addAll(journey.laid[known].holdsInRun);
        }
        journey = journey.step(holding: held.contains(journey.run.steps));
      }

      expect(journey.isOver, isFalse,
          reason: 'died at ${journey.run.x.toStringAsFixed(1)} tiles '
              'by ${journey.run.ending}');
      expect(journey.run.x, greaterThan(700),
          reason: 'it should get a long way');
    });
  });
}
