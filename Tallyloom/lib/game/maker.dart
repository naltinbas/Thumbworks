import 'dart:math';

import 'clues.dart';
import 'picture.dart';
import 'solver.dart';

/// A puzzle: the clues to play, the picture behind them, and what it cost to
/// work out.
class Puzzle {
  const Puzzle({
    required this.seed,
    required this.picture,
    required this.clues,
    required this.passes,
    required this.tries,
  });

  final int seed;

  /// The answer. The game holds it so it can be shown when the player asks to
  /// give up, and so a finished grid can be checked without solving anything.
  final Picture picture;

  final Clues clues;

  /// How many times the solver went round every line to finish it.
  final int passes;

  /// How many pictures were thrown away before this one. Kept because it is
  /// the number that says whether the maker is working or thrashing.
  final int tries;

  int get width => picture.width;
  int get height => picture.height;
}

/// Makes puzzles that can be solved, and throws away the ones that cannot.
///
/// The rule this exists to keep is that a player is never asked to guess. A
/// grid of random squares usually breaks it: the clues that come off it are
/// perfectly valid, and they leave a point where nothing more follows from any
/// single line and the only way on is to try a square and see. That is not a
/// puzzle, it is a coin toss with extra steps, and a player who hits one
/// cannot tell the difference between a hard puzzle and an unfair one.
///
/// So every picture is put through [solve], which reasons the way a person
/// does and refuses to guess, and a picture it cannot finish is thrown away.
/// What comes out is a puzzle with a guaranteed route through it, and the
/// route's length is [Puzzle.passes].
///
/// Solvability by line logic alone also settles uniqueness for free: if every
/// square is forced, no other picture fits the clues.
class Maker {
  const Maker({this.tries = 4000});

  /// How many pictures to try before giving up on a seed.
  ///
  /// Four thousand sounds enormous and costs nothing: a picture is drawn and
  /// solved in tens of microseconds, and only the hardest chapter gets
  /// anywhere near it. Measured on the deepest one, ten across needing eight
  /// passes, the maker throws away about seven hundred pictures and takes
  /// under forty milliseconds.
  final int tries;

  /// The puzzle for a seed at a size, or null if this seed had nothing.
  ///
  /// Deterministic: the same seed and size give the same puzzle on any
  /// machine, which is what lets a puzzle be numbered rather than stored.
  ///
  /// [leastPasses] is how hard it has to be. A puzzle the solver finishes in
  /// one sweep of the lines is one a player finishes without ever coming back
  /// to a line, which is a fine thing to open a book with and a dull thing to
  /// be given twenty of. Asking for more sweeps asks for deductions that only
  /// appear after other deductions, which is the thing that makes a nonogram
  /// worth doing.
  Puzzle? make({
    required int seed,
    required int width,
    required int height,
    int leastPasses = 1,
    bool folds = true,
  }) {
    for (var attempt = 0; attempt < tries; attempt++) {
      final random = Random(seed * 1000003 + attempt);
      final picture = _draw(random, width, height, folds);
      if (!_worthPlaying(picture)) continue;

      final clues = Clues.of(picture);
      final solved = solve(clues);
      if (!solved.isSolved) continue;
      if (solved.passes < leastPasses) continue;

      // Belt and braces: the solver finished, so what it finished with had
      // better be the picture the clues came off.
      assert(solved.grid.matches(picture), 'solved a different picture');

      return Puzzle(
        seed: seed,
        picture: picture,
        clues: clues,
        passes: solved.passes,
        tries: attempt,
      );
    }
    return null;
  }

  /// The share of the grid a picture should fill.
  ///
  /// Too empty and the clues are all small numbers that force nothing; too
  /// full and the picture is a rectangle with bites out of it. Between these
  /// is where a picture has enough long runs to give the solver a foothold and
  /// enough gaps to be worth looking at.
  static const _leastFilled = 0.38;
  static const _mostFilled = 0.62;

  /// A picture of blobs rather than static.
  ///
  /// Random squares make a picture with no long runs in it, which is both ugly
  /// and nearly always unsolvable: the clues come out as columns of ones and
  /// twos that pin nothing down. Growing a few blobs by walking gives runs of
  /// three and four, which is what the solver has to bite on and what makes
  /// the finished grid look like a shape somebody meant.
  Picture _draw(Random random, int width, int height, bool folds) {
    // Which way this one folds, decided before anything is drawn.
    //
    // Symmetry is what makes a picture read as something somebody drew rather
    // than as spilled ink; comparing the two settled it, because the mirrored
    // ones come out looking like masks and butterflies and the rest look like
    // nothing at all. Not every one, though, and not always the same way, or
    // knowing the shape of the answer would be worth more than reading the
    // clues.
    final fold = random.nextInt(20);
    final foldsAcross = folds && (fold < 9 || fold >= 17);
    final foldsDown = folds && fold >= 13;

    // Drawn inside the fold and then copied out, rather than drawn everywhere
    // and folded afterwards. Folding afterwards moves the share of the grid
    // that ends up filled — it copies one half over the other — so a picture
    // drawn to a target and then folded misses it, and the check below throws
    // it away. Which is how a maker that mirrors most of its pictures ends up
    // handing over hardly any.
    final drawWide = foldsAcross ? (width + 1) ~/ 2 : width;
    final drawHigh = foldsDown ? (height + 1) ~/ 2 : height;

    final filled = List<bool>.filled(width * height, false);
    final target =
        (drawWide * drawHigh * (_leastFilled + random.nextDouble() * 0.18))
            .round();

    var count = 0;
    var row = random.nextInt(drawHigh);
    var col = random.nextInt(drawWide);
    var stepsLeft = 0;

    while (count < target) {
      if (stepsLeft == 0) {
        // A new blob somewhere else, so the picture is not one snake.
        row = random.nextInt(drawHigh);
        col = random.nextInt(drawWide);
        stepsLeft = 4 + random.nextInt(2 + (drawWide * drawHigh) ~/ 12);
      }
      if (!filled[row * width + col]) {
        filled[row * width + col] = true;
        count++;
      }
      stepsLeft--;

      // A step that favoured going straight on would make longer runs still,
      // but it would also turn the blobs into lines. Four ways, evenly.
      switch (random.nextInt(4)) {
        case 0:
          row = (row - 1).clamp(0, drawHigh - 1);
        case 1:
          row = (row + 1).clamp(0, drawHigh - 1);
        case 2:
          col = (col - 1).clamp(0, drawWide - 1);
        default:
          col = (col + 1).clamp(0, drawWide - 1);
      }
    }

    if (foldsAcross) {
      for (var r = 0; r < height; r++) {
        for (var c = 0; c < width ~/ 2; c++) {
          filled[r * width + (width - 1 - c)] = filled[r * width + c];
        }
      }
    }
    if (foldsDown) {
      for (var r = 0; r < height ~/ 2; r++) {
        for (var c = 0; c < width; c++) {
          filled[(height - 1 - r) * width + c] = filled[r * width + c];
        }
      }
    }

    return Picture(width: width, height: height, filled: filled);
  }

  /// Whether a picture is worth turning into clues at all.
  ///
  /// Cheap tests, run before the solver, because the solver is the expensive
  /// part and most of what gets thrown away can be thrown away on sight.
  bool _worthPlaying(Picture picture) {
    final share = picture.filledCount / picture.area;
    if (share < _leastFilled || share > _mostFilled) return false;

    // An empty line is a gift, and two are a hole in the picture.
    var emptyRows = 0;
    for (var row = 0; row < picture.height; row++) {
      if (!picture.row(row).contains(true)) emptyRows++;
    }
    var emptyColumns = 0;
    for (var col = 0; col < picture.width; col++) {
      if (!picture.column(col).contains(true)) emptyColumns++;
    }
    return emptyRows <= 1 && emptyColumns <= 1;
  }
}
