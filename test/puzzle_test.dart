import 'package:flutter_test/flutter_test.dart';
import 'package:tallyloom/game/book.dart';
import 'package:tallyloom/game/clues.dart';
import 'package:tallyloom/game/grid.dart';
import 'package:tallyloom/game/line.dart';
import 'package:tallyloom/game/maker.dart';
import 'package:tallyloom/game/picture.dart';
import 'package:tallyloom/game/solver.dart';

import 'support/exhaust.dart';

void main() {
  group('a picture', () {
    test('reads back the rows it was written with', () {
      final picture = Picture.of(const ['.##.', '####', '.##.']);
      expect(picture.width, 4);
      expect(picture.height, 3);
      expect(picture.at(0, 0), isFalse);
      expect(picture.at(0, 1), isTrue);
      expect(picture.filledCount, 8);
      expect(picture.toString(), '.##.\n####\n.##.');
    });

    test('runs are the lengths of what is filled, in order', () {
      expect(Picture.runsIn(const [true, true, false, true]), [2, 1]);
      expect(Picture.runsIn(const [false, false]), [0]);
      expect(Picture.runsIn(const [true, true, true]), [3]);
      expect(Picture.runsIn(const [false, true, false]), [1]);
    });
  });

  group('clues', () {
    test('are read off a picture, both ways round', () {
      final clues = Clues.of(Picture.of(const [
        '#.#',
        '###',
        '#..',
      ]));
      expect(clues.rows, [
        [1, 1],
        [3],
        [1],
      ]);
      expect(clues.columns, [
        [3],
        [1],
        [2],
      ]);
      expect(clues.isConsistent, isTrue);
      expect(clues.filledCount, 6);
    });

    test('say when a line has satisfied them', () {
      expect(
        Clues.satisfied(const [2, 1], Grid.of(const ['##.#']).row(0).map((s) => s == Square.filled).toList()),
        isTrue,
      );
      expect(
        Clues.satisfied(const [2, 1], Grid.of(const ['##..']).row(0).map((s) => s == Square.filled).toList()),
        isFalse,
      );
    });
  });

  group('the solver', () {
    test('works out a picture from its clues alone', () {
      final picture = Picture.of(const [
        '..#..',
        '.###.',
        '#####',
        '..#..',
        '..#..',
      ]);
      final solved = solve(Clues.of(picture));
      expect(solved.verdict, Verdict.solved);
      expect(solved.grid.matches(picture), isTrue);
    });

    test('gets stuck rather than guessing', () {
      // A hollow square, which looks like a perfectly good puzzle and is not.
      // Its clues are the same eight numbers along the top and down the side,
      // and the corners can be swapped for the ones diagonally opposite
      // without changing a single one of them. Line logic finds the middle and
      // stops, which is exactly where a player would stop, and the only way on
      // is to pick a corner and hope.
      final clues = Clues.of(Picture.of(const [
        '.###.',
        '#...#',
        '#...#',
        '#...#',
        '.###.',
      ]));
      final solved = solve(clues);
      expect(solved.verdict, Verdict.stuck);
      expect(solved.grid.isComplete, isFalse);
      expect(everySolution(clues).length, greaterThan(1),
          reason: 'it really is ambiguous, not merely hard');
    });

    test('says so when no picture fits', () {
      final clues = Clues(
        rows: const [
          [2],
          [0],
        ],
        columns: const [
          [0],
          [0],
        ],
      );
      expect(solve(clues).verdict, Verdict.impossible);
    });
  });

  group('the maker', () {
    test('gives the same puzzle for the same seed', () {
      final once = const Maker().make(seed: 7, width: 8, height: 8)!;
      final again = const Maker().make(seed: 7, width: 8, height: 8)!;
      expect(once.picture, again.picture);
      expect(once.passes, again.passes);
    });

    test('respects the difficulty it is asked for', () {
      for (var seed = 0; seed < 12; seed++) {
        final puzzle =
            const Maker().make(seed: seed, width: 10, height: 10, leastPasses: 5);
        expect(puzzle, isNotNull, reason: 'seed $seed');
        expect(puzzle!.passes, greaterThanOrEqualTo(5));
      }
    });

    test('never hands over a picture it could not solve', () {
      // The property the whole maker exists for, on every size it makes.
      for (final size in const [5, 8, 10]) {
        for (var seed = 0; seed < 12; seed++) {
          final puzzle =
              const Maker().make(seed: seed, width: size, height: size)!;
          final solved = solve(puzzle.clues);
          expect(solved.isSolved, isTrue, reason: '${size}x$size seed $seed');
          expect(solved.grid.matches(puzzle.picture), isTrue);
        }
      }
    });
  });

  group('the book', () {
    test('numbers puzzles from one and climbs', () {
      expect(Book.chapterOf(1).size, 5);
      expect(Book.chapterOf(1).leastPasses, 1);
      expect(Book.chapterOf(100).size, 10);
      expect(Book.chapterOf(100).leastPasses, 7);
      expect(Book.chapterOf(500).size, 10, reason: 'the book does not run out');
      expect(Book.chapterOf(500).folds, isFalse,
          reason: 'and the deep end stays deep');
      expect(Book.placeInChapter(1), 1);
      expect(Book.placeInChapter(12), 2);
    });

    test('has a puzzle at every number, of the promised shape', () {
      // Walked rather than trusted: the maker searches for a picture that is
      // both solvable and hard enough, and "it always finds one" is a claim
      // about a search, which is the kind of claim that quietly stops being
      // true.
      for (var number = 1; number <= 250; number++) {
        final chapter = Book.chapterOf(number);
        final puzzle = Book.at(number);
        expect(puzzle.width, chapter.size, reason: 'puzzle $number');
        expect(puzzle.height, chapter.size, reason: 'puzzle $number');
        expect(puzzle.passes, greaterThanOrEqualTo(chapter.leastPasses),
            reason: 'puzzle $number');
      }
    });

    test('every puzzle is solvable without a guess', () {
      for (var number = 1; number <= 250; number++) {
        final puzzle = Book.at(number);
        final solved = solve(puzzle.clues);
        expect(solved.verdict, Verdict.solved, reason: 'puzzle $number');
        expect(solved.grid.matches(puzzle.picture), isTrue,
            reason: 'puzzle $number');
      }
    });

    test('the small puzzles have exactly one answer, searched for by hand', () {
      // Uniqueness follows from being solvable by line logic, but that is an
      // argument, and this is a check. The search below knows nothing about
      // the solver: it lays out every row every way the clue allows and keeps
      // the layouts whose columns come out right. If it ever finds two, the
      // guarantee is broken however good the argument sounded.
      for (var number = 1; number <= 20; number++) {
        final puzzle = Book.at(number);
        final answers = everySolution(puzzle.clues);
        expect(answers, hasLength(1), reason: 'puzzle $number');
        expect(answers.single, puzzle.picture, reason: 'puzzle $number');
      }
    });
  });

  group('a grid', () {
    test('marks one square at a time and leaves the rest alone', () {
      final grid = Grid(width: 3, height: 2);
      final marked = grid.mark(1, 2, Square.filled);
      expect(grid.at(1, 2), Square.unknown, reason: 'the old grid is untouched');
      expect(marked.at(1, 2), Square.filled);
      expect(marked.filledCount, 1);
      expect(marked.isComplete, isFalse);
    });

    test('matches a picture on what is filled, not on what is marked empty', () {
      final picture = Picture.of(const ['#.', '.#']);
      expect(Grid.of(const ['#?', '?#']).matches(picture), isTrue);
      expect(Grid.of(const ['#.', '.#']).matches(picture), isTrue);
      expect(Grid.of(const ['##', '.#']).matches(picture), isFalse);
    });
  });
}
