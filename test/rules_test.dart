import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thornguard/game/board.dart';

import 'support/plainly.dart';

/// A random game, played to the end or until it goes on too long.
///
/// Random play is a poor player and an excellent test: it wanders into
/// positions nobody would design, which is where rules written slightly wrong
/// are found.
List<Board> randomGame(int seed, {int most = 120}) {
  final random = Random(seed);
  var board = Board.opening();
  final seen = <Board>[board];
  while (!board.isOver && seen.length < most) {
    final moves = board.moves;
    board = board.play(moves[random.nextInt(moves.length)]);
    seen.add(board);
  }
  return seen;
}

void main() {
  group('the opening', () {
    test('has the men it should, in the shape it should', () {
      final board = Board.opening();
      expect(board.count(Piece.raider), 12);
      expect(board.count(Piece.guard), 4);
      expect(board.count(Piece.king), 1);
      expect(board.kingAt, Board.throne);
      expect(board.turn, Side.raiders);
      expect(board.isOver, isFalse);
    });

    test('gives the raiders somewhere to go', () {
      expect(Board.opening().moves, isNotEmpty);
    });
  });

  group('moving', () {
    test('is along a row or column, over nothing', () {
      final board = Board.of(const [
        '       ',
        '       ',
        '   R   ',
        '  RGR  ',
        '   K   ',
        '       ',
        '       ',
      ], turn: Side.guards);

      final guard = const Square(3, 3);
      // Hemmed in on all four sides, and the throne it stands on is not a
      // square it may return to anyway.
      expect(board.moves.where((m) => m.from == guard), isEmpty);
    });

    test('may not finish on a corner or the throne, unless it is the king', () {
      final board = Board.of(const [
        'R      ',
        '       ',
        '       ',
        '       ',
        '       ',
        '       ',
        '      K',
      ], turn: Side.raiders);

      final corners = board.moves.where((m) => Board.isCorner(m.to));
      expect(corners, isEmpty, reason: 'a raider may not sit in a corner');
      expect(board.moves.where((m) => m.to == Board.throne), isEmpty);

      final kings = Board.of(const [
        'R      ',
        '       ',
        '       ',
        '       ',
        '       ',
        '       ',
        '      K',
      ], turn: Side.guards);
      expect(
        kings.moves.where((m) => Board.isCorner(m.to)),
        isNotEmpty,
        reason: 'the king may',
      );
    });
  });

  group('taking', () {
    test('a piece moved between two enemies is sandwiched', () {
      final board = Board.of(const [
        '       ',
        '  R    ',
        '  G    ',
        '   K   ',
        '       ',
        '  R    ',
        '       ',
      ], turn: Side.raiders);

      // The raider comes up to (3,2) and the guard above it is pinned against
      // the raider on (1,2).
      final after = board.play(const Move(Square(5, 2), Square(3, 2)));
      expect(after.at(const Square(2, 2)), isNull);
      expect(after.count(Piece.guard), 0);
    });

    test('a piece that moves between two enemies itself is safe', () {
      // The rule that makes the game playable. Without it half the board is
      // poisoned and neither side can develop.
      final board = Board.of(const [
        '       ',
        '       ',
        '  R R  ',
        '   K   ',
        '  G    ',
        '       ',
        '       ',
      ], turn: Side.guards);

      final after = board.play(const Move(Square(4, 2), Square(2, 3)));
      expect(after.at(const Square(2, 3)), Piece.guard,
          reason: 'walking into the sandwich is not being sandwiched');
    });

    test('a corner helps take a piece pinned against it', () {
      final board = Board.of(const [
        '       ',
        'G      ',
        '       ',
        '   K   ',
        '       ',
        'R      ',
        '       ',
      ], turn: Side.raiders);

      final after = board.play(const Move(Square(5, 0), Square(2, 0)));
      expect(after.at(const Square(1, 0)), isNull,
          reason: 'the guard was between a raider and the corner');
    });

    test('the king is not taken by a sandwich', () {
      final board = Board.of(const [
        '       ',
        '   R   ',
        '   K   ',
        '       ',
        '   R   ',
        '       ',
        '       ',
      ], turn: Side.raiders);

      final after = board.play(const Move(Square(4, 3), Square(3, 3)));
      expect(after.kingAt, const Square(2, 3));
      expect(after.isOver, isFalse);
    });

    test('the king is taken when he is surrounded', () {
      final board = Board.of(const [
        '       ',
        ' R     ',
        'RK     ',
        ' R     ',
        '       ',
        '  R    ',
        '       ',
      ], turn: Side.raiders);

      final after = board.play(const Move(Square(5, 2), Square(2, 2)));
      expect(after.at(const Square(2, 2)), Piece.raider);
      expect(after.kingAt, isNull);
      expect(after.outcome, Outcome.kingTaken);
      expect(after.winner, Side.raiders);
    });

    test('a king with his back to the wall needs one fewer raider', () {
      // The edge is the fourth side. A rule that counted only four-sided
      // surrounds would make the edge the safest place on the board, which is
      // the opposite of true.
      final board = Board.of(const [
        '  RK   ',
        '   R   ',
        '       ',
        '       ',
        '    R  ',
        '       ',
        '       ',
      ], turn: Side.raiders);

      final after = board.play(const Move(Square(4, 4), Square(0, 4)));
      expect(after.kingAt, isNull);
      expect(after.outcome, Outcome.kingTaken);
    });
  });

  group('ending', () {
    test('the king reaching a corner wins for the guards', () {
      final board = Board.of(const [
        '   K   ',
        '       ',
        '       ',
        '       ',
        '       ',
        '       ',
        'R      ',
      ], turn: Side.guards);

      final after = board.play(const Move(Square(0, 3), Square(0, 0)));
      expect(after.outcome, Outcome.kingAway);
      expect(after.winner, Side.guards);
      expect(after.moves, isEmpty, reason: 'a finished game has no moves');
    });

    test('a side with nowhere to go has lost', () {
      // The last raider is shut into the bottom right pocket: a guard above
      // it, a guard beside it, the corner on its other side, and the edge
      // below. The guards play a quiet move somewhere else and the raiders
      // have nothing at all.
      final board = Board.of(const [
        '  G    ',
        '       ',
        '       ',
        '   K   ',
        '       ',
        '     G ',
        '    GR ',
      ], turn: Side.guards);
      expect(board.moves.where((m) => m.from == const Square(6, 5)), isEmpty);

      final after = board.play(const Move(Square(0, 2), Square(0, 1)));
      expect(after.turn, Side.raiders);
      expect(after.isOver, isTrue, reason: 'the raider has nothing to play');
      expect(after.outcome, Outcome.shutIn);
      expect(after.winner, Side.guards);
    });
  });

  group('against the rules written out the slow way', () {
    test('the two generators agree on the opening', () {
      final board = Board.opening();
      expect(board.moves.toSet(), movesPlainly(board).toSet());
      expect(board.moves, hasLength(movesPlainly(board).length));
    });

    test('and on every position of a hundred random games', () {
      // Random play wanders into positions nobody would design, which is where
      // a rule written slightly wrong is found.
      var checked = 0;
      for (var seed = 0; seed < 100; seed++) {
        for (final board in randomGame(seed)) {
          final fast = board.moves.toSet();
          final slow = movesPlainly(board).toSet();
          expect(fast, slow, reason: 'seed $seed\n$board');
          expect(board.moves, hasLength(fast.length),
              reason: 'the same move twice: seed $seed');
          checked++;
        }
      }
      expect(checked, greaterThan(1000));
    });
  });

  group('counting the game tree', () {
    // The one number that catches a rule written slightly wrong. A generator
    // that allows one illegal move, or forgets a legal one, or takes a piece
    // it should not, changes these — and by an amount that grows with depth,
    // so a bug too rare to trip a hand written test shows up as a mismatch of
    // thousands.
    //
    // These are this game's numbers, taken from this implementation once the
    // two generators agreed and the rules above passed. They are here to fail
    // when something changes, which is the whole job.
    test('the opening has the leaves it has', () {
      final board = Board.opening();
      // Twenty eight is checkable by hand and worth checking, because every
      // number under it is only as good as the one above it. Each edge holds
      // three raiders in a row: the outer two have two squares inward and one
      // along the edge, three each, and the middle one is boxed in by its
      // neighbours and has only the two squares inward. Seven an edge, four
      // edges.
      expect(perft(board, 1), 28);
      expect(perft(board, 2), 524);
      expect(perft(board, 3), 17796);
      expect(perft(board, 4), 373396);
    });
  });
}
