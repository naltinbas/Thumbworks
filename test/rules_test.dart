import 'package:flutter_test/flutter_test.dart';
import 'package:fanwright/game/cards.dart';
import 'package:fanwright/game/deal.dart';
import 'package:fanwright/game/game.dart';
import 'package:fanwright/game/table.dart';

void main() {
  group('a card', () {
    test('is written down and read back the same', () {
      for (final card in Card.pack) {
        expect(Card.from(card.face), card, reason: card.face);
      }
      expect(Card.from('AS').rank, 1);
      expect(Card.from('KH').rank, 13);
      expect(Card.from('TD').rank, 10);
      expect(Card.from('AS').black, isTrue);
      expect(Card.from('AH').red, isTrue);
    });

    test('sits on a card one higher of the other colour', () {
      expect(Card.from('9H').sitsOn(Card.from('TS')), isTrue);
      expect(Card.from('9H').sitsOn(Card.from('TC')), isTrue);
      expect(Card.from('9H').sitsOn(Card.from('TD')), isFalse,
          reason: 'red on red');
      expect(Card.from('9H').sitsOn(Card.from('JS')), isFalse,
          reason: 'two apart');
      expect(Card.from('TS').sitsOn(Card.from('9H')), isFalse,
          reason: 'the wrong way round');
    });

    test('follows on a foundation by suit, one at a time', () {
      expect(Card.from('2H').followsOn(Card.from('AH')), isTrue);
      expect(Card.from('2S').followsOn(Card.from('AH')), isFalse);
      expect(Card.from('3H').followsOn(Card.from('AH')), isFalse);
    });
  });

  group('a deal', () {
    test('lays out fifty two cards with none missing or twice over', () {
      for (final number in const [1, 2, 617, 11982, 32000]) {
        final columns = Deal.layout(number);
        final cards = [for (final column in columns) ...column];
        expect(cards, hasLength(52), reason: 'deal $number');
        expect(cards.toSet(), hasLength(52), reason: 'deal $number');
        expect(columns.where((column) => column.length == 7), hasLength(4));
        expect(columns.where((column) => column.length == 6), hasLength(4));
      }
    });

    test('is the same every time it is asked for', () {
      final once = Deal.layout(617);
      final again = Deal.layout(617);
      for (var i = 0; i < once.length; i++) {
        expect(once[i], again[i]);
      }
    });

    test('is a different deal for a different number', () {
      expect(Deal.layout(1).first, isNot(Deal.layout(2).first));
    });
  });

  group('a table', () {
    test('starts with four empty cells and nothing home', () {
      final table = Table.deal(1);
      expect(table.freeCells, 4);
      expect(table.homeCount, 0);
      expect(table.isWon, isFalse);
      for (final suit in Suit.values) {
        expect(table.home(suit), 0);
      }
    });

    test('knows the run at the end of a column', () {
      final table = Table.of(columns: const [
        'KS QH JS TH',
        'KS QH 9S',
        '',
        '5C',
        '',
        '',
        '',
        '',
      ]);
      expect(table.runAt(0), 4, reason: 'a run all the way down');
      expect(table.runAt(1), 1, reason: 'the nine does not sit on the queen');
      expect(table.runAt(2), 0);
      expect(table.runAt(3), 1);
    });

    group('how many cards can move at once', () {
      test('is one more than the free cells, doubled per empty column', () {
        final full = Table.of(
          columns: const ['AS', 'AS', 'AS', 'AS', 'AS', 'AS', 'AS', 'AS'],
          cells: const ['2S', '2H', '2D', '2C'],
        );
        expect(full.canCarry(), 1, reason: 'nowhere to put anything');

        final open = Table.of(
          columns: const ['AS', 'AS', 'AS', 'AS', 'AS', 'AS', 'AS', 'AS'],
        );
        expect(open.canCarry(), 5, reason: 'four cells and no empty column');

        final roomy = Table.of(
          columns: const ['AS', 'AS', 'AS', 'AS', 'AS', 'AS', '', ''],
        );
        expect(roomy.canCarry(), 20, reason: 'five, doubled twice');
      });

      test('does not count the empty column being moved into', () {
        // The case everybody forgets: a column cannot both be the destination
        // and hold part of the run on the way there.
        final one = Table.of(
          columns: const ['AS', 'AS', 'AS', 'AS', 'AS', 'AS', 'AS', ''],
        );
        expect(one.canCarry(), 10);
        expect(one.canCarry(into: true), 5);
      });
    });
  });

  group('moving', () {
    test('a card to a cell and back out again', () {
      var table = Table.of(columns: const ['KS 5H', '', '', '', '', '', '', '']);
      final toCell = table.moves.firstWhere(
        (move) => move.from == Where.column && move.to == Where.cell,
      );
      table = table.play(toCell);

      expect(table.cell(0), Card.from('5H'));
      expect(table.column(0), [Card.from('KS')]);
      expect(table.freeCells, 3);

      final back = table.moves.firstWhere(
        (move) => move.from == Where.cell && move.to == Where.column,
      );
      table = table.play(back);
      expect(table.freeCells, 4);
    });

    test('an ace home, and the two after it', () {
      var table = Table.of(columns: const ['AH', '2H', '', '', '', '', '', '']);
      table = table.tidied;

      expect(table.home(Suit.hearts), 2);
      expect(table.column(0), isEmpty);
      expect(table.column(1), isEmpty);
      expect(table.homeCount, 2);
    });

    test('a run of cards together, when there is room for it', () {
      // No empty columns, so the only room is the four cells: five at a time.
      var table = Table.of(columns: const [
        'KS QH JS',
        'KC',
        '3D',
        '3C',
        '3H',
        '3S',
        '4D',
        '4C',
      ]);
      expect(table.runAt(0), 3);
      expect(table.canCarry(), 5);

      final run = table.moves.firstWhere(
        (move) => move.cards == 2 && move.toAt == 1,
      );
      table = table.play(run);
      expect(table.column(1), [
        Card.from('KC'),
        Card.from('QH'),
        Card.from('JS'),
      ]);
      expect(table.column(0), [Card.from('KS')]);
    });

    test('but not more of a run than there is room for', () {
      final table = Table.of(
        columns: const [
          'KS QH JS TH 9S',
          'KC',
          '3D',
          '3C',
          '3H',
          '3S',
          '4D',
          '4C',
        ],
        cells: const ['2S', '2H', '2D', '2C'],
      );
      // Every cell full and no empty column: one card at a time, so the four
      // card run that would land on the king cannot go anywhere.
      expect(table.runAt(0), 5);
      expect(table.canCarry(), 1);
      expect(table.moves.where((move) => move.cards > 1), isEmpty);
      expect(table.moves.where((move) => move.toAt == 1), isEmpty);
    });

    test('never off a foundation', () {
      final table = Table.of(columns: const ['', '', '', '', '', '', '', ''],
          homes: const [1, 0, 0, 0]);
      expect(
        () => table.play(const Move(
          from: Where.home,
          fromAt: 0,
          to: Where.column,
          toAt: 0,
        )),
        throwsArgumentError,
      );
    });
  });

  group('sending cards home on their own', () {
    test('only when nothing of the other colour still wants them', () {
      // The five of hearts could go up, and must not: both black fours are
      // still out and one of them may need to sit on it.
      var table = Table.of(
        columns: const ['5H', '4S', '4C', '', '', '', '', ''],
        homes: const [0, 0, 4, 0],
      );
      table = table.tidied;
      expect(table.home(Suit.hearts), 4, reason: 'the five stayed put');
      expect(table.column(0), [Card.from('5H')]);
    });

    test('and freely once they do not', () {
      var table = Table.of(
        columns: const ['5H', '', '', '', '', '', '', ''],
        homes: const [4, 0, 4, 4],
      );
      table = table.tidied;
      expect(table.home(Suit.hearts), 5);
    });

    test('aces and twos always', () {
      var table = Table.of(
        columns: const ['AS', '2S', '', '', '', '', '', ''],
      );
      table = table.tidied;
      expect(table.home(Suit.spades), 2);
    });
  });

  group('a position', () {
    test('is the same whichever cell a card sits in', () {
      final one = Table.of(
        columns: const ['KS', '', '', '', '', '', '', ''],
        cells: const ['AH', null, '2S', null],
      );
      final other = Table.of(
        columns: const ['KS', '', '', '', '', '', '', ''],
        cells: const [null, '2S', null, 'AH'],
      );
      expect(one.fingerprint, other.fingerprint);
    });

    test('and whichever way round two identical columns are written', () {
      final one = Table.of(
        columns: const ['KS', '5H', '', '', '', '', '', ''],
      );
      final other = Table.of(
        columns: const ['5H', 'KS', '', '', '', '', '', ''],
      );
      expect(one.fingerprint, other.fingerprint);
    });

    test('but not when a card is somewhere else', () {
      final one = Table.of(columns: const ['KS 5H', '', '', '', '', '', '', '']);
      final other = Table.of(
        columns: const ['KS', '', '', '', '', '', '', ''],
        cells: const ['5H', null, null, null],
      );
      expect(one.fingerprint, isNot(other.fingerprint));
    });
  });

  group('a game', () {
    test('counts moves and takes them back', () {
      var game = Game.deal(1);
      final was = game.table.fingerprint;
      expect(game.canUndo, isFalse);

      game = game.play(game.table.moves.first);
      expect(game.moves, 1);
      expect(game.canUndo, isTrue);
      expect(game.table.fingerprint, isNot(was));

      game = game.back;
      expect(game.table.fingerprint, was);
      expect(game.canUndo, isFalse);
    });

    test('ignores a move the rules do not allow', () {
      final game = Game.deal(1);
      final silly = const Move(
        from: Where.column,
        fromAt: 0,
        to: Where.column,
        toAt: 0,
      );
      expect(game.play(silly).moves, 0);
    });

    test('deals the same number again on demand', () {
      var game = Game.deal(42);
      game = game.play(game.table.moves.first);
      expect(game.again.number, 42);
      expect(game.again.table.fingerprint, Game.deal(42).table.fingerprint);
    });
  });
}
