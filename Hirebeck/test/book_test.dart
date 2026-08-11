import 'package:flutter_test/flutter_test.dart';
import 'package:hirebeck/book/days.dart';
import 'package:hirebeck/book/play.dart';
import 'package:hirebeck/book/rules.dart';

void main() {
  group('the clashes', () {
    test('overlapping hours clash, and an end may meet a start', () {
      final rules = Rules(const [8, 9, 10], const [10, 11, 12]);
      expect(rules.clash(0, 1), isTrue);
      expect(rules.clash(0, 2), isFalse);
      expect(rules.clash(1, 2), isTrue);
    });

    test('a choice stands only clash-free', () {
      final rules = Rules(const [8, 9, 10], const [10, 11, 12]);
      expect(rules.stands(0x5), isTrue);
      expect(rules.stands(0x3), isFalse);
    });
  });

  group('the three ways of knowing', () {
    test('the sweep, the early-finish rule and the strikes agree', () {
      // The anchor: on every shipped day the sweep's fullest, the
      // greedy book and the piercing count are one number.
      for (var number = 0; number < Days.count; number++) {
        final day = Days.at(number);
        final rules = Rules(day.starts, day.ends);
        final fullest = rules.fullestBySweep();
        expect(fullest, day.fullest, reason: day.name);
        expect(Rules.weigh(rules.byEarlyFinish()), fullest,
            reason: day.name);
        final strikes = rules.piercing();
        expect(strikes.length, fullest, reason: day.name);
        expect(rules.pierced(strikes), isTrue, reason: day.name);
      }
    });

    test('the strikes are a ceiling by counting alone', () {
      // Two hirings holding the same strike clash, so a clash-free
      // book holds at most one hiring per strike.
      final day = Days.at(4);
      final rules = Rules(day.starts, day.ends);
      final strikes = rules.piercing();
      for (final strike in strikes) {
        final holding = [
          for (var hiring = 0; hiring < day.hirings; hiring++)
            if (day.starts[hiring] < strike && strike <= day.ends[hiring])
              hiring,
        ];
        for (var one = 0; one < holding.length; one++) {
          for (var other = one + 1; other < holding.length; other++) {
            expect(rules.clash(holding[one], holding[other]), isTrue);
          }
        }
      }
    });

    test('the early-start rule falls into the traps', () {
      final trap = Days.at(1);
      final fair = Days.at(3);
      expect(
          Rules.weigh(Rules(trap.starts, trap.ends).byEarlyStart()), 2);
      expect(
          Rules.weigh(Rules(fair.starts, fair.ends).byEarlyStart()), 1);
    });
  });

  group('every day that ships', () {
    for (var number = 0; number < Days.count; number++) {
      final day = Days.at(number);

      test('${day.name} is what it says it is', () {
        final rules = Rules(day.starts, day.ends);
        expect(rules.fullestBySweep(), day.fullest);
        expect(rules.fullestWays(), day.ways);
        if (!day.winnable) {
          expect(day.ask, greaterThan(day.fullest));
        }
      });
    }
  });

  group('a book in play', () {
    test('starts empty', () {
      final play = Play.of(Days.at(0));
      expect(play.bookedCount, 0);
      expect(play.moves, 0);
      expect(play.isDone, isFalse);
    });

    test('a toggle books and cancels', () {
      var play = Play.of(Days.at(0)).toggle(0);
      expect(play.isBooked(0), isTrue);
      play = play.toggle(0);
      expect(play.isBooked(0), isFalse);
      expect(play.moves, 2);
    });

    test('clashes are seen the moment both stand booked', () {
      final play = Play.of(Days.at(0)).toggle(0).toggle(1);
      expect(play.clashes, [(0, 1)]);
      expect(play.isDone, isFalse);
    });

    test('take back returns the book as it stood', () {
      final start = Play.of(Days.at(0));
      final booked = start.toggle(0);
      expect(booked.back.bookedCount, 0);
      expect(identical(start.back, start), isTrue);
    });

    test('following next fills every winnable day', () {
      for (var number = 0; number < Days.count; number++) {
        final day = Days.at(number);
        if (!day.winnable) continue;
        var play = Play.of(day);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 20) fail('${day.name} never filled');
          play = play.toggle(play.next!);
        }
        expect(play.bookedCount, day.ask, reason: day.name);
        expect(play.clashes, isEmpty, reason: day.name);
      }
    });

    test('next cancels a stray booking before adding', () {
      // Book the trap: the all-morning fair committee is not in the
      // one full book.
      final play = Play.of(Days.at(1)).toggle(0);
      expect(play.next, 0);
    });

    test('the extra guest offers nothing and never fills', () {
      var play = Play.of(Days.at(4));
      expect(play.next, isNull);
      // Book the four that fit: still not done, the ask is five.
      play = play.toggle(1).toggle(2).toggle(3).toggle(5);
      expect(play.clashes, isEmpty);
      expect(play.bookedCount, 4);
      expect(play.isDone, isFalse);
    });
  });
}
