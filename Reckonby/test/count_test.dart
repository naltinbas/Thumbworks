import 'package:flutter_test/flutter_test.dart';
import 'package:reckonby/count/levels.dart';
import 'package:reckonby/count/play.dart';
import 'package:reckonby/count/rules.dart';

/// The counting house itself: the wheels, the readings and the top.
void main() {
  int factorial(int n) {
    var out = 1;
    for (var k = 2; k <= n; k++) {
      out *= k;
    }
    return out;
  }

  group('the wheels', () {
    test('are worth the factorials and turn to their places', () {
      expect([for (var k = 1; k <= Rules.wheels; k++) Rules.worth(k)],
          [1, 2, 6, 24, 120]);
      expect([for (var k = 1; k <= Rules.wheels; k++) Rules.top(k)],
          [1, 2, 3, 4, 5]);
      expect(Rules.howManyReadings, 720);
      expect(Rules.most, 719);
      expect(Rules.most, factorial(Rules.wheels + 1) - 1);
    });

    test('the folding sum, out past the wheels the house has', () {
      for (var k = 1; k <= 12; k++) {
        expect(k * factorial(k), factorial(k + 1) - factorial(k));
        var added = 0;
        for (var i = 1; i <= k; i++) {
          added += i * factorial(i);
        }
        expect(added, factorial(k + 1) - 1, reason: 'the sum to $k');
      }
    });

    test('will not turn past a stop', () {
      expect(Rules.valid([1, 2, 3, 4, 5]), isTrue);
      expect(Rules.valid([2, 2, 3, 4, 5]), isFalse);
      expect(Rules.valid([0, 0, 0, 0, 6]), isFalse);
      expect(Rules.valid([0, -1, 0, 0, 0]), isFalse);
    });
  });

  group('the readings', () {
    test('give every number to 719, each exactly once', () {
      final all = Rules.readings();
      expect(all.length, 720);
      final seen = <int>{};
      for (var tick = 0; tick < all.length; tick++) {
        final number = Rules.reading(all[tick]);
        // The tick a setting falls on is what it reads: the odometer
        // and the adding agree.
        expect(number, tick, reason: '${all[tick]}');
        expect(seen.add(number), isTrue, reason: '$number read twice');
        expect(Rules.wheelsFor(number), all[tick]);
      }
      expect(seen.length, 720);
      for (var number = 0; number <= Rules.most; number++) {
        expect(seen.contains(number), isTrue, reason: '$number');
      }
    });

    test('stop at the top', () {
      expect(Rules.wheelsFor(720), isNull);
      expect(Rules.wheelsFor(-1), isNull);
      expect(Rules.tickUp([1, 2, 3, 4, 5]), isNull);
      expect(Rules.tickUp([1, 2, 3, 4, 0]), [0, 0, 0, 0, 1]);
      expect(Rules.tickUp([0, 0, 0, 0, 0]), [1, 0, 0, 0, 0]);
    });

    test('the wheels under one come to one less than it is worth', () {
      for (var k = 2; k <= Rules.wheels; k++) {
        var under = 0;
        for (var i = 1; i < k; i++) {
          under += Rules.top(i) * Rules.worth(i);
        }
        expect(under, Rules.worth(k) - 1, reason: 'under wheel $k');
      }
    });

    test('the numbers the asks name', () {
      expect(Rules.wheelsFor(42), [0, 0, 3, 1, 0]);
      expect(Rules.wheelsFor(100), [0, 2, 0, 4, 0]);
      expect(Rules.wheelsFor(500), [0, 1, 3, 0, 4]);
      expect(Rules.reading([1, 2, 3, 4, 5]), 719);
    });
  });

  group('the asks', () {
    test('are read by one setting each, or none', () {
      for (final level in Levels.all) {
        var n = 0;
        for (final at in Rules.readings()) {
          if (level.meets(at)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('the fewest turns is the wheels of the number added up', () {
      expect([for (final level in Levels.all) level.fewest],
          [4, 6, 8, 15, null]);
      for (final level in Levels.all.where((l) => l.winnable)) {
        var added = 0;
        for (final wheel in level.aim!) {
          added += wheel;
        }
        expect(level.fewest, added, reason: level.name);
      }
    });

    test('none of them is read before a wheel is turned', () {
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('opens with every wheel at nothing', () {
      final play = Play.of(Levels.at(0));
      expect(play.wheels, [0, 0, 0, 0, 0]);
      expect(play.reading, 0);
      expect(play.under, 719);
      expect(play.moves, 0);
      expect(play.isDone, isFalse);
    });

    test('a turn moves one wheel and counts', () {
      final play = Play.of(Levels.at(0)).turn(3, 1);
      expect(play.wheels, [0, 0, 1, 0, 0]);
      expect(play.reading, 6);
      expect(play.moves, 1);
    });

    test('refuses a turn past a stop', () {
      final play = Play.of(Levels.at(3));
      expect(identical(play.turn(1, -1), play), isTrue);
      expect(identical(play.turn(1, 0), play), isTrue);
      final full = Play.standing(Levels.at(3), const [1, 2, 3, 4, 5]);
      expect(identical(full.turn(5, 1), full), isTrue);
    });

    test('back undoes the last turn', () {
      final play = Play.of(Levels.at(3)).turn(5, 1).turn(4, 1);
      expect(play.reading, 144);
      expect(play.back.reading, 120);
      expect(play.back.moves, 1);
      final opening = Play.of(Levels.at(3));
      expect(identical(opening.back, opening), isTrue);
    });

    test('the pointer lands every ask, in the fewest turns', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone) {
          final was = play.toGo!;
          final aim = play.next!;
          play = play.turn(aim.$1, aim.$2);
          expect(play.toGo, was - 1, reason: level.name);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer says which wheel and which way', () {
      expect(Play.pointed((3, 1)), 'Turn the 3! wheel up one.');
      expect(Play.pointed((5, -1)), 'Turn the 5! wheel down one.');
    });

    test('the hopeless ask admits it after four readings', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      expect(play.toGo, isNull);
      for (final wheel in [1, 2, 3, 4]) {
        play = play.turn(wheel, 1);
      }
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(identical(play.turn(5, 1), play), isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (final wheel in [1, 2, 3, 4]) {
        play = play.turn(wheel, 1);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names the folding sum and the one way', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains('6 factorial less 1 factorial'));
      expect(words, contains('every number below it reads exactly one way'));
      expect(words, contains('Seven Hundred and Twenty'));
    });
  });
}
