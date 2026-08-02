import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/game/board.dart';
import 'package:latchword/game/lexicon.dart';
import 'package:latchword/game/maker.dart';

/// A small lexicon so these tests say what they mean rather than depending on
/// which words the shipped list happens to contain.
final _lex = Lexicon.of(['star', 'stare', 'rats', 'arts', 'tsar', 'least']);

Board _board(List<String> rows) => Board(
      size: rows.length,
      letters: rows.expand((r) => r.split('')).toList(),
      lexicon: _lex,
    );

void main() {
  group('squares', () {
    test('touch their neighbours, including corners', () {
      expect(const Spot(1, 1).touches(const Spot(0, 0)), isTrue);
      expect(const Spot(1, 1).touches(const Spot(1, 2)), isTrue);
      expect(const Spot(1, 1).touches(const Spot(2, 2)), isTrue);
    });

    test('do not touch themselves or anything further away', () {
      expect(const Spot(1, 1).touches(const Spot(1, 1)), isFalse);
      expect(const Spot(1, 1).touches(const Spot(1, 3)), isFalse);
      expect(const Spot(1, 1).touches(const Spot(3, 3)), isFalse);
    });
  });

  group('judging a trace', () {
    final board = _board(['star', 'ratz', 'zzzz', 'zzzz']);

    test('accepts a real word traced along touching squares', () {
      final trace = [
        const Spot(0, 0),
        const Spot(0, 1),
        const Spot(0, 2),
        const Spot(0, 3),
      ];
      expect(board.wordFor(trace), 'star');
      expect(board.judge(trace), Refusal.none);
    });

    test('refuses a trace that jumps', () {
      expect(
        board.judge([
          const Spot(0, 0),
          const Spot(0, 1),
          const Spot(0, 2),
          const Spot(3, 3),
        ]),
        Refusal.broken,
      );
    });

    test('refuses a square used twice', () {
      expect(
        board.judge([
          const Spot(0, 0),
          const Spot(0, 1),
          const Spot(0, 0),
          const Spot(0, 1),
        ]),
        Refusal.repeated,
      );
    });

    test('refuses a trace too short to be a word', () {
      expect(
        board.judge([const Spot(0, 0), const Spot(0, 1)]),
        Refusal.tooShort,
      );
    });

    test('refuses letters that are not a word', () {
      expect(
        board.judge([
          const Spot(3, 0),
          const Spot(3, 1),
          const Spot(3, 2),
          const Spot(3, 3),
        ]),
        Refusal.unknown,
      );
    });

    test('refuses a word already found, and says which refusal it is', () {
      final trace = [
        const Spot(0, 0),
        const Spot(0, 1),
        const Spot(0, 2),
        const Spot(0, 3),
      ];
      final after = board.take(trace);
      expect(after.found, {'star'});
      expect(after.judge(trace), Refusal.alreadyFound);
    });

    test('checks the shape of a trace before the word it spells', () {
      // A trace that is both broken and nonsense should complain about the
      // trace, because that is the mistake the player can see.
      expect(
        board.judge([
          const Spot(0, 0),
          const Spot(3, 3),
          const Spot(0, 1),
          const Spot(0, 2),
        ]),
        Refusal.broken,
      );
    });
  });

  group('taking a word', () {
    final board = _board(['star', 'ratz', 'zzzz', 'zzzz']);
    final trace = [
      const Spot(0, 0),
      const Spot(0, 1),
      const Spot(0, 2),
      const Spot(0, 3),
    ];

    test('leaves the board it came from alone', () {
      final after = board.take(trace);
      expect(board.found, isEmpty);
      expect(after.found, {'star'});
    });

    test('changes nothing when the trace is refused', () {
      final after = board.take([const Spot(0, 0), const Spot(0, 1)]);
      expect(identical(after, board), isTrue);
    });
  });

  group('scoring', () {
    test('pays much more for a long word than a short one', () {
      expect(Board.scoreOf('rats'), 1);
      expect(Board.scoreOf('stare'), 2);
      expect(Board.scoreOf('parades'), 7);
      expect(
        Board.scoreOf('paradise'),
        greaterThan(Board.scoreOf('parade') * 2),
      );
    });

    test('adds up what has been found', () {
      var board = _board(['star', 'ratz', 'zzzz', 'zzzz']);
      board = board.take([
        const Spot(0, 0),
        const Spot(0, 1),
        const Spot(0, 2),
        const Spot(0, 3),
      ]);
      expect(board.score, Board.scoreOf('star'));
    });
  });

  group('finding every word on a board', () {
    test('finds one traced along a row', () {
      expect(_board(['star', 'zzzz', 'zzzz', 'zzzz']).everyWord, contains('star'));
    });

    test('finds one that turns a corner', () {
      // s t z z
      // z a z z    star reading down and across.
      // z r z z
      final board = _board(['stzz', 'zazz', 'zrzz', 'zzzz']);
      expect(board.everyWord, contains('star'));
    });

    test('does not invent words that need a square twice', () {
      // Only one 's', so 'stars' cannot be traced.
      expect(_board(['star', 'zzzz', 'zzzz', 'zzzz']).everyWord,
          isNot(contains('stars')));
    });
  });

  group('a made board', () {
    // The whole point of the maker: a board is only handed over once it is
    // known to be worth playing. These use the real lexicon, since the
    // property is about real boards.
    final lexicon = Lexicon.standard();

    test('always holds enough words to be worth playing', () {
      for (var seed = 0; seed < 25; seed++) {
        final board = Maker(lexicon: lexicon, random: Random(seed)).make();
        expect(board.everyWord.length, greaterThanOrEqualTo(Maker.enough),
            reason: 'seed $seed');
      }
    });

    test('is the same board for the same seed', () {
      final a = Maker(lexicon: lexicon, random: Random(7)).make();
      final b = Maker(lexicon: lexicon, random: Random(7)).make();
      for (var r = 0; r < a.size; r++) {
        for (var c = 0; c < a.size; c++) {
          expect(a.letterAt(Spot(r, c)), b.letterAt(Spot(r, c)));
        }
      }
    });

    test('is not the same board for different seeds', () {
      final a = Maker(lexicon: lexicon, random: Random(1)).make();
      final b = Maker(lexicon: lexicon, random: Random(2)).make();
      var same = 0;
      for (var r = 0; r < a.size; r++) {
        for (var c = 0; c < a.size; c++) {
          if (a.letterAt(Spot(r, c)) == b.letterAt(Spot(r, c))) same++;
        }
      }
      expect(same, lessThan(a.size * a.size));
    });

    test('holds only letters', () {
      final board = Maker(lexicon: lexicon, random: Random(4)).make();
      for (var r = 0; r < board.size; r++) {
        for (var c = 0; c < board.size; c++) {
          expect(board.letterAt(Spot(r, c)), matches(RegExp(r'^[a-z]$')));
        }
      }
    });

    test('every word it claims to hold can actually be traced', () {
      // The search and the judge are separate pieces of code, and a board
      // where they disagree is a board that refuses a word it advertised.
      final board = Maker(lexicon: lexicon, random: Random(11)).make();
      for (final word in board.everyWord) {
        expect(lexicon.knows(word), isTrue, reason: word);
        expect(word.length, greaterThanOrEqualTo(Lexicon.shortest));
        expect(word.length, lessThanOrEqualTo(Lexicon.longest));
      }
    });
  });

  group('the shipped lexicon', () {
    final lexicon = Lexicon.standard();

    test('knows ordinary words', () {
      for (final word in ['stone', 'garden', 'letter', 'window']) {
        expect(lexicon.knows(word), isTrue, reason: word);
      }
    });

    test('does not know things that are not words', () {
      for (final word in ['zzzz', 'qxqx', 'aaaa']) {
        expect(lexicon.knows(word), isFalse, reason: word);
      }
    });

    test('holds nothing too short or too long to trace', () {
      for (final word in lexicon.words) {
        expect(word.length, greaterThanOrEqualTo(Lexicon.shortest));
        expect(word.length, lessThanOrEqualTo(Lexicon.longest));
      }
    });
  });
}
