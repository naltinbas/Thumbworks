import 'package:flutter_test/flutter_test.dart';
import 'package:fanwright/game/book.dart';
import 'package:fanwright/game/game.dart';
import 'package:fanwright/game/solver.dart';
import 'package:fanwright/game/tapping.dart';
import 'package:fanwright/game/table.dart';

/// Plays a solver's line through the rules, and says where it got to.
///
/// This is the check that matters. A solver is a second opinion about the
/// rules, and the only way to know it is the same opinion is to make the rules
/// play out what it suggested: every move legal at the moment it is made, and
/// a finished game at the end.
Table replay(Table from, List<Move> moves) {
  var table = from.tidied;
  for (final move in moves) {
    expect(table.allows(move), isTrue,
        reason: 'the solver played $move, which the rules do not allow:\n'
            '$table');
    table = table.play(move).tidied;
  }
  return table;
}

void main() {
  group('the solver', () {
    test('wins a deal, and its moves really are a win', () {
      final found = const Solver().solve(Table.deal(1));
      expect(found.won, isTrue);
      expect(found.moves, isNotEmpty);
      expect(replay(Table.deal(1), found.moves).isWon, isTrue);
    });

    test('and does so on twenty deals in a row', () {
      // Twenty rather than two hundred because this replays every line
      // through the rules as well as finding it, and the point of the number
      // is to be enough to catch a rule the two disagree about.
      for (var number = 1; number <= 20; number++) {
        if (number == 11982) continue;
        final found = const Solver().solve(Table.deal(number));
        expect(found.won, isTrue, reason: 'deal $number');
        expect(replay(Table.deal(number), found.moves).isWon, isTrue,
            reason: 'deal $number');
      }
    });

    test('says so when a deal cannot be won at all', () {
      // Deal 11982 is the one everybody who has written one of these knows:
      // of the first thirty two thousand deals it is the only one that cannot
      // be won. This is the check on everything at once — the shuffle, the
      // numbering, the rules and the search — because getting any of them
      // wrong gives a deal that is not this one, and a deal that is not this
      // one can be won.
      final found = const Solver(mostPositions: 500000).solve(
        Table.deal(11982),
      );
      expect(found.won, isFalse);
      expect(found.gaveUp, isFalse,
          reason: 'it should run out of positions to try, not out of patience');
      expect(found.looked, lessThan(200000),
          reason: 'and the whole space should be small enough to exhaust');
    });

    test('finds nothing from a position that is already lost', () {
      // Every column topped by a black card and every cell holding one too, so
      // nothing has anywhere to go: a black card only ever sits on a red one.
      // No aces are loose either, so nothing can go home. Fewer than fifty two
      // cards, which a real deal never is, but the question here is only
      // whether the rules can find a move and they cannot.
      final stuck = Table.of(
        columns: const [
          '3H 2S',
          '4H 3S',
          '5H 4S',
          '6H 5S',
          '7H 6S',
          '8H 7S',
          '9H 8S',
          'TH 9S',
        ],
        cells: const ['TS', 'JS', 'QS', 'KS'],
      );
      expect(stuck.moves, isEmpty, reason: 'nothing can move at all');
      expect(const Solver().solve(stuck).won, isFalse);
    });
  });

  group('the book', () {
    test('holds a few hundred deals and none of the ones that were dropped',
        () {
      expect(Book.count, greaterThan(400));
      expect(Book.holds(11982), isFalse, reason: 'that one cannot be won');
      for (final number in Book.numbers) {
        expect(number, greaterThan(0));
      }
      expect(Book.numbers.toSet(), hasLength(Book.count), reason: 'no repeats');
      expect(Book.at(Book.count), Book.at(0), reason: 'it wraps round');
    });

    test('every deal in it really is winnable, on a sample', () {
      // The whole book was checked by tool/build_book.dart, which took four
      // minutes. Checking all of it again on every test run would be four
      // minutes nobody would wait for, so this walks a spread of it — and the
      // tool is in the repository for anybody who wants the whole thing.
      for (var place = 0; place < Book.count; place += 37) {
        final number = Book.at(place);
        final found = const Solver(mostPositions: 120000).solve(
          Table.deal(number),
        );
        expect(found.won, isTrue, reason: 'deal $number is in the book');
        expect(replay(Table.deal(number), found.moves).isWon, isTrue,
            reason: 'deal $number');
      }
    });
  });

  group('a tap', () {
    test('sends a card home before anywhere else', () {
      final table = Table.of(
        columns: const ['5H AS', '2D', '3C', '4C', '5C', '6C', '7C', '8C'],
      );
      final move = tapMove(table, from: Where.column, at: 0);
      expect(move, isNotNull);
      expect(move!.to, Where.home);
    });

    test('prefers landing on a card to filling an empty column', () {
      // The five of hearts could go on the six of spades or into the empty
      // column. An empty column is the most valuable thing on the table.
      final table = Table.of(
        columns: const ['KD 5H', '6S', '', '3C', '4C', '6C', '7C', '8C'],
      );
      final move = tapMove(table, from: Where.column, at: 0);
      expect(move!.to, Where.column);
      expect(move.toAt, 1, reason: 'onto the six, not into the gap');
    });

    test('uses a cell only when there is nothing else', () {
      // No black six on top of anything, no empty column, and the five of
      // hearts cannot go home with no hearts up.
      final table = Table.of(
        columns: const ['KD 5H', '2S', '3C', '4C', '5C', '9C', '7C', '8C'],
      );
      final move = tapMove(table, from: Where.column, at: 0);
      expect(move!.to, Where.cell);
    });

    test('takes the run from the card that was tapped', () {
      final table = Table.of(
        columns: const ['KS QH JS', 'KC', '3D', '3C', '3H', '3S', '4D', '4C'],
      );
      // The queen, which is one up from the end: the run is two cards.
      final move = tapMove(table, from: Where.column, at: 0, card: 1);
      expect(move, isNotNull);
      expect(move!.cards, 2);
      expect(move.toAt, 1);
    });

    test('is nothing when the card has nowhere to go', () {
      final table = Table.of(
        columns: const [
          '3H 2S',
          '4H 3S',
          '5H 4S',
          '6H 5S',
          '7H 6S',
          '8H 7S',
          '9H 8S',
          'TH 9S',
        ],
        cells: const ['TS', 'JS', 'QS', 'KS'],
      );
      expect(tapMove(table, from: Where.column, at: 0), isNull);
      expect(tapMove(table, from: Where.cell, at: 0), isNull);
    });
  });

  group('the hint', () {
    test('is a move the rules allow', () {
      final table = Table.deal(1).tidied;
      final move = hintFor(table);
      expect(move, isNotNull);
      expect(table.allows(move!), isTrue);
    });

    test('is a move on a line that wins, not merely a sensible one', () {
      // Followed to the end, taking the hint every time, the game finishes.
      // That is the whole promise of the button.
      var game = Game.deal(3);
      var taken = 0;
      while (!game.isWon && taken < 300) {
        final move = hintFor(game.table);
        expect(move, isNotNull, reason: 'ran out of hints after $taken moves');
        game = game.play(move!);
        taken++;
      }
      expect(game.isWon, isTrue, reason: 'gave up after $taken hints');
    });

    test('is nothing when there is nothing to be done', () {
      // Every column topped by a black card and every cell holding one too, so
      // nothing has anywhere to go: a black card only ever sits on a red one.
      // No aces are loose either, so nothing can go home. Fewer than fifty two
      // cards, which a real deal never is, but the question here is only
      // whether the rules can find a move and they cannot.
      final stuck = Table.of(
        columns: const [
          '3H 2S',
          '4H 3S',
          '5H 4S',
          '6H 5S',
          '7H 6S',
          '8H 7S',
          '9H 8S',
          'TH 9S',
        ],
        cells: const ['TS', 'JS', 'QS', 'KS'],
      );
      expect(hintFor(stuck), isNull);
    });
  });
}
