import 'package:flutter_test/flutter_test.dart';
import 'package:hoopwell/hoop/levels.dart';
import 'package:hoopwell/hoop/play.dart';
import 'package:hoopwell/hoop/rules.dart';

/// The hoop itself, with no screen anywhere near it.
void main() {
  group('the hoop', () {
    test('has seven holes, and seven is a prime', () {
      expect(Rules.holes, 7);
      for (var d = 2; d < Rules.holes; d++) {
        expect(Rules.holes % d, isNot(0));
      }
    });

    test('counts stones and names their holes', () {
      expect(Rules.count(0), 0);
      expect(Rules.count(0x0F), 4);
      expect(Rules.at(0x0F), [0, 1, 2, 3]);
      expect(Rules.write(0x15), '024');
    });

    test('turns a ring round and comes back where it started', () {
      expect(Rules.turn(1, 0), 1);
      expect(Rules.turn(1, 3), 1 << 3);
      expect(Rules.turn(1 << 6, 1), 1);
      var set = 0x2B;
      for (var k = 0; k < Rules.holes; k++) {
        set = Rules.turn(set, 1);
      }
      expect(set, 0x2B);
    });
  });

  group('the lamps', () {
    test('are the pale ring laid down once for each dark stone', () {
      // One dark stone at hole 3 just turns the pale ring by three.
      expect(Rules.lamps(1 << 3, 0x0F), Rules.turn(0x0F, 3));
      expect(Rules.lamps(0, 0x0F), 0);
      expect(Rules.lamps(0x0F, 0), 0);
    });

    test('are the same whichever voice lights them, on every board', () {
      var boards = 0;
      for (var dark = 0; dark < 1 << Rules.holes; dark++) {
        for (var pale = 0; pale < 1 << Rules.holes; pale++) {
          boards++;
          expect(Rules.lampsByWays(dark, pale), Rules.lamps(dark, pale),
              reason: '${Rules.write(dark)} and ${Rules.write(pale)}');
        }
      }
      expect(boards, 16384);
    });

    test('carry counts that add up to the two rings multiplied', () {
      for (var dark = 0; dark < 1 << Rules.holes; dark += 7) {
        for (var pale = 0; pale < 1 << Rules.holes; pale += 5) {
          final total = Rules.ways(dark, pale).reduce((a, b) => a + b);
          expect(total, Rules.count(dark) * Rules.count(pale));
        }
      }
    });
  });

  group('the floor', () {
    test('is the two counts added with one taken off, capped at the hoop', () {
      expect(Rules.floor(1, 1), 1);
      expect(Rules.floor(2, 4), 5);
      expect(Rules.floor(3, 3), 5);
      expect(Rules.floor(4, 5), 7);
      expect(Rules.floor(0, 3), 0);
    });

    test('is read the same off the divisors of seven', () {
      for (var a = 1; a <= Rules.holes; a++) {
        for (var b = 1; b <= Rules.holes; b++) {
          expect(Rules.floorByDivisors(Rules.holes, a, b), Rules.floor(a, b),
              reason: '$a and $b');
        }
      }
    });

    test('is never broken, on any of the 16,384 boards', () {
      var under = 0;
      for (var dark = 1; dark < 1 << Rules.holes; dark++) {
        for (var pale = 1; pale < 1 << Rules.holes; pale++) {
          final lit = Rules.count(Rules.lamps(dark, pale));
          if (lit < Rules.floor(Rules.count(dark), Rules.count(pale))) under++;
        }
      }
      expect(under, 0);
    });

    test('gives out on a hoop of six, which is why seven is the point', () {
      // Two and four would have a floor of five on a prime hoop; on six
      // the divisor reading says four, and four is reached.
      expect(Rules.floorByDivisors(6, 2, 4), 4);
      expect(Rules.floorByDivisors(7, 2, 4), 5);
    });
  });

  group('the walk', () {
    test('passes through every hole, from any pair of dark stones', () {
      for (var dark = 0; dark < 1 << Rules.holes; dark++) {
        if (Rules.count(dark) != 2) continue;
        expect(Rules.walk(dark).toSet().length, Rules.holes);
      }
    });

    test('makes the lamps the pale stones plus the runs it passes', () {
      var boards = 0;
      for (var dark = 0; dark < 1 << Rules.holes; dark++) {
        if (Rules.count(dark) != 2) continue;
        for (var pale = 1; pale < 1 << Rules.holes; pale++) {
          boards++;
          expect(Rules.count(Rules.lamps(dark, pale)),
              Rules.count(pale) + Rules.runEnds(dark, pale),
              reason: '${Rules.write(dark)} and ${Rules.write(pale)}');
        }
      }
      expect(boards, 2667);
    });

    test('always passes at least one run, so two and four never reach four',
        () {
      var fewest = Rules.holes;
      for (var dark = 0; dark < 1 << Rules.holes; dark++) {
        if (Rules.count(dark) != 2) continue;
        for (var pale = 0; pale < 1 << Rules.holes; pale++) {
          if (Rules.count(pale) != 4) continue;
          final runs = Rules.runEnds(dark, pale);
          if (runs < fewest) fewest = runs;
          expect(Rules.count(Rules.lamps(dark, pale)), greaterThanOrEqualTo(5));
        }
      }
      expect(fewest, 1);
    });
  });

  group('every ask', () {
    test('lands as many boards as it claims', () {
      for (final level in Levels.all) {
        var n = 0;
        for (var dark = 0; dark < 1 << Rules.holes; dark++) {
          for (var pale = 0; pale < 1 << Rules.holes; pale++) {
            if (level.meets((dark, pale))) n++;
          }
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('counts the boards its stones allow', () {
      expect(Levels.at(0).boards, 1225);
      expect(Levels.at(1).boards, 735);
      expect(Levels.all.last.boards, 735);
    });

    test('opens unlanded, one stone of each in hole nothing', () {
      expect(Rules.opening, (1, 1));
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });

    test('asks for the floor or more, except the hopeless one', () {
      for (final level in Levels.all) {
        if (level.winnable) {
          expect(level.lit, greaterThanOrEqualTo(level.floor),
              reason: level.name);
        } else {
          expect(level.lit, lessThan(level.floor), reason: level.name);
        }
      }
    });

    test('is landed by the pointer in the taps it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone && play.taps < 16) {
          final aim = play.next!;
          play = play.tap(aim.$1, aim.$2);
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.taps, level.fewest, reason: level.name);
      }
    });
  });

  group('the boards on the floor', () {
    test('are all a dark run and a pale run at one shared step', () {
      var onFloor = 0, runs = 0;
      for (var dark = 0; dark < 1 << Rules.holes; dark++) {
        final a = Rules.count(dark);
        if (a < 2) continue;
        for (var pale = 0; pale < 1 << Rules.holes; pale++) {
          final b = Rules.count(pale);
          if (b < 2) continue;
          final floor = Rules.floor(a, b);
          if (floor > Rules.holes - 2) continue;
          if (Rules.count(Rules.lamps(dark, pale)) != floor) continue;
          onFloor++;
          var shared = false;
          for (var by = 1; by < Rules.holes; by++) {
            if (Rules.isRun(dark, by) && Rules.isRun(pale, by)) shared = true;
          }
          if (shared) runs++;
        }
      }
      expect(onFloor, 882);
      expect(runs, onFloor);
    });
  });

  group('a go', () {
    test('lays a stone, counts a tap, and takes it back', () {
      final one = Play.of(Levels.at(0)).tap(0, 3);
      expect(one.taps, 1);
      expect(Rules.at(one.dark), [0, 3]);
      expect(one.back.taps, 0);
      expect(Rules.at(one.back.dark), [0]);
    });

    test('lifts a stone back out of a hole it is already in', () {
      final out = Play.of(Levels.at(0)).tap(0, 0);
      expect(out.dark, 0);
      expect(out.lampCount, 0);
    });

    test('reads the floor off the stones it is holding', () {
      final play = Play.of(Levels.at(0));
      expect(play.darkCount, 1);
      expect(play.paleCount, 1);
      expect(play.floor, 1);
      expect(play.lampCount, 1);
    });

    test('points at a hole and says whether to lay or lift', () {
      final play = Play.of(Levels.at(0));
      final aim = play.next!;
      expect(play.pointed(aim), anyOf(contains('Put a'), contains('Take the')));
    });
  });

  group('the hopeless ask', () {
    final dead = Levels.all.last;

    test('is landed by none of its 735 boards', () {
      var n = 0;
      for (var dark = 0; dark < 1 << Rules.holes; dark++) {
        for (var pale = 0; pale < 1 << Rules.holes; pale++) {
          if (dead.meets((dark, pale))) n++;
        }
      }
      expect(n, 0);
      expect(dead.floor, 5);
      expect(dead.lit, 4);
    });

    test('admits it after eight boards', () {
      var play = Play.of(dead);
      expect(play.gaveUp, isFalse);
      for (final tap in [(0, 1), (1, 1), (1, 2), (1, 3), (0, 2), (1, 4),
        (1, 5), (0, 3)]) {
        play = play.tap(tap.$1, tap.$2);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('admits it after twenty taps of going nowhere', () {
      var play = Play.of(dead);
      for (var k = 0; k < Play.gaveUpAt; k++) {
        play = play.tap(0, 1);
      }
      expect(play.seen.length, lessThan(Play.enough));
      expect(play.gaveUp, isTrue);
    });
  });

  group('the why', () {
    test('names both proofs, the sweep and the ask it was asked from', () {
      final words = whyWords(Play.of(Levels.at(3)));
      expect(words, contains('Cauchy proved it in 1813'));
      expect(words, contains('1947'));
      expect(words, contains('16,384'));
      expect(words, contains('The Floor'));
    });
  });
}
