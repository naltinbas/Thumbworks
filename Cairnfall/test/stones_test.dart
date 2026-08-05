import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:cairnfall/stones/cairn.dart';
import 'package:cairnfall/stones/play.dart';
import 'package:cairnfall/stones/worth.dart';

void main() {
  late Worth worth;

  setUpAll(() => worth = Worth.upTo(40));

  group('the rules', () {
    test('an open cairn gives up anything down to the last stone', () {
      expect(const Cairn(Rule.open, 4).takes, [1, 2, 3, 4]);
      expect(const Cairn(Rule.open, 0).takes, isEmpty);
    });

    test('a three cairn gives up one, two or three', () {
      expect(const Cairn(Rule.three, 9).takes, [1, 2, 3]);
      expect(const Cairn(Rule.three, 2).takes, [1, 2],
          reason: 'and no more than there are');
    });

    test('a halves cairn gives up one stone, or half of an even number', () {
      expect(const Cairn(Rule.halves, 8).takes, [1, 4]);
      expect(const Cairn(Rule.halves, 7).takes, [1],
          reason: 'seven has no half');
      expect(const Cairn(Rule.halves, 2).takes, [1],
          reason: 'half of two is one, which is the same move');
    });
  });

  group('what a cairn is worth', () {
    test('an empty one is worth nothing, whatever its rule', () {
      for (final rule in Rule.values) {
        expect(worth.of(Cairn(rule, 0)), 0);
      }
    });

    test('an open cairn is worth its own size', () {
      // Which is the whole of Nim, and the one row of the table that can be
      // checked against something known rather than against itself.
      for (var stones = 0; stones <= 40; stones++) {
        expect(worth.of(Cairn(Rule.open, stones)), stones);
      }
    });

    test('a three cairn goes round every four stones', () {
      // Also known: take-away games with a limit of k repeat every k+1.
      for (var stones = 0; stones <= 40; stones++) {
        expect(worth.of(Cairn(Rule.three, stones)), stones % 4);
      }
    });

    test('and every value is the smallest one it cannot turn into', () {
      // The definition, checked against the table from the outside: whatever
      // a cairn is worth, it can turn into everything below that and never
      // into that.
      for (final rule in Rule.values) {
        for (var stones = 0; stones <= 40; stones++) {
          final cairn = Cairn(rule, stones);
          final reachable = {
            for (final take in cairn.takes) worth.of(cairn.less(take)),
          };
          final mine = worth.of(cairn);
          expect(reachable, isNot(contains(mine)),
              reason: '$cairn can turn into its own value');
          for (var below = 0; below < mine; below++) {
            expect(reachable, contains(below),
                reason: '$cairn cannot turn into $below');
          }
        }
      }
    });
  });

  group('the whole position', () {
    /// Who wins from a position, worked out by walking every move there is.
    ///
    /// Slow, and it knows nothing about values — which is exactly why it is
    /// the thing to check them against.
    bool winsByBruteForce(Play play, Map<String, bool> seen) {
      if (play.isOver) return false;
      final key = play.cairns.map((c) => '${c.rule.index}:${c.stones}').join(',');
      final known = seen[key];
      if (known != null) return known;

      var wins = false;
      for (final move in play.moves) {
        if (!winsByBruteForce(play.after(move), seen)) {
          wins = true;
          break;
        }
      }
      return seen[key] = wins;
    }

    test('is won by whoever is to move exactly when it is worth something',
        () {
      // Sprague and Grundy's theorem, checked rather than taken on trust: the
      // value of several games played side by side is the exclusive or of
      // their values, so a position is lost precisely when that comes to
      // nothing. Every claim this game makes rests on it.
      final seen = <String, bool>{};
      final dice = Random(4);
      var checked = 0;

      for (var i = 0; i < 400; i++) {
        final cairns = [
          for (var n = 0; n < 1 + dice.nextInt(3); n++)
            Cairn(
              Rule.values[dice.nextInt(Rule.values.length)],
              dice.nextInt(9),
            ),
        ];
        final play = Play(cairns: cairns, toMove: Who.you);

        expect(winsByBruteForce(play, seen), worth.ofAll(cairns) != 0,
            reason: 'the arithmetic and the search disagree about $cairns');
        checked++;
      }
      expect(checked, 400);
    });

    test('and every one of them, exhaustively, for three small cairns', () {
      // Not a sample: every position of three cairns of up to six stones,
      // one of each rule.
      final seen = <String, bool>{};
      for (var a = 0; a <= 6; a++) {
        for (var b = 0; b <= 6; b++) {
          for (var c = 0; c <= 6; c++) {
            final cairns = [
              Cairn(Rule.open, a),
              Cairn(Rule.three, b),
              Cairn(Rule.halves, c),
            ];
            final play = Play(cairns: cairns, toMove: Who.you);
            expect(winsByBruteForce(play, seen), worth.ofAll(cairns) != 0,
                reason: '$cairns');
          }
        }
      }
    });
  });

  group('a game', () {
    test('takes stones off the cairn it was told to', () {
      final play = Play(
        cairns: const [Cairn(Rule.open, 5), Cairn(Rule.three, 4)],
        toMove: Who.you,
      ).after(const Take(0, 3));

      expect(play.cairns[0].stones, 2);
      expect(play.cairns[1].stones, 4);
      expect(play.toMove, Who.them);
      expect(play.last, const Take(0, 3));
    });

    test('refuses a take the rule does not allow', () {
      const start = Play(
        cairns: [Cairn(Rule.three, 9)],
        toMove: Who.you,
      );
      expect(start.after(const Take(0, 4)).cairns, start.cairns);
      expect(start.after(const Take(1, 1)).cairns, start.cairns);
      expect(start.after(const Take(0, 0)).cairns, start.cairns);
    });

    test('is over when the last stone goes, and the taker has won', () {
      final play = Play(
        cairns: const [Cairn(Rule.open, 2)],
        toMove: Who.you,
      ).after(const Take(0, 2));

      expect(play.isOver, isTrue);
      expect(play.won, Who.you, reason: 'whoever takes the last stone wins');
      expect(play.after(const Take(0, 1)).isOver, isTrue);
    });

    test('and a winning move really does leave nothing behind', () {
      final dice = Random(12);
      var found = 0;
      for (var i = 0; i < 300; i++) {
        final cairns = [
          for (var n = 0; n < 2 + dice.nextInt(3); n++)
            Cairn(
              Rule.values[dice.nextInt(Rule.values.length)],
              1 + dice.nextInt(12),
            ),
        ];
        final play = Play(cairns: cairns, toMove: Who.you);
        final move = play.winningMove(worth);

        if (worth.ofAll(cairns) == 0) {
          expect(move, isNull, reason: 'nothing wins from $cairns');
          continue;
        }
        expect(move, isNotNull, reason: 'something must win from $cairns');
        expect(worth.ofAll(play.after(move!).cairns), 0);
        found++;
      }
      expect(found, greaterThan(200));
    });

    test('and playing it perfectly wins every game that can be won', () {
      // Both sides playing the arithmetic. Whoever is to move first from a
      // position worth something has to end up the winner, every time.
      final dice = Random(21);
      for (var i = 0; i < 200; i++) {
        final cairns = [
          for (var n = 0; n < 2 + dice.nextInt(3); n++)
            Cairn(
              Rule.values[dice.nextInt(Rule.values.length)],
              1 + dice.nextInt(10),
            ),
        ];
        var play = Play(cairns: cairns, toMove: Who.you);
        final winnable = worth.ofAll(cairns) != 0;

        var guard = 0;
        while (!play.isOver && guard++ < 500) {
          play = play.after(play.bestMove(worth));
        }
        expect(play.isOver, isTrue);
        expect(play.won, winnable ? Who.you : Who.them,
            reason: 'perfect play went wrong from $cairns');
      }
    });
  });
}
