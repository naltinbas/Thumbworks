import 'package:flutter_test/flutter_test.dart';
import 'package:truckleford/yard/levels.dart';
import 'package:truckleford/yard/play.dart';
import 'package:truckleford/yard/rules.dart';

/// The yard itself: what the siding can make and what it cannot.
void main() {
  group('the siding', () {
    test('makes 132 of the 720 orders of six wagons', () {
      expect(Rules.howManyOrders(), 720);
      expect(Rules.orders().length, 720);
      expect(Rules.trains().length, 132);
    });

    test('makes an order exactly when the order is free of the shape', () {
      for (final train in Rules.orders()) {
        expect(Rules.canBeRun(train), !Rules.holdsPattern(train),
            reason: Rules.tellTrain(train));
      }
    });

    test('and the counts up to eight wagons are the Catalan numbers', () {
      // The yard itself only runs the six the game plays with; for the
      // other lengths this counts by the shape, which the checker holds
      // to a yard of that length.
      const catalan = [0, 1, 2, 5, 14, 42, 132, 429, 1430];
      for (var wagons = 1; wagons <= 8; wagons++) {
        var made = 0;
        for (final train in Rules.orders(wagons)) {
          if (!Rules.holdsPattern(train)) made++;
        }
        expect(made, catalan[wagons], reason: '$wagons wagons');
      }
    });

    test('cannot make 3, 1, 2 at the head, and six orders begin that way',
        () {
      var heads = 0;
      for (final train in Rules.orders()) {
        if (train[0] == 3 && train[1] == 1 && train[2] == 2) {
          heads++;
          expect(Rules.canBeRun(train), isFalse);
        }
      }
      expect(heads, 6);
      expect(Rules.canBeRun([3, 1, 2, 4, 5, 6]), isFalse);
      expect(Rules.pattern([3, 1, 2, 4, 5, 6]), [3, 1, 2]);
      expect(Rules.pattern([1, 2, 3, 4, 5, 6]), isNull);
    });

    test('the taps a train takes run from six to eleven', () {
      final spread = <int, int>{};
      for (final train in Rules.trains()) {
        final taps = Rules.tapsFor(train)!;
        spread[taps] = (spread[taps] ?? 0) + 1;
      }
      expect(spread, {6: 1, 7: 15, 8: 50, 9: 50, 10: 15, 11: 1});
      expect(Rules.tapsFor([1, 2, 3, 4, 5, 6]), 6);
      expect(Rules.tapsFor([6, 5, 4, 3, 2, 1]), 11);
      expect(Rules.tapsFor([3, 1, 2, 4, 5, 6]), isNull);
    });
  });

  group('the asks', () {
    test('are landed by as many out-trains as the sweep counted', () {
      for (final level in Levels.all) {
        var n = 0;
        for (final train in Rules.trains()) {
          if (level.meets(train)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('name the cheapest out-train that lands them', () {
      for (final level in Levels.all) {
        if (!level.winnable) {
          expect(level.aim, isNull, reason: level.name);
          continue;
        }
        expect(level.meets(level.aim!), isTrue, reason: level.name);
        expect(Rules.canBeRun(level.aim!), isTrue, reason: level.name);
        for (final train in Rules.trains()) {
          if (!level.meets(train)) continue;
          expect(Rules.tapsFor(train)!, greaterThanOrEqualTo(level.fewest!),
              reason: '${Rules.tellTrain(train)} against ${level.name}');
        }
      }
    });

    test('the fewest taps each one takes', () {
      expect([for (final level in Levels.all) level.fewest], [6, 7, 8, 11, null]);
    });

    test('the odd ones all leave 1, 3, 5 in that order', () {
      final odds = [
        for (final train in Rules.trains())
          if (Levels.at(2).meets(train)) train,
      ];
      expect(odds.length, 3);
      for (final train in odds) {
        expect(train.take(3), [1, 3, 5]);
      }
    });
  });

  group('a go', () {
    test('opens with every wagon on the line', () {
      final play = Play.of(Levels.at(0));
      expect(play.line, [1, 2, 3, 4, 5, 6]);
      expect(play.siding, isEmpty);
      expect(play.out, isEmpty);
      expect(play.moves, 0);
      expect(play.isClear, isFalse);
      expect(play.isDone, isFalse);
    });

    test('shunts, rolls and sends', () {
      var play = Play.of(Levels.at(1)).tap(Rules.shunt);
      expect(play.line, [2, 3, 4, 5, 6]);
      expect(play.siding, [1]);
      play = play.tap(Rules.roll);
      expect(play.out, [2]);
      play = play.tap(Rules.send);
      expect(play.out, [2, 1]);
      expect(play.siding, isEmpty);
      expect(play.moves, 3);
    });

    test('refuses a send with the siding empty and a shunt with the line clear',
        () {
      final play = Play.of(Levels.at(1));
      expect(identical(play.tap(Rules.send), play), isTrue);
      expect(identical(play.tap('nothing'), play), isTrue);
      var run = Play.of(Levels.at(1));
      for (var k = 0; k < Rules.wagons; k++) {
        run = run.tap(Rules.shunt);
      }
      expect(run.line, isEmpty);
      expect(identical(run.tap(Rules.shunt), run), isTrue);
      expect(identical(run.tap(Rules.roll), run), isTrue);
    });

    test('back undoes the last tap', () {
      final play = Play.of(Levels.at(1)).tap(Rules.shunt).tap(Rules.roll);
      expect(play.out, [2]);
      expect(play.back.out, isEmpty);
      expect(play.back.siding, [1]);
      expect(play.back.moves, 1);
      final opening = Play.of(Levels.at(1));
      expect(identical(opening.back, opening), isTrue);
    });

    test('a wedged go says so and cannot be worked further', () {
      final play = Play.of(Levels.at(3)).tap(Rules.roll);
      expect(play.out, [1]);
      expect(play.least, isNull);
      expect(play.wedged, isTrue);
      expect(play.isOver, isTrue);
      expect(identical(play.tap(Rules.shunt), play), isTrue);
      expect(play.back.wedged, isFalse);
    });

    test('the pointer lands every ask, in the fewest taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone) {
          final was = play.least!;
          final what = play.next!;
          play = play.tap(what);
          expect(play.least, was - 1, reason: level.name);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(level.meets(play.out), isTrue, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer says which lever', () {
      expect(Play.pointed(Rules.shunt),
          'Shunt the wagon at the head onto the siding.');
      expect(Play.pointed(Rules.roll),
          'Roll the wagon at the head straight out.');
      expect(Play.pointed(Rules.send), 'Send the wagon at the points out.');
    });

    test('the hopeless ask admits it once the points are set against it', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      expect(play.wedged, isFalse);
      for (final what in [
        Rules.shunt,
        Rules.shunt,
        Rules.shunt,
        Rules.send,
      ]) {
        play = play.tap(what);
      }
      expect(play.out, [3]);
      expect(play.siding, [1, 2]);
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(identical(play.tap(Rules.send), play), isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(1));
      for (var k = 0; k < 4; k++) {
        play = play.tap(Rules.shunt);
      }
      expect(play.gaveUp, isFalse);
      expect(play.wedged, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names Knuth and the shape', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains('Donald Knuth set this down in 1968'));
      expect(words, contains('no train of the shape 3, 1, 2'));
      expect(words, contains('Three, One, Two'));
    });
  });
}
