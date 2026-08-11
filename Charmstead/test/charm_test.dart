import 'package:charmstead/charm/charms.dart';
import 'package:charmstead/charm/play.dart';
import 'package:charmstead/charm/rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the lines', () {
    test('are the three rows, three columns and two crossways', () {
      expect(Rules.lines, hasLength(8));
      expect(Rules.holds(const [4, 9, 2, 3, 5, 7, 8, 1, 6]), isTrue);
      expect(Rules.holds(const [1, 2, 3, 4, 5, 6, 7, 8, 9]), isFalse);
    });
  });

  group('the two ways of knowing', () {
    test('the sweep finds eight charms, and the counting owns them', () {
      // The anchor: every filling tried, knowing no arithmetic.
      final all = Rules.allCharms();
      expect(all, hasLength(8));
      for (final charm in all) {
        // The counting: three rows partition forty five, so each
        // counts fifteen; the four heart lines count sixty, which is
        // forty five plus two more hearts, so the heart is five.
        expect(charm[4], 5, reason: '$charm');
        for (final line in Rules.lines) {
          expect(charm[line[0]] + charm[line[1]] + charm[line[2]], 15);
        }
      }
    });

    test('the eight are one square eight ways round', () {
      final all = Rules.allCharms();
      final swept = {for (final charm in all) charm.join(',')};
      for (final turning in Rules.turnings) {
        expect(swept,
            contains(Rules.turned(all.first, turning).join(',')));
      }
    });

    test('the heart of one and the heavy row hold nothing', () {
      expect(Rules.charmsUnder(const {4: 1}), isEmpty);
      expect(Rules.charmsUnder(const {0: 9, 1: 8}), isEmpty);
      // The heavy row's arithmetic: the third coin would be minus
      // two.
      expect(15 - 9 - 8, -2);
    });
  });

  group('every charm that ships', () {
    for (var number = 0; number < Charms.count; number++) {
      final charm = Charms.at(number);

      test('${charm.name} is what it says it is', () {
        expect(Rules.charmsUnder(charm.pins), hasLength(charm.ways));
      });
    }
  });

  group('a charm in play', () {
    test('starts with the pins laid and the tray full otherwise', () {
      final play = Play.of(Charms.at(3));
      expect(play.laid[0], 4);
      expect(play.laid[4], isNull);
      expect(play.tray, [1, 3, 5, 6, 7, 8]);
      expect(play.isDone, isFalse);
    });

    test('a coin lays on a bare cell and lifts back, pins excepted', () {
      var play = Play.of(Charms.at(1));
      play = play.lay(0, 8);
      expect(play.laid[0], 8);
      expect(play.tray, isNot(contains(8)));
      play = play.lift(0);
      expect(play.laid[0], isNull);
      expect(identical(play.lift(4), play), isTrue);
      expect(play.moves, 2);
    });

    test('a laid coin cannot lay twice, nor on a held cell', () {
      final play = Play.of(Charms.at(1)).lay(0, 8);
      expect(play.mayLay(1, 8), isFalse);
      expect(play.mayLay(0, 7), isFalse);
      expect(play.mayLay(4, 7), isFalse);
    });

    test('take back returns the bed as it lay', () {
      final start = Play.of(Charms.at(0));
      final laid = start.lay(0, 2);
      expect(laid.back.laid[0], isNull);
      expect(identical(start.back, start), isTrue);
    });

    test('a broken line is seen the moment it finishes', () {
      final play =
          Play.of(Charms.at(0)).lay(0, 1).lay(1, 2).lay(2, 3);
      expect(play.broken, [0]);
      expect(play.lineCount(0), (6, true));
    });

    test('following next sets every winnable charm', () {
      for (var number = 0; number < Charms.count; number++) {
        final charm = Charms.at(number);
        if (!charm.winnable) continue;
        var play = Play.of(charm);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 20) fail('${charm.name} never held');
          final (cell, coin) = play.next!;
          play = coin == null ? play.lift(cell) : play.lay(cell, coin);
        }
        expect(play.broken, isEmpty, reason: charm.name);
      }
    });

    test('next mends a wrong coin before filling on', () {
      // Lay a coin the one written-row charm does not want there.
      final play = Play.of(Charms.at(3)).lay(4, 1);
      final (cell, coin) = play.next!;
      expect(cell, 4);
      expect(coin, isNull);
    });

    test('the dead charms offer nothing and never hold', () {
      for (final number in const [4, 5]) {
        var play = Play.of(Charms.at(number));
        expect(play.next, isNull);
        for (final coin in [...play.tray]) {
          final cell = play.laid.indexOf(null);
          play = play.lay(cell, coin);
        }
        expect(play.isFull, isTrue);
        expect(play.isDone, isFalse);
        expect(play.broken, isNotEmpty);
      }
    });
  });
}
