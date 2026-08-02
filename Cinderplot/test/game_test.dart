import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:cinderplot/game/maker.dart';
import 'package:cinderplot/game/play.dart';
import 'package:cinderplot/game/reason.dart';
import 'package:cinderplot/game/plots.dart';
import 'package:cinderplot/game/solve.dart';

import 'support/boards.dart';

void main() {
  group('the field', () {
    final field = boardOf(const [
      '..*',
      '.*.',
      '...',
    ]);

    test('knows what touches what, corners included', () {
      expect(field.around(0), unorderedEquals([1, 3, 4]));
      expect(field.around(4), unorderedEquals([0, 1, 2, 3, 5, 6, 7, 8]));
      expect(field.around(8), unorderedEquals([4, 5, 7]));
    });

    test('counts the mines around a square', () {
      expect(field.countAt(0), 1, reason: 'only the middle one touches it');
      expect(field.countAt(1), 2);
      expect(field.countAt(8), 1);
      expect(field.countAt(6), 1);
    });

    test('and a square nothing touches is blank', () {
      expect(field.isBlank(0), isFalse);
      expect(boardOf(const ['...', '...']).isBlank(0), isTrue);
    });
  });

  group('a game', () {
    test('opens the region the opening square is in', () {
      // A wall of mines down the right, so the left three columns are one
      // blank region and opening any of them opens all of them.
      final play = Play.of(boardOf(const [
        '...*',
        '...*',
        '...*',
      ], opening: 0));

      expect(play.isOpen(0), isTrue);
      expect(play.isOpen(1), isTrue, reason: 'the region should have spread');
      expect(play.isOpen(2), isTrue, reason: 'the edge of it, which has a 1');
      expect(play.isOpen(3), isFalse, reason: 'that is the mine');
      expect(play.moves, 0, reason: 'the opening square is not a move');
    });

    test('stops spreading at a square with a number on it', () {
      final play = Play.of(boardOf(const [
        '....',
        '....',
        '.*..',
      ], opening: 3));
      expect(play.isOpen(at(play.field, 2, 1)), isFalse);
      expect(play.isOpen(at(play.field, 1, 1)), isTrue,
          reason: 'the 1 above the mine is opened, and stops there');
      expect(play.isOpen(at(play.field, 2, 0)), isFalse,
          reason: 'past the 1 is not opened');
    });

    test('ends when a mine is opened', () {
      final play = Play.of(boardOf(const [
        '.....',
        '..*..',
        '...*.',
        '.....',
      ], opening: 0));
      expect(play.ending, Ending.going);

      final blown = play.open(7);
      expect(blown.ending, Ending.blown);
      expect(blown.isOpen(7), isTrue, reason: 'you get to see what you hit');
      expect(blown.open(1).ending, Ending.blown,
          reason: 'nothing happens after that');
    });

    test('is cleared when every square that is not a mine is open', () {
      final field = boardOf(const [
        '.*.',
        '...',
      ], opening: 3);
      var play = Play.of(field);
      expect(play.ending, Ending.going);

      for (var square = 0; square < field.cells; square++) {
        if (field.holdsMine(square)) continue;
        play = play.open(square);
      }
      expect(play.ending, Ending.cleared);
      expect(play.isOpen(1), isFalse, reason: 'the mine is left where it is');
    });

    test('leaves a flag where it was put, even under a spreading region', () {
      // The flag is wrong — there is no mine there — and the region would run
      // straight over it. It stays, because the player put it there.
      // A wall of mines down the middle makes two regions. The opening one
      // is on the left; a flag goes down on the right, and then the right is
      // opened, and the region runs straight over where the flag is.
      final play = Play.of(boardOf(const [
        '..*..',
        '..*..',
        '..*..',
      ], opening: 0));
      expect(play.isShut(4), isTrue, reason: 'the right side is still shut');

      final flagged = play.flag(4);
      expect(flagged.isFlagged(4), isTrue);

      final spread = flagged.open(14);
      expect(spread.isOpen(9), isTrue, reason: 'the right region opened');
      expect(spread.isFlagged(4), isTrue,
          reason: 'the region ran over the flag and left it alone');
    });

    test('counts flags down, and past zero if they are wrong', () {
      var play = Play.of(boardOf(const ['.*.', '...'], opening: 3));
      expect(play.minesLeft, 1);

      play = play.flag(0).flag(2);
      expect(play.minesLeft, -1,
          reason: 'saying there is one to go when there is not is a lie');
    });

    test('takes a flag off again, and never opens under one', () {
      final play = Play.of(boardOf(const ['.*.', '...'], opening: 3)).flag(1);
      expect(play.open(1).isOpen(1), isFalse, reason: 'flagged, so not opened');
      expect(play.flag(1).isShut(1), isTrue);
    });
  });

  group('the reasoning', () {
    test('reads one number on its own', () {
      // One mine near a corner. Opening the far corner leaves four squares
      // shut, and one of the 1s around them is looking at exactly one.
      final field = boardOf(const [
        '....',
        '.*..',
        '....',
        '....',
      ], opening: 15);
      final play = Play.of(field);
      expect(play.isShut(5), isTrue);

      final step = Reasoner(play, upTo: Rule.counted).step;
      expect(step, isNotNull);
      expect(step!.rule, Rule.counted);
      expect(step.clue, 10, reason: 'the 1 below and right of it');
      expect(step.mined, {5}, reason: 'that 1 has nowhere else to look');
      expect(step.safe, isEmpty);
    });

    test('reads two numbers against each other, when one alone says nothing',
        () {
      // The rules are not interchangeable, and this is what that means: a
      // board counting cannot finish, that a pair of numbers can.
      final field = Maker.find(
        across: 9,
        down: 13,
        mines: 22,
        seed: 1,
        needs: Rule.subset,
      )!.field;

      expect(reasonThrough(field, upTo: Rule.counted).cleared, isFalse,
          reason: 'counting alone should stop short of this one');
      expect(reasonThrough(field, upTo: Rule.subset).cleared, isTrue);
    });

    test('lists every way the mines could lie when nothing simpler works', () {
      final field = Maker.find(
        across: 10,
        down: 16,
        mines: 38,
        seed: 1,
        needs: Rule.whole,
      )!.field;

      expect(reasonThrough(field, upTo: Rule.subset).cleared, isFalse,
          reason: 'a pair of numbers should stop short of this one');
      expect(reasonThrough(field, upTo: Rule.whole).cleared, isTrue);
    });

    test('never proves anything that is not so', () {
      // The test the whole game rests on. Every step the reasoner takes is
      // checked against where the mines actually are — which the reasoner
      // cannot see and must never need to. A rule that is merely usually
      // right would show up here as a board that says clear over a mine.
      final dice = Random(11);
      var steps = 0;

      for (var game = 0; game < 300; game++) {
        final across = 6 + dice.nextInt(6);
        final down = 6 + dice.nextInt(6);
        final field = Maker.from(
              across: across,
              down: down,
              mines: (across * down * 0.2).round(),
              seed: dice.nextInt(1 << 30),
              needs: Rule.whole,
            ) ??
            // A seed that needs a guess is not wasted: reasoning as far as it
            // goes on one of those is exactly as answerable as on any other.
            Maker.from(
              across: across,
              down: down,
              mines: (across * down * 0.2).round(),
              seed: dice.nextInt(1 << 30),
              needs: Rule.counted,
            );
        if (field == null) continue;

        var play = Play.of(field);
        final known = <int>{};
        while (!play.isOver) {
          final step = Reasoner(play, known: known).step;
          if (step == null) break;
          steps++;

          for (final square in step.safe) {
            expect(field.holdsMine(square), isFalse,
                reason: 'the reasoner called a mine clear');
          }
          for (final square in step.mined) {
            expect(field.holdsMine(square), isTrue,
                reason: 'the reasoner called a clear square a mine');
          }

          known.addAll(step.mined);
          for (final square in step.safe) {
            play = play.open(square);
          }
        }
      }

      expect(steps, greaterThan(1000), reason: 'that proved almost nothing');
    });
  });

  group('the maker', () {
    test('hands back only boards that reasoning can finish', () {
      for (final size in Plots.all) {
        for (var seed = 1; seed <= 40; seed++) {
          final field = Maker.from(
            across: size.across,
            down: size.down,
            mines: size.mines,
            seed: seed,
            needs: size.needs,
          );
          if (field == null) continue;

          final solved = reasonThrough(field, upTo: size.needs);
          expect(solved.cleared, isTrue,
              reason: '${size.name} seed $seed needs a guess');
          expect(solved.hardest, size.needs,
              reason: '${size.name} seed $seed is not the puzzle it says');
        }
      }
    });

    test('finds one for every size, and does not take all day', () {
      for (final size in Plots.all) {
        final found = Maker.find(
          across: size.across,
          down: size.down,
          mines: size.mines,
          seed: 5000,
          needs: size.needs,
        );
        expect(found, isNotNull, reason: 'no board found for ${size.name}');
        expect(found!.tried, lessThan(3000),
            reason: '${size.name} took ${found.tried} tries, which a phone '
                'would be waiting through');
        expect(found.field.mines, hasLength(size.mines));
      }
    });

    test('opens on a square with nothing touching it', () {
      // Otherwise the board starts as one number and a hundred shut squares,
      // and the first move is a guess however good the rest of it is.
      for (final size in Plots.all) {
        final found = Maker.find(
          across: size.across,
          down: size.down,
          mines: size.mines,
          seed: 91,
          needs: size.needs,
        )!;
        expect(found.field.isBlank(found.field.opening), isTrue);
        expect(Play.of(found.field).opened.length, greaterThan(4),
            reason: 'the opening should show enough to start from');
      }
    });

    test('gives the same board for the same seed', () {
      final once = Maker.from(
        across: 9,
        down: 12,
        mines: 18,
        seed: 4242,
        needs: Rule.subset,
      );
      final again = Maker.from(
        across: 9,
        down: 12,
        mines: 18,
        seed: 4242,
        needs: Rule.subset,
      );
      expect(once?.mines, again?.mines);
      expect(once?.opening, again?.opening);
    });
  });
}
