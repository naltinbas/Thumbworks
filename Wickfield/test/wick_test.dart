import 'package:flutter_test/flutter_test.dart';
import 'package:wickfield/wick/play.dart';
import 'package:wickfield/wick/rules.dart';
import 'package:wickfield/wick/wicks.dart';

void main() {
  group('the press', () {
    test('flips the lamp and its neighbours, clipped at the walls', () {
      final rules = Rules(3, 3);
      // The middle flips five; a corner flips three.
      expect(rules.crossOf(4), 0xBA);
      expect(rules.crossOf(0), 0x0B);
      expect(rules.press(0, 4), 0xBA);
    });

    test('undoes itself, and lands the same in any order', () {
      final rules = Rules(3, 3);
      for (var cell = 0; cell < 9; cell++) {
        expect(rules.press(rules.press(0x1C5, cell), cell), 0x1C5);
        for (var other = 0; other < 9; other++) {
          expect(rules.press(rules.press(0x1C5, cell), other),
              rules.press(rules.press(0x1C5, other), cell));
        }
      }
    });
  });

  group('the two ways of knowing', () {
    test('agree on every board of nine there is', () {
      // The anchor. The walk from dark knows nothing of algebra, the
      // elimination nothing of walking: 512 boards, no parting.
      final rules = Rules(3, 3);
      expect(rules.quiet, isEmpty);
      final walk = rules.byWalk();
      for (final board in rules.allBoards()) {
        expect(rules.fewest(board), walk[board], reason: 'board $board');
      }
    });

    test('and on every board of sixteen, quiet patterns and all', () {
      final rules = Rules(4, 4);
      expect(rules.quiet, hasLength(4));
      final walk = rules.byWalk();
      for (final board in rules.allBoards()) {
        expect(rules.fewest(board), walk[board], reason: 'board $board');
      }
    });
  });

  group('the quiet patterns', () {
    test('are truly quiet: pressed on the dark, they leave it dark', () {
      for (final (rows, cols) in const [(4, 4), (5, 5)]) {
        final rules = Rules(rows, cols);
        for (final pattern in rules.quiet) {
          expect(rules.pressAll(0, pattern), 0,
              reason: '$rows by $cols pattern $pattern');
        }
      }
    });

    test('the five-board keeps two, and both weigh even', () {
      final rules = Rules(5, 5);
      expect(rules.quiet, hasLength(2));
      for (final pattern in rules.quiet) {
        expect(Rules.weigh(pattern).isEven, isTrue);
      }
    });

    test('no press ever moves a board\'s parity against one', () {
      // The whole death certificate, swept: every quiet pattern, every
      // press, from boards easy and awkward.
      final rules = Rules(5, 5);
      for (final board in [0x1, 0x1FFFFFF, 0x155AA55, Wicks.at(5).lit]) {
        for (final pattern in rules.quiet) {
          final parity = rules.overlap(board, pattern).isOdd;
          for (var cell = 0; cell < 25; cell++) {
            expect(
              rules.overlap(rules.press(board, cell), pattern).isOdd,
              parity,
              reason: 'board $board cell $cell',
            );
          }
        }
      }
    });

    test('every full board goes dark all the same, as Sutner promised', () {
      for (final (rows, cols) in const [(3, 3), (4, 4), (5, 5)]) {
        final rules = Rules(rows, cols);
        expect(rules.fewest((1 << rules.cells) - 1), isNotNull,
            reason: '$rows by $cols');
      }
    });
  });

  group('every wick that ships', () {
    for (var number = 0; number < Wicks.count; number++) {
      final wick = Wicks.at(number);

      test('${wick.name} is what it says it is', () {
        final rules = Rules(wick.rows, wick.cols);
        final answers = rules.answers(wick.lit);
        expect(answers, hasLength(wick.ways));
        expect(rules.fewest(wick.lit), wick.fewest);
        for (final presses in answers) {
          expect(rules.pressAll(wick.lit, presses), 0);
        }
      });
    }

    test('the dead lamp is odd against a quiet pattern, and stays so', () {
      final wick = Wicks.at(5);
      final rules = Rules(5, 5);
      final pattern = rules.oddAgainst(wick.lit);
      expect(pattern, isNotNull);
      expect(rules.overlap(wick.lit, pattern!).isOdd, isTrue);
    });

    test('only five lamps could stand alone and go dark, as the dead '
        'board\'s note claims', () {
      final rules = Rules(5, 5);
      final alone = [
        for (var cell = 0; cell < 25; cell++)
          if (rules.solvable(1 << cell)) cell
      ];
      expect(alone, [6, 8, 12, 16, 18]);
    });

    test('the full five\'s four answers all weigh fifteen', () {
      final rules = Rules(5, 5);
      for (final presses in rules.answers(Wicks.at(4).lit)) {
        expect(Rules.weigh(presses), 15);
      }
    });
  });

  group('a board in play', () {
    test('starts as lit, with the fewest still to be had', () {
      final play = Play.of(Wicks.at(2));
      expect(play.lamps, 9);
      expect(play.pressed, 0);
      expect(play.isDark, isFalse);
      expect(play.fewestFromHere, 5);
    });

    test('a press flips the cross and counts', () {
      final play = Play.of(Wicks.at(0)).press(4);
      expect(play.isDark, isTrue);
      expect(play.pressed, 1);
      expect(identical(play.press(0), play), isTrue);
    });

    test('a wandering press shows in the live number at once', () {
      final play = Play.of(Wicks.at(1));
      expect(play.fewestFromHere, 4);
      expect(play.press(4).fewestFromHere, 5);
    });

    test('take back returns the board as it lay', () {
      final start = Play.of(Wicks.at(1));
      final pressed = start.press(0);
      expect(pressed.back.board, start.board);
      expect(identical(start.back, start), isTrue);
    });

    test('following next darkens every winnable wick at its fewest', () {
      for (var number = 0; number < Wicks.count; number++) {
        final wick = Wicks.at(number);
        if (!wick.winnable) continue;
        var play = Play.of(wick);
        var guard = 0;
        while (!play.isDark) {
          if (guard++ > 20) fail('${wick.name} never went dark');
          expect(play.fewestFromHere, wick.fewest! - play.pressed,
              reason: wick.name);
          play = play.press(play.next!);
        }
        expect(play.pressed, wick.fewest, reason: wick.name);
      }
    });

    test('the dead board offers nothing to press for', () {
      final play = Play.of(Wicks.at(5));
      expect(play.fewestFromHere, isNull);
      expect(play.next, isNull);
      expect(play.oddAgainst, isNotNull);
    });
  });
}
