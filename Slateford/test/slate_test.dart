import 'package:flutter_test/flutter_test.dart';
import 'package:slateford/slate/book.dart';
import 'package:slateford/slate/levels.dart';
import 'package:slateford/slate/play.dart';
import 'package:slateford/slate/rules.dart';

/// The law of the slate, held to.
void main() {
  group('the rules', () {
    test('three in a row is read on every line', () {
      for (final line in Rules.lines) {
        final b = Rules.empty;
        for (final c in line) {
          b[c] = Rules.cross;
        }
        expect(Rules.winner(b), Rules.cross, reason: '$line');
        expect(Rules.winningLine(b), line);
      }
      expect(Rules.winner(const [1, 2, 1, 2, 1, 2, 2, 1, 2]), 0);
      expect(Rules.full(const [1, 2, 1, 2, 1, 2, 2, 1, 2]), isTrue);
    });

    test('the whole tree is what the books say', () {
      final census = Rules.census();
      expect(census.positions.length, 5478);
      expect(census.games, 255168);
      expect(census.crossWins, 131184);
      expect(census.noughtWins, 77904);
      expect(census.draws, 46080);
      expect(census.byLength, {5: 1440, 6: 5328, 7: 47952, 8: 72576, 9: 127872});
    });

    test('the open slate is level, and the saving replies are pinned', () {
      expect(Rules.value(Rules.empty), 0);
      Map<int, int> replies(int opening) {
        final b = Rules.played(Rules.empty, opening, Rules.cross);
        return {
          for (final c in Rules.empties(b)) c: -Rules.value(Rules.played(b, c, Rules.nought)),
        };
      }

      expect(replies(0), {1: -1, 2: -1, 3: -1, 4: 0, 5: -1, 6: -1, 7: -1, 8: -1});
      expect(replies(4), {0: 0, 1: -1, 2: 0, 3: -1, 5: -1, 6: 0, 7: -1, 8: 0});
      expect(replies(1), {0: 0, 2: 0, 3: -1, 4: 0, 5: -1, 6: -1, 7: 0, 8: -1});
    });

    test('winning cells and forks read as told', () {
      expect(Rules.winningCells(const [1, 1, 0, 0, 2, 0, 0, 0, 2], Rules.cross), [2]);
      expect(Rules.winningCells(const [1, 1, 0, 0, 2, 0, 0, 0, 2], Rules.nought), isEmpty);
      // Two crosses share at most one line, so a second cross never
      // forks; two corner crosses round a middle nought fork at the
      // other two corners.
      expect(Rules.forkCells(const [1, 0, 0, 2, 0, 0, 0, 0, 0], Rules.cross), isEmpty);
      expect(Rules.forkCells(const [1, 0, 0, 0, 2, 0, 0, 0, 1], Rules.cross), [2, 6]);
    });
  });

  group('the book', () {
    test('opens in the middle, answers the middle with a corner', () {
      expect(Book.advise(Rules.empty), (4, 'centre'));
      for (var c = 0; c < 9; c++) {
        final after = Book.advise(Rules.played(Rules.empty, c, Rules.cross));
        expect(after, c == 4 ? (0, 'corner') : (4, 'centre'), reason: '$c');
      }
    });

    test('wins when it can, blocks when it must, forks when it may', () {
      expect(Book.advise(const [2, 2, 0, 1, 1, 0, 0, 0, 0]).$2, 'win');
      expect(Book.advise(const [1, 1, 0, 0, 2, 0, 0, 0, 0]).$2, 'block');
      expect(Book.advise(const [1, 1, 0, 0, 2, 0, 0, 0, 0]).$1, 2);
      expect(Book.advise(const [1, 0, 0, 0, 2, 0, 0, 0, 1]).$2, 'block the fork');
    });

    test('never loses from the open slate, playing either side', () {
      for (final level in [Levels.at(0), Levels.at(1)]) {
        var games = 0, bookLost = 0;
        void walk(Play play) {
          if (play.isOver) {
            games++;
            if (play.won) bookLost++;
            return;
          }
          for (final c in Rules.empties(play.board)) {
            walk(play.tap(c));
          }
        }

        walk(Play.of(level));
        expect(games, level.games, reason: level.name);
        expect(bookLost, 0, reason: level.name);
      }
    });

    test('keeps the tree\'s word at every move of every game', () {
      for (final level in Levels.all) {
        void walk(Play play) {
          if (play.isOver) return;
          for (final c in Rules.empties(play.board)) {
            final mid = Rules.played(play.board, c, play.side);
            final after = play.tap(c);
            if (!Rules.over(mid)) {
              expect(-Rules.value(after.board), Rules.value(mid), reason: '${level.name} $mid');
            }
            walk(after);
          }
        }

        walk(Play.of(level));
      }
    });
  });

  group('the play', () {
    test('every label\'s ways is what the walk finds', () {
      for (final level in Levels.all) {
        var games = 0, ways = 0;
        void walk(Play play) {
          if (play.isOver) {
            games++;
            if (play.isDone) ways++;
            return;
          }
          for (final c in Rules.empties(play.board)) {
            walk(play.tap(c));
          }
        }

        walk(Play.of(level));
        expect(games, level.games, reason: level.name);
        expect(ways, level.ways, reason: level.name);
      }
    });

    test('opens on the start, the book moving first when it is its turn', () {
      final open = Play.of(Levels.at(0));
      expect(open.board, Rules.empty);
      expect(open.bookCell, isNull);
      final second = Play.of(Levels.at(1));
      expect(second.board, [0, 0, 0, 0, 1, 0, 0, 0, 0]);
      expect(second.bookCell, 4);
      expect(second.bookRule, 'centre');
      final trap = Play.of(Levels.at(2));
      expect(trap.board, [1, 0, 0, 2, 0, 0, 0, 0, 0]);
      expect(trap.value, 1);
    });

    test('a tap marks and the book answers, counted, and back undoes both', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(0);
      expect(play.board, [1, 0, 0, 0, 2, 0, 0, 0, 0]);
      expect(play.moves, 1);
      expect(play.bookRule, 'centre');
      expect(play.tap(0), same(play));
      expect(play.tap(4), same(play));
      expect(play.back.board, Rules.empty);
    });

    test('the tree plays the open slate level in five, and it is the mark', () {
      var play = Play.of(Levels.at(0));
      while (!play.isOver) {
        play = play.tap(play.next!);
      }
      expect(play.drawn, isTrue);
      expect(play.isDone, isTrue);
      expect(play.moves, 5);
      expect(play.board, [1, 1, 2, 2, 2, 1, 1, 1, 2]);
    });

    test('the pointer lands every winnable level', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        while (!play.isOver) {
          play = play.tap(play.next!);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('a side reply to the middle loses to the book', () {
      var play = Play.of(Levels.at(1)).tap(1);
      expect(play.value, -1);
      while (!play.isOver) {
        play = play.tap(Rules.empties(play.board).first);
      }
      expect(play.lost, isTrue);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isFalse);
    });

    test('the two corners save by the sides only', () {
      final play = Play.of(Levels.at(3));
      expect([for (final c in Rules.empties(play.board)) if (play.tap(c).value == 0) c], [1, 3, 5, 7]);
      expect(play.tap(2).value, -1);
    });

    test('the hopeless level cracks when the slate is played out', () {
      var play = Play.of(Levels.at(4));
      while (!play.isOver) {
        play = play.tap(play.board[0] == 0 ? 0 : Rules.empties(play.board).first);
      }
      expect(play.won, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(Rules.empties(play.board).isEmpty ? 0 : Rules.empties(play.board).first), same(play));
    });

    test('the mark stands level', () {
      final mark = Play.standing(Levels.at(0), const [1, 1, 2, 2, 2, 1, 1, 1, 2]);
      expect(mark.drawn, isTrue);
      expect(mark.isDone, isTrue);
    });
  });
}
