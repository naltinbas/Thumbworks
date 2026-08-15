import 'package:flutter_test/flutter_test.dart';
import 'package:fridayford/almanac/levels.dart';
import 'package:fridayford/almanac/play.dart';
import 'package:fridayford/almanac/rules.dart';

/// The law of the almanac, held to.
void main() {
  group('the rules', () {
    test('the thirteenths follow the first of January', () {
      // A common year beginning on a Thursday, like 2026: Fridays in
      // February, March and November.
      expect(Rules.thirteenths(3, false)[0], 1);
      expect(Rules.fridays(3, false), [1, 2, 10]);
      expect(Rules.fridays(6, true), [0, 3, 6]);
      expect(Rules.fridays(2, false), [5]);
      expect(Rules.offsets(false), [0, 3, 3, 6, 1, 4, 6, 2, 5, 0, 3, 5]);
      expect(Rules.offsets(true), [0, 3, 4, 0, 2, 5, 0, 3, 6, 1, 4, 6]);
      expect(Rules.offsets(false).toSet(), hasLength(7));
      expect(Rules.offsets(true).toSet(), hasLength(7));
    });

    test('the fourteen kinds, one to three Fridays each', () {
      expect(Rules.kinds, hasLength(14));
      for (final (_, f) in Rules.kinds) {
        expect(f.length, inInclusiveRange(1, 3));
      }
      expect(Rules.sweep((f) => f.length == 1), (6, 14));
      expect(Rules.sweep((f) => f.length == 2), (6, 14));
      expect(Rules.sweep((f) => f.length == 3), (2, 14));
      expect(Rules.sweep((f) => f.isEmpty), (0, 14));
      expect(Rules.sweep((f) => f.contains(10)), (2, 14));
    });

    test('real years by the calendar itself', () {
      final ((first, isLeap), fridays) = Rules.real(2026);
      expect(first, 3);
      expect(isLeap, isFalse);
      expect(fridays, [1, 2, 10]);
      for (var y = 1990; y <= 2040; y++) {
        final ((f, l), fr) = Rules.real(y);
        expect(fr, Rules.fridays(f, l), reason: '$y');
        expect(fr.length, inInclusiveRange(1, 3), reason: '$y');
      }
      expect(Rules.real(2024).$1.$2, isTrue);
      expect(Rules.real(2015).$2, [1, 2, 10]);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(Rules.sweep(level.meets), (level.ways, level.kinds), reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens on a common year that does not meet the ask', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.start, level.startDay, reason: level.name);
        expect(play.isLeap, isFalse);
        expect(play.isDone, isFalse, reason: level.name);
      }
      expect(Play.of(Levels.at(0)).fridays, [3, 6]);
      expect(Play.of(Levels.at(1)).fridays, [5]);
    });

    test('a day on, a leap toggled, counted; back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.nextDay;
      expect(play.start, 1);
      expect(play.moves, 1);
      play = play.toggleLeap;
      expect(play.isLeap, isTrue);
      expect(play.moves, 2);
      expect(play.back.isLeap, isFalse);
      var round = Play.of(Levels.at(4));
      for (var k = 0; k < 7; k++) {
        round = round.nextDay;
      }
      expect(round.start, 0);
      expect(round.moves, 7);
    });

    test('the asks by hand', () {
      final three = Play.of(Levels.at(2)).nextDay.nextDay.nextDay;
      expect(three.start, 3);
      expect(three.isDone, isTrue);
      expect(three.nextDay, same(three));
      final one = Play.of(Levels.at(0)).nextDay.nextDay;
      expect(one.fridays, [5]);
      expect(one.isDone, isTrue);
      final november = Play.of(Levels.at(3)).nextDay.nextDay.toggleLeap;
      expect(november.isDone, isTrue);
    });

    test('the pointer sets every winnable ask', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 16) {
          play = play.next == 'day' ? play.nextDay : play.toggleLeap;
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer takes the shorter road', () {
      // Two Fridays opens on a common Wednesday, one Friday; a leap
      // Wednesday has two, one tap, while the next common day with two
      // is Sunday, four taps: the pointer says leap.
      final play = Play.of(Levels.at(1));
      expect(play.fridays, [5]);
      expect(play.next, 'leap');
      expect(play.toggleLeap.isDone, isTrue);
    });

    test('the hopeless ask admits it after fourteen taps', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 14; k++) {
        play = k == 6 ? play.toggleLeap : play.nextDay;
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.nextDay, same(play));
    });

    test('the mark stands with three Fridays', () {
      final mark = Play.standing(Levels.at(2), 3, false);
      expect(mark.isDone, isTrue);
      expect(mark.fridays, [1, 2, 10]);
    });
  });
}
