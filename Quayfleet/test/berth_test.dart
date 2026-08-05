import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quayfleet/berth/most.dart';
import 'package:quayfleet/berth/play.dart';
import 'package:quayfleet/berth/quay.dart';
import 'package:quayfleet/berth/quays.dart';

/// A day made up at random, the same way the tool that found the shipped ones
/// does it.
Quay _madeUp(Random random, {int many = 8, int opens = 6, int shuts = 18}) => Quay(
      name: 'made up',
      opens: opens,
      shuts: shuts,
      ships: [
        for (var ship = 0; ship < many; ship++)
          () {
            final from = opens + random.nextInt(shuts - opens - 1);
            final hours = 1 + random.nextInt(min(5, shuts - from));
            return Ship('S$ship', from, from + hours);
          }(),
      ],
    );

void main() {
  group('a ship', () {
    const ship = Ship('Marigold', 9, 13);

    test('is in the berth up to but not including the hour it casts off', () {
      expect(ship.wantsIt(8), isFalse);
      expect(ship.wantsIt(9), isTrue);
      expect(ship.wantsIt(12), isTrue);
      expect(ship.wantsIt(13), isFalse);
      expect(ship.lastHour, 12);
      expect(ship.hours, 4);
    });

    test('clashes with one that overlaps it and not with one that follows', () {
      expect(ship.clashesWith(const Ship('Osprey', 12, 14)), isTrue);
      expect(ship.clashesWith(const Ship('Osprey', 13, 15)), isFalse);
      expect(ship.clashesWith(const Ship('Osprey', 7, 9)), isFalse);
      expect(ship.clashesWith(const Ship('Osprey', 7, 10)), isTrue);
    });
  });

  group('the rule', () {
    test('takes the ship that casts off earliest', () {
      final quay = Quay(
        name: 'three',
        opens: 8,
        shuts: 14,
        ships: const [
          Ship('long', 8, 13),
          Ship('early', 8, 10),
          Ship('after', 10, 12),
        ],
      );
      final berthing = Berthings.most(quay);
      expect(berthing.most, 2);
      expect(berthing.taken, [1, 2]);
    });

    test('and the hours it gives back catch every ship in the day', () {
      for (var number = 0; number < Days.count; number++) {
        final quay = Days.at(number).quay;
        final marks = Berthings.most(quay).marks;
        for (var ship = 0; ship < quay.count; ship++) {
          expect(marks.any(quay[ship].wantsIt), isTrue,
              reason: '${quay[ship].name} on ${quay.name} wants none of '
                  '$marks');
        }
      }
    });

    test('the ships it takes really do all fit', () {
      for (var number = 0; number < Days.count; number++) {
        final quay = Days.at(number).quay;
        expect(quay.allFit(Berthings.most(quay).taken), isTrue,
            reason: quay.name);
      }
    });
  });

  group('the rule against trying every set of ships', () {
    test('agree on five hundred days made up at random', () {
      final random = Random(4815162342);
      for (var go = 0; go < 500; go++) {
        final quay = _madeUp(random, many: 4 + random.nextInt(8));
        final rule = Berthings.most(quay).most;
        final trying = Berthings.byTrying(quay);
        expect(rule, trying,
            reason: 'the rule says $rule and trying every set says $trying on '
                '${quay.ships.map((ship) => '${ship.from}-${ship.to}')}');
      }
    });

    test('and the hours always catch every ship, whatever the day', () {
      final random = Random(90210);
      for (var go = 0; go < 500; go++) {
        final quay = _madeUp(random, many: 3 + random.nextInt(9));
        final berthing = Berthings.most(quay);
        expect(berthing.marks, hasLength(berthing.most));
        for (var ship = 0; ship < quay.count; ship++) {
          expect(berthing.marks.any(quay[ship].wantsIt), isTrue);
        }
      }
    });

    test('and the two obvious ways are never better, and often worse', () {
      final random = Random(1123581321);
      var worse = 0;
      for (var go = 0; go < 500; go++) {
        final quay = _madeUp(random, many: 4 + random.nextInt(8));
        final most = Berthings.most(quay).most;
        final arriving = Berthings.byArriving(quay).length;
        final shortest = Berthings.byShortest(quay).length;

        expect(arriving, lessThanOrEqualTo(most));
        expect(shortest, lessThanOrEqualTo(most));
        expect(quay.allFit(Berthings.byArriving(quay)), isTrue);
        expect(quay.allFit(Berthings.byShortest(quay)), isTrue);
        if (arriving < most || shortest < most) worse++;
      }
      expect(worse, greaterThan(100));
    });
  });

  group('every day that ships', () {
    for (var number = 0; number < Days.count; number++) {
      final day = Days.at(number);

      test('${day.name} says the number both ways say', () {
        expect(Berthings.most(day.quay).most, day.most);
        expect(Berthings.byTrying(day.quay), day.most);
      });

      test('${day.name} has ships that are named and want real hours', () {
        final quay = day.quay;
        expect(quay.ships.map((ship) => ship.name).toSet(),
            hasLength(quay.count));
        for (final ship in quay.ships) {
          expect(ship.from, greaterThanOrEqualTo(quay.opens));
          expect(ship.to, lessThanOrEqualTo(quay.shuts));
          expect(ship.hours, greaterThan(0));
        }
      });
    }

    test('and past the first two, both obvious ways come out short', () {
      for (var number = 2; number < Days.count; number++) {
        final day = Days.at(number);
        expect(Berthings.byArriving(day.quay).length, lessThan(day.most),
            reason: day.name);
        expect(Berthings.byShortest(day.quay).length, lessThan(day.most),
            reason: day.name);
      }
    });
  });

  group('working a day', () {
    late Play play;

    setUp(() => play = Play.of(Days.at(1).quay, Days.answerFor(1)));

    test('starts with an empty berth', () {
      expect(play.taken, isEmpty);
      expect(play.isDone, isFalse);
      expect(play.couldStillGet, play.most);
    });

    test('taking a ship puts it in the berth', () {
      play = play.take(1);
      expect(play.has(1), isTrue);
      expect(play.taken, [1]);
    });

    test('taking it again turns it away', () {
      play = play.take(1).take(1);
      expect(play.has(1), isFalse);
    });

    test('a ship that clashes cannot be taken, and it says which', () {
      play = play.take(0);
      expect(play.canTake(1), isFalse);
      expect(play.clashFor(1), 0);
      expect(identical(play.take(1), play), isTrue);
    });

    test('the day is over when nothing else will fit', () {
      play = play.take(0).take(4);
      expect(play.isDone, isTrue);
      expect(play.isMost, isFalse);
      expect(play.taken, hasLength(2));
    });

    test('and it says so before the day is over', () {
      // The Providence holds the berth from six to twelve, and two ships are
      // turned away for her.
      play = play.take(0);
      expect(play.couldStillGet, 2);
      expect(play.couldStillGet, lessThan(play.most));
    });

    test('taking a ship back out puts the day right again', () {
      play = play.take(0);
      expect(play.couldStillGet, lessThan(play.most));
      play = play.take(0);
      expect(play.couldStillGet, play.most);
    });

    test('show me works every day up to the most there is', () {
      for (var number = 0; number < Days.count; number++) {
        var walk = Play.of(Days.at(number).quay, Days.answerFor(number));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 40) fail('it never finished');
          final next = walk.next;
          expect(next, isNotNull, reason: Days.at(number).name);
          walk = walk.take(next!);
        }
        expect(walk.isMost, isTrue, reason: Days.at(number).name);
        expect(walk.taken, hasLength(Days.at(number).most),
            reason: Days.at(number).name);
      }
    });

    test('and it works days made up at random up to the most as well', () {
      final random = Random(24680);
      for (var go = 0; go < 150; go++) {
        final quay = _madeUp(random, many: 4 + random.nextInt(8));
        var walk = Play.of(quay, Berthings.most(quay));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 40) fail('it never finished');
          walk = walk.take(walk.next!);
        }
        expect(walk.taken, hasLength(Berthings.most(quay).most));
        expect(quay.allFit(walk.taken), isTrue);
      }
    });
  });
}
