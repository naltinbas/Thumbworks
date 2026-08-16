import 'package:flutter_test/flutter_test.dart';
import 'package:stubwick/ticket/level.dart';
import 'package:stubwick/ticket/levels.dart';
import 'package:stubwick/ticket/play.dart';
import 'package:stubwick/ticket/rules.dart';

/// The rule, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the rule', () {
    test('the doubling, the places, the sum and the check digit', () {
      expect([for (var d = 0; d < 10; d++) Rules.doubled(d)], [0, 2, 4, 6, 8, 1, 3, 5, 7, 9]);
      expect(Rules.doubles, [0, 2, 4, 6, 8, 1, 3, 5, 7, 9]);
      expect([for (var i = 0; i < 5; i++) Rules.isDoubled(i)], [false, true, false, true, false]);
      expect(Rules.adds([4, 9, 9, 2, 4]), [4, 9, 9, 4, 4]);
      expect(Rules.sum([4, 9, 9, 2, 4]), 30);
      expect(Rules.passes([4, 9, 9, 2, 4]), isTrue);
      expect(Rules.passes([4, 9, 9, 2, 7]), isFalse);
      expect(Rules.checkFor([4, 9, 9, 2, 0]), 4);
      expect(Rules.checkFor([0, 0, 0, 0, 0]), 0);
      expect(Rules.digitsOf(91), [0, 0, 0, 9, 1]);
      expect(Rules.numberOf([0, 0, 0, 9, 1]), 91);
      expect(Rules.tickets.length, 100000);
      expect([for (var d = 0; d < 10; d++) Rules.withDouble(d)], [0, 3, 6, 9, 2, 6, 9, 2, 5, 8]);
      expect(Rules.swapUnseen, [(0, 9), (9, 0)]);
      expect(Rules.twinsUnseen, [(2, 5), (3, 6), (4, 7)]);
      expect(Rules.tell([4, 9, 9, 2, 4]), '4 9 9 2 4');
      expect(Level.swapPlaces([0, 0, 0, 9, 1]), [2]);
      expect(Level.swapPlaces([4, 9, 9, 2, 4]), isEmpty);
      expect(Level.twinPlaces([0, 0, 1, 3, 3]), [3]);
      expect(Level.twinPlaces([0, 0, 1, 1, 8]), isEmpty);
      expect(Level.palindrome([1, 2, 0, 2, 1]), isTrue);
      expect(Level.palindrome([1, 2, 0, 2, 3]), isFalse);
    });

    test('the sweep: the two sums agree, one check digit a run, no slip passes, and the swaps and twins that pass are the table\'s', () {
      var passing = 0, slipsPass = 0, swapsPass = 0, twinsPass = 0;
      for (final d in Rules.tickets) {
        var byTable = 0;
        for (var i = 0; i < 5; i++) {
          byTable += Rules.isDoubled(i) ? Rules.doubles[d[i]] : d[i];
        }
        expect(byTable, Rules.sum(d), reason: Rules.tell(d));
        if (!Rules.passes(d)) continue;
        passing++;
        for (var i = 0; i < 5; i++) {
          for (var x = 0; x < 10; x++) {
            if (x != d[i] && Rules.passes(List.of(d)..[i] = x)) slipsPass++;
          }
        }
        for (var i = 0; i + 1 < 5; i++) {
          if (d[i] == d[i + 1]) {
            for (var b = 0; b < 10; b++) {
              if (b != d[i] && Rules.passes(List.of(d)..[i] = b..[i + 1] = b)) {
                twinsPass++;
                expect(Rules.twinsUnseen.any((p) => {p.$1, p.$2}.containsAll({d[i], b})), isTrue, reason: '${Rules.tell(d)} twin $b');
              }
            }
          } else if (Rules.passes(List.of(d)..[i] = d[i + 1]..[i + 1] = d[i])) {
            swapsPass++;
            expect({d[i], d[i + 1]}, {0, 9}, reason: Rules.tell(d));
          }
        }
      }
      expect((passing, slipsPass, swapsPass, twinsPass), (10000, 0, 800, 2400));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Slip Unseen']);
      for (final level in Levels.all) {
        var ways = 0;
        for (final d in Rules.tickets) {
          if (level.meets(d)) ways++;
        }
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, [0, 0, 0, 0, 0]);
      expect(Levels.at(1).aim, [0, 0, 0, 9, 1]);
      expect(Levels.at(2).aim, [0, 0, 1, 3, 3]);
      expect(Levels.at(3).aim, [0, 0, 0, 0, 0]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'turn the dials to a ticket that passes');
      expect(Levels.at(1).task, 'turn the dials to a passing ticket with a 0 and a 9 side by side');
      expect(Levels.at(2).task, 'turn the dials to a passing ticket with 22, 33, 44, 55, 66 or 77 in it');
      expect(Levels.at(3).task, 'turn the dials to a passing ticket that reads the same backwards');
      expect(Levels.at(4).task, 'turn one dial of a passing ticket and have it pass still');
    });

    test('an ask is met by the ticket', () {
      expect(Levels.at(0).meets([4, 9, 9, 2, 4]), isTrue);
      expect(Levels.at(0).meets([4, 9, 9, 2, 7]), isFalse);
      expect(Levels.at(1).meets([0, 0, 0, 9, 1]), isTrue);
      expect(Levels.at(1).meets([0, 0, 0, 0, 0]), isFalse);
      expect(Levels.at(1).meets([4, 0, 9, 2, 3]), isTrue);
      expect(Levels.at(2).meets([0, 0, 1, 3, 3]), isTrue);
      expect(Levels.at(2).meets([0, 0, 1, 6, 6]), isTrue);
      expect(Levels.at(2).meets([0, 0, 1, 1, 8]), isFalse);
      expect(Levels.at(3).meets([1, 2, 0, 2, 1]), isTrue);
      expect(Levels.at(3).meets([4, 9, 9, 2, 4]), isFalse);
      expect(Levels.at(4).meets([0, 0, 0, 0, 0]), isFalse);
    });
  });

  group('the play', () {
    test('opens at 0 0 0 0 1, failing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.digits, [0, 0, 0, 0, 1]);
        expect((play.sum, play.passes, play.moves), (1, false, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a turn moves one digit, round from 9 to 0 and back', () {
      var play = Play.of(Levels.at(4)).turn(3, -1);
      expect(play.digits, [0, 0, 0, 9, 1]);
      play = play.turn(3, 1);
      expect(play.digits, [0, 0, 0, 0, 1]);
      expect(play.moves, 2);
      expect(play.turn(5, 1), same(play));
      expect(play.turn(0, 0), same(play));
      expect(play.turn(4, 1).digits, [0, 0, 0, 0, 2]);
    });

    test('back undoes one turn', () {
      final play = Play.of(Levels.at(0)).turn(0, 1).turn(1, 1);
      expect(play.back.digits, [1, 0, 0, 0, 1]);
      expect(play.back.back.digits, [0, 0, 0, 0, 1]);
    });

    test('the pointer turns the leftmost dial off the aim, the shorter way', () {
      expect(Play.of(Levels.at(0)).next, (4, -1));
      expect(Play.pointed((4, -1)), 'Turn dial 5 down.');
      expect(Play.of(Levels.at(2)).next, (2, 1));
      expect(Play.pointed((2, 1)), 'Turn dial 3 up.');
      expect(Play.of(Levels.at(1)).next, (3, -1));
      expect(Play.standing(Levels.at(2), [0, 0, 1, 3, 9]).next, (4, 1));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          final (place, by) = play.next!;
          play = play.turn(place, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
      var twin = Play.of(Levels.at(2));
      while (!twin.isDone) {
        final (place, by) = twin.next!;
        twin = twin.turn(place, by);
      }
      expect(twin.digits, [0, 0, 1, 3, 3]);
      expect(twin.moves, 6);
    });

    test('the slip unseen admits it after three slips from passing tickets, or twenty taps', () {
      var play = Play.of(Levels.at(4)).turn(4, -1);
      expect(play.passes, isTrue);
      expect(play.slips, 0);
      play = play.turn(0, 1);
      expect(play.slipped, isTrue);
      expect(play.passes, isFalse);
      expect(play.slips, 1);
      expect(play.gaveUp, isFalse);
      play = play.turn(0, -1).turn(1, 1);
      expect(play.slips, 2);
      play = play.turn(1, -1).turn(2, 1);
      expect(play.slips, 3);
      expect(play.gaveUp, isTrue);
      expect(play.moves, 6);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.turn(0, 1);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 20);
    });

    test('the why tells Luhn and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Hans Peter Luhn'));
      expect(words, contains('450,000'));
      expect(words, contains('This is ask 5, The Slip Unseen.'));
      expect(words, contains('summed in full'));
    });
  });
}
