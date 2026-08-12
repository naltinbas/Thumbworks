import 'package:flutter_test/flutter_test.dart';
import 'package:braidfell/braid/play.dart';
import 'package:braidfell/braid/rules.dart';
import 'package:braidfell/braid/yards.dart';

void main() {
  group('the reckonings', () {
    test('lightest-first, worked by hand', () {
      expect(Rules.lightestFirst([1, 2, 3]), 9);
      expect(Rules.lightestFirst([1, 1, 1, 1]), 8);
      expect(Rules.lightestFirst([1, 2, 4, 8, 16]), 56);
      expect(Rules.lightestFirst([2, 3, 5, 7, 11]), 60);
    });

    test('the sweep agrees with the rule on every yard', () {
      for (final yard in Yards.all) {
        expect(
          Rules.leastWork(yard.bundles),
          Rules.lightestFirst(yard.bundles),
          reason: yard.name,
        );
        expect(Rules.leastWork(yard.bundles), yard.least,
            reason: yard.name);
      }
    });

    test('the dearest orders, for the spread', () {
      expect(Rules.mostWork([1, 2, 3]), 11);
      expect(Rules.mostWork([1, 1, 1, 1]), 9);
      expect(Rules.mostWork([1, 2, 4, 8, 16]), 113);
      expect(Rules.mostWork([2, 3, 5, 7, 11]), 95);
    });

    test('the order counts', () {
      expect(Rules.orders(3), 3);
      expect(Rules.orders(4), 18);
      expect(Rules.orders(5), 180);
    });
  });

  group('a yard', () {
    test('a braid joins two bundles and costs their weights', () {
      var play = Play.of(Yards.at(0));
      play = play.braid(0, 1);
      expect(play.bundles, [3, 3]);
      expect(play.work, 3);
      expect(play.back.bundles, [1, 2, 3]);
      play = play.braid(0, 1);
      expect(play.isDone, isTrue);
      expect(play.work, 9);
      expect(play.met, isTrue);
    });

    test('a dear order finishes over the asking', () {
      var play = Play.of(Yards.at(0));
      play = play.braid(1, 2).braid(0, 1);
      expect(play.isDone, isTrue);
      expect(play.work, 11);
      expect(play.met, isFalse);
    });

    test('the floor rises past the asking on a wrong turn', () {
      final play = Play.of(Yards.at(1));
      expect(play.floor, 8);
      // A pair with a single: the yard can no longer land eight.
      final wandered = play.braid(0, 1).braid(0, 2);
      expect(wandered.floor, greaterThan(8));
    });

    test('the pointer names the two lightest', () {
      final play = Play.of(Yards.at(3));
      final (one, two) = play.lightest!;
      expect({play.bundles[one], play.bundles[two]}, {2, 3});
    });

    test('following the pointer meets every winnable asking '
        'exactly', () {
      for (final yard in Yards.all.where((yard) => yard.winnable)) {
        var play = Play.of(yard);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 8) fail('${yard.name} never finished');
          final (one, two) = play.lightest!;
          play = play.braid(one, two);
        }
        expect(play.work, yard.least, reason: yard.name);
        expect(play.met, isTrue, reason: yard.name);
      }
    });

    test('the fifty-nine cannot be met by any order', () {
      final yard = Yards.at(4);
      expect(yard.winnable, isFalse);
      var play = Play.of(yard);
      expect(play.floor, 60);
      while (!play.isDone) {
        final (one, two) = play.lightest!;
        play = play.braid(one, two);
      }
      expect(play.work, 60);
      expect(play.met, isFalse);
    });
  });
}
