import 'package:flutter_test/flutter_test.dart';
import 'package:pailsworth/pail/errands.dart';
import 'package:pailsworth/pail/play.dart';
import 'package:pailsworth/pail/rules.dart';

void main() {
  group('the pours', () {
    test('fill to the brim, empty to the drain, tip until stopped', () {
      final rules = Rules(const [3, 5]);
      expect(rules.poured(const [0, 0], -1, 1), [0, 5]);
      expect(rules.poured(const [3, 5], 0, -2), [0, 5]);
      expect(rules.poured(const [3, 5], 1, 0), [3, 5]);
      expect(rules.poured(const [0, 5], 1, 0), [3, 2]);
      expect(rules.poured(const [2, 1], 0, 1), [0, 3]);
    });

    test('the pours from a waterline are exactly the legal ones', () {
      final rules = Rules(const [3, 5]);
      final fromDry = rules.pours(const [0, 0]);
      expect(fromDry, [(-1, 0), (-1, 1)]);
      final fromFull = rules.pours(const [3, 5]);
      expect(fromFull, [(0, -2), (1, -2)]);
    });
  });

  group('the two ways of knowing', () {
    test('the walk names the famous fewest', () {
      // The anchor. Nothing here knows anything of arithmetic.
      expect(Rules(const [3, 5]).fewestTo(4), 6);
      expect(Rules(const [6, 9]).fewestTo(3), 2);
      expect(Rules(const [8, 5, 3]).fewestTo(4), 6);
      expect(Rules(const [7, 11]).fewestTo(2), 14);
    });

    test('every reachable waterline keeps the shared measure', () {
      // The invariant, swept: a pour is a fill to the brim, a full
      // emptying, or a tip that conserves, so multiples stay
      // multiples.
      for (final caps in const [
        [6, 9],
        [3, 5],
        [8, 5, 3],
      ]) {
        final rules = Rules(caps);
        final measure = rules.measure;
        for (final held in rules.reachableMeasures()) {
          expect(held % measure, 0, reason: 'caps $caps held $held');
        }
      }
    });

    test('the third pint is dead both ways', () {
      final rules = Rules(const [6, 9]);
      expect(rules.measure, 3);
      expect(4 % rules.measure, isNot(0));
      expect(rules.fewestTo(4), isNull);
      expect(rules.reachableMeasures().toList()..sort(), [0, 3, 6, 9]);
    });
  });

  group('every errand that ships', () {
    for (var number = 0; number < Errands.count; number++) {
      final errand = Errands.at(number);

      test('${errand.name} is what it says it is', () {
        final rules = Rules(errand.caps);
        expect(rules.fewestTo(errand.ask), errand.fewest);
      });
    }
  });

  group('an errand in play', () {
    test('starts dry with the fewest still to be had', () {
      final play = Play.of(Errands.at(1));
      expect(play.held, [0, 0]);
      expect(play.pours, 0);
      expect(play.isDone, isFalse);
      expect(play.fewestFromHere, 6);
    });

    test('a pour moves water and counts; a bad pour is refused', () {
      final play = Play.of(Errands.at(1)).pour(Play.spring, 1);
      expect(play.held, [0, 5]);
      expect(play.pours, 1);
      expect(play.mayPour(Play.spring, 1), isFalse);
      expect(identical(play.pour(Play.spring, 1), play), isTrue);
      expect(play.mayPour(0, Play.drain), isFalse);
    });

    test('take back returns the waterline as it stood', () {
      final start = Play.of(Errands.at(1));
      final poured = start.pour(Play.spring, 0);
      expect(poured.back.held, [0, 0]);
      expect(identical(start.back, start), isTrue);
    });

    test('a wandering pour shows in the live number at once', () {
      final play = Play.of(Errands.at(1));
      final went = play.next!;
      final toward = play.pour(went.$1, went.$2);
      expect(toward.fewestFromHere, 5);
      // Straight down the drain: the water and the count both gone.
      final wasted = toward.pour(
          toward.held[0] > 0 ? 0 : 1, Play.drain);
      expect(wasted.fewestFromHere, greaterThan(5));
    });

    test('following next runs every winnable errand at its fewest', () {
      for (var number = 0; number < Errands.count; number++) {
        final errand = Errands.at(number);
        if (!errand.winnable) continue;
        var play = Play.of(errand);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 20) fail('${errand.name} never ran');
          expect(play.fewestFromHere, errand.fewest! - play.pours,
              reason: errand.name);
          final pour = play.next!;
          play = play.pour(pour.$1, pour.$2);
        }
        expect(play.pours, errand.fewest, reason: errand.name);
      }
    });

    test('the third pint offers nothing however the water moves', () {
      var play = Play.of(Errands.at(5));
      expect(play.fewestFromHere, isNull);
      expect(play.next, isNull);
      play = play
          .pour(Play.spring, 1)
          .pour(1, 0)
          .pour(0, Play.drain)
          .pour(1, 0);
      expect(play.isDone, isFalse);
      expect(play.fewestFromHere, isNull);
    });
  });
}
