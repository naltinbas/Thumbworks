import 'package:flutter_test/flutter_test.dart';
import 'package:groatsworth/till/fewest.dart';
import 'package:groatsworth/till/play.dart';
import 'package:groatsworth/till/rounds.dart';
import 'package:groatsworth/till/till.dart';

void main() {
  group('the till', () {
    test('speaks old money the old way', () {
      expect(Tills.old.spoken(30), '2/6');
      expect(Tills.old.spoken(48), '4/-');
      expect(Tills.old.spoken(7), '7d');
      expect(Tills.old.spoken(21), '1/9');
    });

    test('and new money in plain pence', () {
      expect(Tills.decimal.spoken(88), '88p');
    });

    test('holds its coins smallest first, starting at a penny', () {
      for (final till in [Tills.old, Tills.decimal]) {
        expect(till.coins.first.pence, 1);
        for (var kind = 1; kind < till.kinds; kind++) {
          expect(till.coins[kind].pence,
              greaterThan(till.coins[kind - 1].pence));
        }
      }
    });
  });

  group('the table', () {
    test('agrees with trying every mix of coins, on every amount to 240', () {
      for (final till in [Tills.old, Tills.decimal]) {
        final fewests = Fewests(till);
        for (var amount = 1; amount <= 240; amount++) {
          expect(fewests.fewestFor(amount), fewests.byTrying(amount),
              reason: '${till.name}, ${amount}d');
        }
      }
    });

    test('and the way it hands back really comes to the amount', () {
      final fewests = Fewests(Tills.old);
      for (var amount = 1; amount <= 240; amount++) {
        final counting = fewests.countingFor(amount);
        var total = 0;
        var coins = 0;
        for (var kind = 0; kind < Tills.old.kinds; kind++) {
          total += counting.coins[kind] * Tills.old.coins[kind].pence;
          coins += counting.coins[kind];
        }
        expect(total, amount);
        expect(coins, counting.fewest);
      }
    });
  });

  group('the biggest coin that fits', () {
    test('fails on the old till exactly where it should', () {
      // The real coinage really did this: the half crown and the florin
      // overlap so that four shillings is two florins, and reaching for the
      // half crown first wastes a coin. Every failing amount up to a pound is
      // one of these, six pence apart in two runs.
      final fails = Fewests(Tills.old).whereBiggestFails(240);
      expect(fails.take(6).toList(), [48, 49, 50, 51, 52, 53]);
      expect(fails, contains(78));
      expect(fails, contains(108));
      expect(fails, contains(228));
      expect(fails.where((amount) => amount < 48), isEmpty);
    });

    test('and never fails on the new till, tried on every amount to 500', () {
      expect(Fewests(Tills.decimal).whereBiggestFails(500), isEmpty);
    });

    test('and is never better than the table anywhere', () {
      for (final till in [Tills.old, Tills.decimal]) {
        final fewests = Fewests(till);
        for (var amount = 1; amount <= 240; amount++) {
          expect(fewests.byBiggest(amount).fewest,
              greaterThanOrEqualTo(fewests.fewestFor(amount)));
        }
      }
    });
  });

  group('the floor', () {
    test('is the amount over the largest coin, rounded up', () {
      final fewests = Fewests(Tills.old);
      expect(fewests.floorFor(48), 2);
      expect(fewests.floorFor(78), 3);
      expect(fewests.floorFor(61), 3);
    });

    test('and never sits above the answer', () {
      final fewests = Fewests(Tills.old);
      for (var amount = 1; amount <= 240; amount++) {
        expect(fewests.floorFor(amount),
            lessThanOrEqualTo(fewests.fewestFor(amount)));
      }
    });
  });

  group('every round that ships', () {
    setUp(Rounds.forget);

    for (var number = 0; number < Rounds.count; number++) {
      final round = Rounds.at(number);

      test('${round.name} says the number the table says', () {
        expect(Rounds.fewestsFor(number).fewestFor(round.amount),
            round.fewest);
      });
    }

    test('every old till round has a tight floor', () {
      // So the game can always say why fewer coins cannot reach the amount,
      // with one multiplication a player can check.
      for (final round in Rounds.all) {
        if (round.till.decimal) continue;
        final fewests = Fewests(round.till);
        expect(fewests.floorFor(round.amount), round.fewest,
            reason: round.name);
      }
    });

    test('and three of them are amounts where biggest-first pays extra', () {
      final traps = [
        for (final round in Rounds.all)
          if (Fewests(round.till).byBiggest(round.amount).fewest > round.fewest)
            round.name,
      ];
      expect(traps, ['Four Bob', 'Six and Six', 'Nine Bob', 'Nineteen Bob']);
    });
  });

  group('a round at the counter', () {
    late Play play;

    setUp(() {
      Rounds.forget();
      play = Play.of(Rounds.at(2), Rounds.fewestsFor(2));
    });

    test('starts with an empty tray', () {
      expect(play.used, 0);
      expect(play.owed, 48);
      expect(play.couldFinishIn, 2);
    });

    test('a coin goes on the tray and comes off again', () {
      play = play.put(4);
      expect(play.onTray(4), 1);
      expect(play.owed, 24);
      play = play.take(4);
      expect(play.used, 0);
    });

    test('a coin that would go over is refused', () {
      play = play.put(4).put(4);
      expect(play.owed, 0);
      expect(identical(play.put(0), play), isTrue);
    });

    test('the half crown here is the wrong coin, and the game knows at once',
        () {
      play = play.put(5);
      expect(play.couldFinishIn, greaterThan(2));
    });

    test('it is done when the amount is met', () {
      play = play.put(4).put(4);
      expect(play.isDone, isTrue);
      expect(play.isFewest, isTrue);
    });

    test('again empties the tray', () {
      play = play.put(4).again;
      expect(play.used, 0);
    });

    test('asking counts every round out in the fewest', () {
      for (var number = 0; number < Rounds.count; number++) {
        var walk = Play.of(Rounds.at(number), Rounds.fewestsFor(number));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 20) fail('${Rounds.at(number).name} never paid up');
          walk = walk.put(walk.next!);
        }
        expect(walk.used, Rounds.at(number).fewest,
            reason: Rounds.at(number).name);
        expect(walk.isFewest, isTrue);
      }
    });

    test('and still finishes as well as it can after the wrong coin', () {
      play = play.put(5);
      final could = play.couldFinishIn;
      var guard = 0;
      while (!play.isDone) {
        if (guard++ > 20) fail('it never paid up');
        play = play.put(play.next!);
      }
      expect(play.used, could);
      expect(play.isFewest, isFalse);
    });
  });
}
