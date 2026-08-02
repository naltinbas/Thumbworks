import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thornguard/game/board.dart';
import 'package:thornguard/game/game.dart';
import 'package:thornguard/game/judge.dart';
import 'package:thornguard/game/search.dart';

int _menOn(Board board) =>
    board.count(Piece.raider) +
    board.count(Piece.guard) +
    board.count(Piece.king);

/// Plays a match and reports it, which is the only way to say anything true
/// about how well an opponent plays.
({int raiders, int guards, int drawn}) match(
  int raiderDepth,
  int guardDepth,
  int games,
) {
  var wonByRaiders = 0, wonByGuards = 0, drawn = 0;
  for (var seed = 0; seed < games; seed++) {
    final random = Random(seed);
    var game = Game.fresh();
    // A few random moves each way, so the games are not all the same game.
    for (var i = 0; i < 4 && !game.isOver; i++) {
      final moves = game.board.moves;
      game = game.play(moves[random.nextInt(moves.length)]);
    }
    while (!game.isOver) {
      final depth =
          game.board.turn == Side.raiders ? raiderDepth : guardDepth;
      final thought = Search(depth: depth).think(game.board);
      if (thought.move == null) break;
      game = game.play(thought.move!);
    }
    switch (game.winner) {
      case Side.raiders:
        wonByRaiders++;
      case Side.guards:
        wonByGuards++;
      case null:
        drawn++;
    }
  }
  return (raiders: wonByRaiders, guards: wonByGuards, drawn: drawn);
}

void main() {
  group('the judge', () {
    test('scores a won game as won, from both sides', () {
      final away = Board.of(const [
        '   K   ',
        '       ',
        '       ',
        '       ',
        '       ',
        '       ',
        'R      ',
      ], turn: Side.guards).play(const Move(Square(0, 3), Square(0, 0)));

      expect(const Judge().of(away), -Judge.won);
    });

    test('knows a king with two ways out has already won', () {
      // Nothing between him and two corners. The raiders can block one clear
      // path in a move and not two, so the score has to say the game is over
      // even though the board does not.
      final board = Board.of(const [
        'K      ',
        '       ',
        '       ',
        '       ',
        '       ',
        '       ',
        '  R    ',
      ], turn: Side.raiders);

      expect(const Judge().of(board), lessThan(-Judge.won ~/ 3));
    });

    test('counts a guard as worth more than a raider', () {
      final evens = Board.of(const [
        'R      ',
        '       ',
        '   G   ',
        '   K   ',
        '       ',
        '       ',
        '       ',
      ], turn: Side.raiders);
      final aGuardDown = Board.of(const [
        'R      ',
        '       ',
        '       ',
        '   K   ',
        '       ',
        '       ',
        '       ',
      ], turn: Side.raiders);

      expect(const Judge().of(aGuardDown), greaterThan(const Judge().of(evens)));
    });
  });

  group('the search', () {
    test('takes the win when it is one move away', () {
      final board = Board.of(const [
        '   K   ',
        '       ',
        '       ',
        '       ',
        '       ',
        '       ',
        '   R   ',
      ], turn: Side.guards);

      final thought = const Search(depth: 3).think(board);
      expect(Board.isCorner(thought.move!.to), isTrue);
      expect(thought.isDecided, isTrue);
      expect(board.play(thought.move!).winner, Side.guards);
    });

    test('does not walk the king into a corner it cannot reach', () {
      final board = Board.of(const [
        '  RK   ',
        '       ',
        '       ',
        '       ',
        '       ',
        '       ',
        '      R',
      ], turn: Side.guards);

      final thought = const Search(depth: 3).think(board);
      final after = board.play(thought.move!);
      expect(after.kingAt, isNotNull, reason: 'it gave the king away');
    });

    test('sees the king taken and stops it', () {
      // Three raiders are already round the king and a fourth is a move from
      // the last square. The only move that saves him is moving him.
      final board = Board.of(const [
        '       ',
        ' R     ',
        'RK     ',
        ' R     ',
        '       ',
        '  R    ',
        '       ',
      ], turn: Side.guards);

      final thought = const Search(depth: 4).think(board);
      final after = board.play(thought.move!);
      expect(after.kingAt, isNot(const Square(2, 1)),
          reason: 'the king had to move and did not');
      expect(after.isOver, isFalse);
    });

    test('gives the same answer twice', () {
      // Nothing in the search is random. A test that says the opponent found
      // a win is only worth having if it finds it every time.
      final board = Board.opening();
      final once = const Search(depth: 4).think(board);
      final again = const Search(depth: 4).think(board);
      expect(once.move, again.move);
      expect(once.score, again.score);
      expect(once.positions, again.positions);
    });

    test('prunes, rather than looking at everything', () {
      // The whole tree four deep is 373,396 positions. Alpha-beta with the
      // moves ordered should see a small fraction of it, and if it ever stops
      // doing so the game gets slow on a phone before anybody notices here.
      final thought = const Search(depth: 4).think(Board.opening());
      expect(thought.positions, lessThan(40000));
      expect(thought.depth, 4);
    });
  });

  group('playing strength', () {
    // The only honest way to say an opponent is good is to have it beat a
    // worse one. These play whole games, which is slow, so they are kept
    // small: twelve games is enough for a difference this large and not
    // enough for a small one, which is why the claim is only that looking
    // deeper wins more.
    test('looking deeper wins more, playing the raiders', () {
      final deep = match(4, 2, 12);
      expect(deep.raiders, greaterThan(deep.guards),
          reason: 'raiders at depth 4 vs guards at depth 2: $deep');
    });

    test('looking deeper wins more, playing the guards', () {
      final deep = match(2, 4, 12);
      expect(deep.guards, greaterThan(deep.raiders),
          reason: 'guards at depth 4 vs raiders at depth 2: $deep');
    });

    test('neither side runs away with it at equal depth', () {
      // The balance the opening was chosen for. Twelve raiders was settled on
      // by trying sixteen, which won four games in five, and eight, which lost
      // every single one. If this ever fails, the game has stopped being a
      // game.
      final even = match(3, 3, 24);
      final decided = even.raiders + even.guards;
      expect(decided, greaterThan(8), reason: 'too few games finished: $even');
      expect(even.raiders, greaterThan(decided ~/ 5), reason: '$even');
      expect(even.guards, greaterThan(decided ~/ 5), reason: '$even');
    });
  });

  group('a game rather than a position', () {
    test('takes moves back, including the draw one caused', () {
      var game = Game.fresh();
      final first = game.board.moves.first;
      game = game.play(first);
      expect(game.played, 1);
      expect(game.back.played, 0);
      expect(game.back.board, Board.opening());
    });

    test('calls it a draw when the same position comes round a third time', () {
      var game = Game.fresh();
      // Two raiders and two guards shuffling back and forth, which is a
      // position repeating without anything happening.
      final shuffle = [
        const Move(Square(0, 2), Square(1, 2)),
        const Move(Square(2, 3), Square(2, 2)),
        const Move(Square(1, 2), Square(0, 2)),
        const Move(Square(2, 2), Square(2, 3)),
      ];
      for (var round = 0; round < 3 && !game.isOver; round++) {
        for (final move in shuffle) {
          if (game.isOver) break;
          game = game.play(move);
        }
      }
      expect(game.drawn, Drawn.repeated);
      expect(game.isOver, isTrue);
      expect(game.winner, isNull);
    });

    test('calls it a draw when nothing has happened for a long while', () {
      // Fifty plies with nothing taken and the king where he was. Written as
      // a search for such a line rather than as a list of moves, because a
      // list of fifty moves that never repeats a position and never touches
      // anything is not something a person should be asked to write down or
      // to read.
      final random = Random(4);
      var game = Game.fresh();
      var tries = 0;

      while (!game.isOver && tries < 4000) {
        tries++;
        final moves = game.board.moves;
        final move = moves[random.nextInt(moves.length)];
        if (game.board.at(move.from) == Piece.king) continue;

        final next = game.play(move);
        // Anything that takes a man is progress, and so is a repetition,
        // which would end the game the other way and prove nothing.
        final took = _menOn(next.board) < _menOn(game.board);
        if (took || next.drawn == Drawn.repeated) continue;
        game = next;
      }

      expect(game.isOver, isTrue, reason: 'gave up after $tries tries');
      expect(game.drawn, Drawn.stale);
      expect(game.played, Game.stalePlies);
      expect(game.winner, isNull);
    });

    test('the going-nowhere clock starts again when a man is taken', () {
      var game = Game.fresh();
      game = game.play(const Move(Square(0, 2), Square(2, 2)));
      expect(game.sinceProgress, 1);
      game = game.play(const Move(Square(4, 3), Square(4, 2)));
      expect(game.sinceProgress, 2);

      // The second raider comes down the far file and the guard between them
      // comes off.
      game = game.play(const Move(Square(0, 4), Square(2, 4)));
      expect(game.board.at(const Square(2, 3)), isNull,
          reason: 'the guard was between two raiders');
      expect(game.sinceProgress, 0);
    });
  });
}
