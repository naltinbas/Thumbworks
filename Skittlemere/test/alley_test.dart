import 'package:flutter_test/flutter_test.dart';
import 'package:skittlemere/alley/frames.dart';
import 'package:skittlemere/alley/play.dart';
import 'package:skittlemere/alley/rules.dart';

void main() {
  group('the counts', () {
    test('run the famous table', () {
      expect([for (var row = 0; row <= 15; row++) Rules.countOf(row)],
          [0, 1, 2, 3, 1, 4, 3, 2, 1, 4, 2, 6, 4, 1, 2, 7]);
    });

    test('an alley adds its rows the carry-less way', () {
      expect(Rules.countAlley(const [4, 7]), 1 ^ 2);
      expect(Rules.countAlley(const [6, 6]), 0);
      expect(Rules.countAlley(const [2, 3, 5]), 2 ^ 3 ^ 4);
    });

    test('the limp of twelve holds along the shipped stretch', () {
      for (var row = 83; row <= 200; row++) {
        expect(Rules.countOf(row), Rules.countOf(row - 12),
            reason: 'row $row');
      }
    });
  });

  group('the two ways of knowing', () {
    test('the search and the arithmetic never part to fourteen', () {
      // The anchor. The search knows nothing of counting; the
      // arithmetic never looks ahead.
      var shapes = 0;
      for (final shape in Rules.shapes(14)) {
        shapes++;
        expect(Rules.moverWins(shape), Rules.countAlley(shape) != 0,
            reason: '$shape');
      }
      expect(shapes, 507);
    });

    test('the mirror is a zero the arithmetic already knows', () {
      // Two equal rows count nought whatever the rows are.
      for (var row = 1; row <= 12; row++) {
        expect(Rules.countAlley([row, row]), 0);
        expect(Rules.moverWins([row, row]), isFalse);
      }
    });
  });

  group('every alley that ships', () {
    for (var number = 0; number < Frames.count; number++) {
      final frame = Frames.at(number);

      test('${frame.name} is what it says it is', () {
        expect(Rules.countAlley(frame.rows), frame.count);
        expect(Rules.moverWins(frame.rows), frame.winnable);
      });
    }
  });

  group('an alley in play', () {
    test('starts standing with the written count', () {
      final play = Play.of(Frames.at(1));
      expect(play.segments, [4, 7]);
      expect(play.count, 3);
      expect(play.knocks, 0);
      expect(play.isCleared, isFalse);
    });

    test('a knock fells one, a pair fells neighbours, splits show', () {
      var play = Play.of(Frames.at(0));
      play = play.knockOne(0, 2);
      expect(play.segments, [2, 2]);
      expect(play.count, 0);
      play = play.knockTwo(0, 0, 1);
      expect(play.segments, [2]);
      expect(identical(play.knockOne(0, 2), play), isTrue);
      expect(play.mayKnockTwo(0, 3, 4), isTrue);
    });

    test('no pair reaches across a gap', () {
      final play = Play.of(Frames.at(0)).knockOne(0, 2);
      expect(play.mayKnockTwo(0, 1, 2), isFalse);
      expect(play.mayKnockTwo(0, 1, 3), isFalse);
    });

    test('take back returns the alley as it stood', () {
      final start = Play.of(Frames.at(0));
      final knocked = start.knockOne(0, 0);
      expect(knocked.back.segments, [5]);
      expect(identical(start.back, start), isTrue);
    });

    test('the zeroing knock zeroes, wherever one exists', () {
      final play = Play.of(Frames.at(0));
      final knock = play.zeroing;
      expect(knock, isNotNull);
      final (row, pin, other) = knock!;
      final after =
          other < 0 ? play.knockOne(row, pin) : play.knockTwo(row, pin, other);
      expect(after.count, 0);
    });

    test('the even alley offers no zeroing knock, and the house '
        'always has one back', () {
      var play = Play.of(Frames.at(4));
      expect(play.zeroing, isNull);
      // Whatever the player knocks, the house zeroes: five rounds of
      // it, deterministically taking the first legal knock.
      var guard = 0;
      while (!play.isCleared) {
        if (guard++ > 12) fail('the alley never cleared');
        // The player knocks first legal.
        final (row, pin, other) = play.allKnocks.first;
        play =
            other < 0 ? play.knockOne(row, pin) : play.knockTwo(row, pin, other);
        if (play.isCleared) {
          fail('the player cleared the even alley from first-legal '
              'play, which the mirror should never allow');
        }
        final house = play.houseKnock!;
        play = house.$3 < 0
            ? play.knockOne(house.$1, house.$2)
            : play.knockTwo(house.$1, house.$2, house.$3);
        expect(play.count, 0, reason: 'the house left the count off '
            'nought');
      }
      // The house knocked last.
      expect(play.isCleared, isTrue);
    });

    test('following the zeroing knock wins every winnable alley', () {
      for (var number = 0; number < Frames.count; number++) {
        final frame = Frames.at(number);
        if (!frame.winnable) continue;
        var play = Play.of(frame);
        var guard = 0;
        while (!play.isCleared) {
          if (guard++ > 20) fail('${frame.name} never cleared');
          final knock = play.zeroing ?? play.allKnocks.first;
          final (row, pin, other) = knock;
          play = other < 0
              ? play.knockOne(row, pin)
              : play.knockTwo(row, pin, other);
          if (play.isCleared) break;
          final house = play.houseKnock!;
          play = house.$3 < 0
              ? play.knockOne(house.$1, house.$2)
              : play.knockTwo(house.$1, house.$2, house.$3);
          expect(play.isCleared, isFalse,
              reason: '${frame.name}: the house cleared it');
        }
        expect(play.isCleared, isTrue, reason: frame.name);
      }
    });
  });
}
