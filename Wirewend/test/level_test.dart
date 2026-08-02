import 'package:flutter_test/flutter_test.dart';
import 'package:wirewend/game/grid.dart';
import 'package:wirewend/game/levels.dart';

/// Two boards are the same puzzle when every cell is the same thing pointing
/// the same way. There is no equality on Board, and there should not be: the
/// game never compares boards, only tests do.
void expectSamePuzzle(Board a, Board b, {required String reason}) {
  expect(a.rows, b.rows, reason: reason);
  expect(a.cols, b.cols, reason: reason);
  for (var row = 0; row < a.rows; row++) {
    for (var col = 0; col < a.cols; col++) {
      expect(a.at(row, col).kind, b.at(row, col).kind, reason: reason);
      expect(a.at(row, col).ends, b.at(row, col).ends, reason: reason);
    }
  }
}

void main() {
  group('a numbered level', () {
    test('builds the same board every time it is asked for it', () {
      for (final number in [1, 7, 23]) {
        expectSamePuzzle(
          Level.forNumber(number).board(),
          Level.forNumber(number).board(),
          reason: 'level $number',
        );
      }
    });

    test('builds a different board from its neighbours', () {
      // Not a claim about randomness, just that the seed moves with the level
      // number rather than the size, which is what two levels of the same
      // shape would otherwise share.
      final seven = Level.forNumber(7).board();
      final eight = Level.forNumber(8).board();
      var differences = 0;
      for (var row = 0; row < seven.rows; row++) {
        for (var col = 0; col < seven.cols; col++) {
          if (seven.at(row, col).ends != eight.at(row, col).ends) differences++;
        }
      }
      expect(differences, greaterThan(0));
    });

    test('hands every level a puzzle with something left to do', () {
      // Well past the point where the board stops growing, because from
      // there on a level is only its seed, and a seed that happened to
      // scramble back into the answer would hand the player a level that was
      // over before they touched it.
      for (var number = 1; number <= 300; number++) {
        final board = Level.forNumber(number).board();
        expect(board.lampCount, greaterThan(0), reason: 'level $number');
        expect(board.isSolved, isFalse, reason: 'level $number');
      }
    });

    test('opens the first level when the saved number makes no sense', () {
      expect(Level.forNumber(0).number, 1);
      expect(Level.forNumber(-12).number, 1);
    });
  });

  group('the run of levels', () {
    test('grows, never shrinks', () {
      var previous = Level.forNumber(1);
      for (var number = 2; number <= 40; number++) {
        final level = Level.forNumber(number);
        expect(level.rows, greaterThanOrEqualTo(previous.rows),
            reason: 'level $number');
        expect(level.cols, greaterThanOrEqualTo(previous.cols),
            reason: 'level $number');
        expect(level.fill, greaterThanOrEqualTo(previous.fill),
            reason: 'level $number');
        previous = level;
      }
    });

    test('starts small enough to teach and ends up several times bigger', () {
      final first = Level.forNumber(1);
      expect(first.rows * first.cols, lessThanOrEqualTo(9));

      final late = Level.forNumber(20);
      expect(late.rows * late.cols, greaterThan(first.rows * first.cols * 4));
      expect(late.fill, greaterThan(first.fill));
    });

    test('stops growing before a tile gets too small for a thumb', () {
      // A narrow phone is 360 logical pixels across and the board keeps a
      // margin, so this is the number of columns that still leaves a tile
      // worth aiming at. Rows are allowed further because phones are tall.
      for (var number = 1; number <= 200; number++) {
        final level = Level.forNumber(number);
        expect(level.cols, lessThanOrEqualTo(6), reason: 'level $number');
        expect(level.rows, lessThanOrEqualTo(9), reason: 'level $number');
        expect(level.fill, lessThanOrEqualTo(1.0), reason: 'level $number');
      }
    });

    test('counts on from the level it is asked about', () {
      expect(Level.forNumber(5).next.number, 6);
    });
  });
}
