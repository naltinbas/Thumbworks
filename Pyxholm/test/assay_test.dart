import 'package:flutter_test/flutter_test.dart';
import 'package:pyxholm/assay/boxes.dart';
import 'package:pyxholm/assay/fewest.dart';
import 'package:pyxholm/assay/play.dart';
import 'package:pyxholm/assay/pyx.dart';

void main() {
  group('the beam', () {
    final weighing = Weighing(const [0, 1], const [2, 3]);

    test('goes down on the side the heavy coin is on', () {
      expect(weighing.tipFor(const Verdict(0, true)), Tip.left);
      expect(weighing.tipFor(const Verdict(2, true)), Tip.right);
    });

    test('and up on the side the light coin is on', () {
      expect(weighing.tipFor(const Verdict(0, false)), Tip.right);
      expect(weighing.tipFor(const Verdict(2, false)), Tip.left);
    });

    test('and stays level when the wrong coin is off it', () {
      expect(weighing.tipFor(const Verdict(4, true)), Tip.level);
      expect(weighing.tipFor(const Verdict(4, false)), Tip.level);
    });

    test('a weighing needs the same number of coins on each pan', () {
      expect(weighing.isFair, isTrue);
      expect(Weighing(const [0], const [1, 2]).isFair, isFalse);
      expect(Weighing(const [], const []).isFair, isFalse);
    });
  });

  group('what counting says', () {
    test('is how many threes it takes to reach the verdicts', () {
      expect(const Pyx(name: 'x', coins: 3, fewest: 0).countingSays, 2);
      expect(const Pyx(name: 'x', coins: 4, fewest: 0).countingSays, 2);
      expect(const Pyx(name: 'x', coins: 5, fewest: 0).countingSays, 3);
      expect(const Pyx(name: 'x', coins: 12, fewest: 0).countingSays, 3);
      expect(const Pyx(name: 'x', coins: 14, fewest: 0).countingSays, 4);
    });

    test('and knowing which way the coin is wrong halves the work', () {
      const either = Pyx(name: 'x', coins: 9, fewest: 0);
      const light = Pyx(name: 'x', coins: 9, fewest: 0, knownLight: true);
      expect(either.verdicts, 18);
      expect(light.verdicts, 9);
      expect(either.countingSays, 3);
      expect(light.countingSays, 2);
      expect(light.everything.every((verdict) => !verdict.heavy), isTrue);
    });
  });

  group('the searching', () {
    test('two coins cannot be settled at all', () {
      // Weigh one against the other and the beam tips, but there is nothing
      // to say which of the two is wrong.
      const pyx = Pyx(name: 'x', coins: 2, fewest: 0);
      expect(Assay.of(2).fewestFor(pyx.everything), isNull);
    });

    test('three coins take two weighings', () {
      const pyx = Pyx(name: 'x', coins: 3, fewest: 0);
      expect(Assay.of(3).fewestFor(pyx.everything), 2);
    });

    test('four coins take three, though counting says two might do', () {
      // The interesting one. Eight verdicts and nine things two weighings can
      // tell apart, so counting cannot rule two out. Searching can.
      const pyx = Pyx(name: 'x', coins: 4, fewest: 0);
      expect(pyx.countingSays, 2);
      expect(Assay.of(4).fewestFor(pyx.everything), 3);
    });

    test('and the weighing it lays out really does split the verdicts', () {
      for (var coins = 3; coins <= 9; coins++) {
        final pyx = Pyx(name: 'x', coins: coins, fewest: 0);
        final assay = Assay.of(coins);
        final standing = pyx.everything;
        final next = assay.nextFor(standing)!;

        expect(next.isFair, isTrue, reason: '$coins coins');
        final parts = [
          for (final tip in Tip.values) next.after(standing, tip),
        ];
        expect(parts.fold(0, (sum, part) => sum + part.length), standing.length,
            reason: '$coins coins');
        for (final part in parts) {
          expect(part.length, lessThan(standing.length), reason: '$coins');
        }
      }
    });
  });

  group('every box that ships', () {
    setUp(Boxes.forget);

    for (var number = 0; number < Boxes.count; number++) {
      final pyx = Boxes.at(number);

      test('${pyx.name} says the number the searching says', () {
        expect(Assay.of(pyx.coins).fewestFor(pyx.everything), pyx.fewest);
      });

      test('${pyx.name} is never fewer than counting allows', () {
        expect(pyx.fewest, greaterThanOrEqualTo(pyx.countingSays));
      });
    }

    test('and Four is the one where counting is not enough', () {
      final four = Boxes.all.firstWhere((pyx) => pyx.coins == 4);
      expect(four.countingSays, 2);
      expect(four.fewest, 3);
    });

    test('and the same nine coins take two when the way is known and three '
        'when it is not', () {
      final light =
          Boxes.all.firstWhere((pyx) => pyx.coins == 9 && pyx.knownLight);
      final either =
          Boxes.all.firstWhere((pyx) => pyx.coins == 9 && !pyx.knownLight);
      expect(light.fewest, 2);
      expect(either.fewest, 3);
    });
  });

  group('a box on the bench', () {
    late Play play;

    setUp(() {
      Boxes.forget();
      play = Play.of(Boxes.at(3), Boxes.assayFor(3));
    });

    test('starts with everything still possible', () {
      expect(play.standing, hasLength(play.pyx.verdicts));
      expect(play.weighings, 0);
      expect(play.isDone, isFalse);
      expect(play.couldFinishIn, play.pyx.fewest);
    });

    test('a coin goes left, then right, then off again', () {
      expect(play.placeOf(0), -1);
      expect(play.move(0).placeOf(0), 0);
      expect(play.move(0).move(0).placeOf(0), 1);
      expect(play.move(0).move(0).move(0).placeOf(0), -1);
    });

    test('the pans have to match before anything can be weighed', () {
      expect(play.canWeigh, isFalse);
      expect(play.move(0).canWeigh, isFalse);
      expect(play.move(0).move(1).move(1).canWeigh, isTrue);
    });

    test('weighing narrows what it could be and empties the pans', () {
      play = play.move(0).move(1).move(1).weigh();
      expect(play.weighings, 1);
      expect(play.standing.length, lessThan(play.pyx.verdicts));
      expect(play.onLeft, isEmpty);
      expect(play.onRight, isEmpty);
    });

    test('and the beam answers as badly as it truthfully can', () {
      // One against one on six coins leaves eight things it could be, not
      // two, because the beam says level and keeps four coins in play.
      play = play.move(0).move(1).move(1).weigh();
      expect(play.told.first.tip, Tip.level);
      expect(play.standing, hasLength(8));
    });

    test('take back undoes the last weighing', () {
      play = play.move(0).move(1).move(1).weigh();
      expect(play.back.weighings, 0);
      expect(play.back.standing, hasLength(play.pyx.verdicts));
    });

    test('again empties the bench', () {
      play = play.move(0).move(1).move(1).weigh().again;
      expect(play.weighings, 0);
      expect(play.standing, hasLength(play.pyx.verdicts));
    });

    test('a coin the beam clears is known sound', () {
      // One against one on six coins: the beam says level, because that is
      // the answer that leaves the most to do, and the two on the pans are
      // then known to be sound.
      play = play.move(0).move(1).move(1).weigh();
      expect(play.told.first.tip, Tip.level);
      expect(play.isCleared(0), isTrue);
      expect(play.isCleared(1), isTrue);
      expect(play.isCleared(4), isFalse);
      expect(play.couldBeHeavy(4), isTrue);
      expect(play.couldBeLight(4), isTrue);
    });

    test('show me settles every box in the fewest weighings there are', () {
      for (var number = 0; number < Boxes.count; number++) {
        final pyx = Boxes.at(number);
        var walk = Play.of(pyx, Boxes.assayFor(number));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 8) fail('${pyx.name} never settled');
          final next = walk.next!;
          for (final coin in next.left) {
            walk = walk.move(coin);
          }
          for (final coin in next.right) {
            walk = walk.move(coin).move(coin);
          }
          walk = walk.weigh();
        }
        expect(walk.weighings, pyx.fewest, reason: pyx.name);
        expect(walk.isFewest, isTrue, reason: pyx.name);
      }
    });

    test('and a bad first weighing costs, and the game says so', () {
      // On nine coins either way wrong, one against one tells almost nothing.
      var walk = Play.of(Boxes.at(4), Boxes.assayFor(4));
      walk = walk.move(0).move(1).move(1).weigh();
      expect(walk.couldFinishIn, greaterThan(Boxes.at(4).fewest));
    });
  });
}
