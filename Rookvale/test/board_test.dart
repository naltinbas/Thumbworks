import 'package:flutter_test/flutter_test.dart';
import 'package:rookvale/board/board.dart';
import 'package:rookvale/board/pieces.dart';
import 'package:rookvale/board/play.dart';
import 'package:rookvale/board/puzzles.dart';
import 'package:rookvale/board/solve.dart';

void main() {
  group('reading a board', () {
    test('puts the pieces where the picture says', () {
      final board = Board.picture(const ['R..N', '....', '..P.', 'K...']);
      expect(board.side, 4);
      expect(board.at(0), Piece.rook);
      expect(board.at(3), Piece.knight);
      expect(board.at(10), Piece.pawn);
      expect(board.at(12), Piece.king);
      expect(board.count, 4);
    });
  });

  group('how the pieces take', () {
    List<int> takesOn(List<String> rows, int from) =>
        Board.picture(rows).moves.where((m) => m.from == from).map((m) => m.to).toList()
          ..sort();

    test('a pawn takes one square diagonally forwards, and only forwards', () {
      // Up the page is forwards. The pawn on 9 can take on 4 and 6, and never
      // on 12 or 14 behind it.
      expect(takesOn(const ['....', 'P.P.', '.P..', 'P.P.'], 9), [4, 6]);
    });

    test('a knight takes two one way and one the other', () {
      expect(takesOn(const ['.P.P', 'P..P', '..N.', 'P.P.'], 10), [1, 3, 4, 12]);
    });

    test('a king takes one square any way', () {
      expect(takesOn(const ['PPP.', 'PKP.', 'PPP.', '....'], 5),
          [0, 1, 2, 4, 6, 8, 9, 10]);
    });

    test('a rook takes along a line, and only the first piece on it', () {
      // Two pawns up the same file: only the near one can be taken.
      expect(takesOn(const ['.P..', '.P..', '.R.P', '....'], 9), [5, 11]);
    });

    test('a bishop takes along a diagonal, and only the first piece on it', () {
      expect(takesOn(const ['P...', '.P..', '..B.', '.P.P'], 10), [5, 13, 15]);
    });

    test('a queen takes both ways, and still over nothing', () {
      // Up the file, along the rank, and up the diagonal — three pawns and
      // three captures.
      expect(takesOn(const ['P.P.', '....', 'P.Q.', '....'], 10), [0, 2, 8]);
    });

    test('and nothing takes an empty square', () {
      final board = Board.picture(const ['R...', '....', '....', '....']);
      expect(board.moves, isEmpty, reason: 'there is nothing to take');
    });
  });

  group('a capture', () {
    test('puts the taker on the square it took', () {
      final board = Board.picture(const ['R..N', '....', '....', '....'])
          .after(const Move(0, 3));
      expect(board.at(3), Piece.rook);
      expect(board.at(0), isNull);
      expect(board.count, 1);
    });

    test('and a move that is not a capture changes nothing', () {
      final board = Board.picture(const ['R..N', '....', '....', '....']);
      expect(board.after(const Move(0, 1)).sameness, board.sameness);
      expect(board.after(const Move(5, 3)).sameness, board.sameness);
    });

    test('one piece left is finished, and stuck is not', () {
      expect(Board.picture(const ['R...', '....']).isDone, isTrue);
      final stuck = Board.picture(const ['R...', '....', '....', '...N']);
      expect(stuck.isDone, isFalse);
      expect(stuck.isStuck, isTrue, reason: 'neither can reach the other');
    });
  });

  group('every puzzle', () {
    test('has exactly one way through it', () {
      // The whole design. Two ways and a player can stumble into the end
      // without working anything out; none and the puzzle is a mistake. The
      // tree is walked entire — every move takes a piece off, so no line is
      // longer than the pieces and nothing can come round again.
      for (var i = 0; i < Puzzles.count; i++) {
        final puzzle = Puzzles.at(i);
        final ways = waysThrough(puzzle.board);
        expect(ways.count, 1,
            reason: '${puzzle.name} has ${ways.count} ways through');
      }
    });

    test('takes as many captures as it says, and one fewer than its pieces',
        () {
      for (var i = 0; i < Puzzles.count; i++) {
        final puzzle = Puzzles.at(i);
        expect(puzzle.takes, puzzle.board.count - 1, reason: puzzle.name);
        expect(waysThrough(puzzle.board).first, hasLength(puzzle.takes),
            reason: puzzle.name);
      }
    });

    test('and the way through it really works when it is played', () {
      for (var i = 0; i < Puzzles.count; i++) {
        final puzzle = Puzzles.at(i);
        var board = puzzle.board;
        for (final move in waysThrough(board).first) {
          expect(board.moves, contains(move),
              reason: '${puzzle.name}: $move cannot be made');
          board = board.after(move);
        }
        expect(board.isDone, isTrue, reason: puzzle.name);
      }
    });

    test('gives more than one thing to try at the start', () {
      // One way through and one move available is not a puzzle, it is a
      // corridor.
      for (var i = 0; i < Puzzles.count; i++) {
        final puzzle = Puzzles.at(i);
        expect(puzzle.board.moves.length, greaterThan(2),
            reason: '${puzzle.name} has nothing to get wrong');
      }
    });
  });

  group('playing one', () {
    Play start([int which = 0]) => Play.of(Puzzles.at(which));

    test('starts on the board it ships with', () {
      final play = start();
      expect(play.board.sameness, Puzzles.at(0).board.sameness);
      expect(play.taken, 0);
      expect(play.isOver, isFalse);
    });

    test('takes a capture and counts it', () {
      final play = start().after(const Move(4, 1));
      expect(play.taken, 1);
      expect(play.board.count, 3);
    });

    test('takes one back, and starts over', () {
      final play = start().after(const Move(4, 1));
      expect(play.back.taken, 0);
      expect(play.back.board.sameness, Puzzles.at(0).board.sameness);
      expect(play.back.back.taken, 0, reason: 'and stops at the start');
      expect(play.again.taken, 0);
    });

    test('is finished when one piece is left', () {
      var play = start();
      for (final move in waysThrough(play.board).first) {
        play = play.after(move);
      }
      expect(play.isDone, isTrue);
      expect(play.taken, Puzzles.at(0).takes);
    });

    test('and knows at once when it can no longer be finished', () {
      // The wrong first capture on a puzzle with one way through leaves a
      // board that cannot be finished, and the whole tree from there is small
      // enough to say so exactly rather than to guess.
      final right = waysThrough(Puzzles.at(0).board).first.first;
      final wrong = Puzzles.at(0)
          .board
          .moves
          .firstWhere((move) => move != right);

      expect(start().after(right).canStillBeDone, isTrue);
      expect(start().after(wrong).canStillBeDone, isFalse);
      expect(start().after(wrong).nextTake, isNull);
    });

    test('and points at a capture that is really on the way through', () {
      for (var which = 0; which < Puzzles.count; which++) {
        var play = Play.of(Puzzles.at(which));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          final next = play.nextTake;
          expect(next, isNotNull, reason: '${Puzzles.at(which).name} ran out');
          play = play.after(next!);
        }
        expect(play.isDone, isTrue);
        expect(play.taken, Puzzles.at(which).takes);
      }
    });
  });
}
