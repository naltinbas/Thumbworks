import 'package:flitwell/flit/levels.dart';
import 'package:flitwell/flit/play.dart';
import 'package:flitwell/flit/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The lane itself, with no screen anywhere near it.
void main() {
  group('the lane', () {
    test('has twenty four ways of housing four tenants', () {
      final lanes = Rules.allocations();
      expect(lanes.length, 24);
      expect(lanes.map(Rules.write).toSet().length, 24);
      expect(Rules.write(Rules.opening), 'ABCD');
    });

    test('reads a street off its letters, best cottage first', () {
      final street = Rules.read('BCAD DACB BADC ACBD');
      expect(street[0], [1, 2, 0, 3]);
      expect(Rules.rank(street, 0, 1), 0);
      expect(Rules.rank(street, 0, 3), 3);
      expect(Rules.rather(street, 0, 1, 3), isTrue);
      expect(Rules.rather(street, 0, 3, 1), isFalse);
    });

    test('counts a swap as one and a ring of four as three', () {
      expect(Rules.between(Rules.opening, Rules.opening), 0);
      expect(Rules.between(Rules.opening, [1, 0, 2, 3]), 1);
      expect(Rules.between(Rules.opening, [1, 0, 3, 2]), 2);
      expect(Rules.between(Rules.opening, [1, 2, 3, 0]), 3);
    });
  });

  group('a group of tenants', () {
    final street = Rules.read('BCAD DACB BADC ACBD');

    test('can beat a lane only with the cottages it owns', () {
      // A and B both want each other's cottage, so the two of them
      // beat everyone staying at home.
      expect(Rules.blockers(street, Rules.opening, firmly: false), isNotNull);
    });

    test('cannot beat the lane the rings give', () {
      final firm = Rules.rings(street);
      expect(Rules.write(firm), 'BDCA');
      expect(Rules.blockers(street, firm, firmly: false), isNull);
      expect(Rules.blockers(street, firm, firmly: true), isNull);
    });

    test('is stricter about nudging than about beating', () {
      // Seven lanes here are unbeaten; only one of them is firm.
      final unbeaten = Rules.allocations()
          .where((lane) => Rules.settled(street, lane))
          .toList();
      final firm =
          Rules.allocations().where((lane) => Rules.firm(street, lane)).toList();
      expect(unbeaten.length, 7);
      expect(firm.length, 1);
      expect(Rules.write(firm.single), 'BDCA');
      expect(unbeaten.map(Rules.write), contains('BDCA'));
    });
  });

  group('the trading rings', () {
    test('give the firm lane on every street of four', () {
      // The whole universe, in the test rather than only the checker.
      final orders = Rules.allocations();
      var streets = 0;
      for (final a in orders) {
        for (final b in orders) {
          final street = [a, b, orders[7], orders[19]];
          streets++;
          final byRings = Rules.rings(street);
          final firm = Rules.allocations()
              .where((lane) => Rules.firm(street, lane))
              .toList();
          expect(firm.length, 1, reason: '$street');
          expect(firm.single, byRings, reason: '$street');
        }
      }
      expect(streets, 576);
    });

    test('leave somebody in the cottage they wanted most', () {
      final orders = Rules.allocations();
      for (final a in orders) {
        final street = [a, orders[3], orders[11], orders[22]];
        expect(Rules.topped(street, Rules.rings(street)), isNotEmpty);
      }
    });

    test('give a lane no other lane beats outright', () {
      final orders = Rules.allocations();
      for (final a in orders) {
        final street = [orders[5], a, orders[13], orders[2]];
        final firm = Rules.rings(street);
        for (final lane in Rules.allocations()) {
          expect(Rules.allBetterThan(street, lane, firm), isFalse);
        }
      }
    });
  });

  group('every ask', () {
    test('lands as many lanes as it claims', () {
      for (final level in Levels.all) {
        final n =
            Rules.allocations().where(level.meets).length;
        expect(n, level.ways, reason: level.name);
      }
    });

    test('opens unlanded, everyone in the cottage they own', () {
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });

    test('is landed by the pointer in the swaps it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone && play.swaps < 8) {
          final aim = play.next!;
          play = play.tap(aim.$1).tap(aim.$2);
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.swaps, level.fewest, reason: level.name);
      }
    });

    test('names its own firm lane, and it is firm', () {
      for (final level in Levels.all) {
        expect(Rules.firm(level.orders, level.firmLane), isTrue,
            reason: level.name);
      }
    });
  });

  group('the shared street', () {
    final street = Rules.read(Levels.shared);

    test('carries the second, fourth and fifth asks', () {
      expect(Levels.at(1).street, Levels.shared);
      expect(Levels.at(3).street, Levels.shared);
      expect(Levels.at(4).street, Levels.shared);
    });

    test('leaves C in the cottage it wants least, and still cannot be '
        'bettered', () {
      final firm = Rules.rings(street);
      expect(Rules.topped(street, firm), [0, 1, 3]);
      expect(Rules.rank(street, 2, firm[2]), 3);
      expect(Rules.firm(street, firm), isTrue);
    });
  });

  group('a go', () {
    test('picks a tenant up before swapping, and counts one swap', () {
      final level = Levels.at(0);
      final held = Play.of(level).tap(0);
      expect(held.held, 0);
      expect(held.swaps, 0);
      final swapped = held.tap(1);
      expect(swapped.held, isNull);
      expect(swapped.swaps, 1);
      expect(Rules.write(swapped.where), 'BACD');
    });

    test('puts a tenant back down when tapped again', () {
      final held = Play.of(Levels.at(0)).tap(2);
      expect(held.tap(2).held, isNull);
      expect(held.tap(2).swaps, 0);
    });

    test('takes a swap back', () {
      final one = Play.of(Levels.at(0)).tap(0).tap(1);
      expect(one.back.where, Rules.opening);
      expect(one.back.swaps, 0);
    });

    test('names the group that could beat the lane it is in', () {
      final play = Play.of(Levels.at(1));
      expect(play.beaters, isNotNull);
      expect(play.isDone, isFalse);
    });

    test('points at two tenants and says to tap both', () {
      final play = Play.of(Levels.at(1));
      final aim = play.next!;
      expect(play.pointed(aim), contains('Tap tenant'));
      expect(play.tap(aim.$1).pointed(aim), contains('Now tap tenant'));
    });
  });

  group('the hopeless ask', () {
    final dead = Levels.all.last;

    test('is landed by none of the twenty four lanes', () {
      for (final lane in Rules.allocations()) {
        expect(dead.meets(lane), isFalse);
      }
    });

    test('has three tenants already in the cottage they want most', () {
      expect(Rules.topped(dead.orders, dead.firmLane).length, 3);
    });

    test('admits it after six lanes', () {
      var play = Play.of(dead);
      expect(play.gaveUp, isFalse);
      for (final pair in [(0, 1), (2, 3), (0, 2), (1, 3), (0, 3), (1, 2)]) {
        play = play.tap(pair.$1).tap(pair.$2);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('admits it after twelve swaps of going nowhere', () {
      var play = Play.of(dead);
      for (var k = 0; k < Play.gaveUpAt; k++) {
        play = play.tap(0).tap(1);
      }
      expect(play.seen.length, lessThan(Play.enough));
      expect(play.gaveUp, isTrue);
    });
  });

  group('the why', () {
    test('names the paper, the rings and the ask it was asked from', () {
      final words = whyWords(Play.of(Levels.at(3)));
      expect(words, contains('Shapley and Scarf'));
      expect(words, contains('Gale'));
      expect(words, contains('331,776'));
      expect(words, contains('The Firm Lane'));
    });
  });
}
