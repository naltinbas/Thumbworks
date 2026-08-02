import 'clues.dart';
import 'grid.dart';
import 'line.dart';

/// How a puzzle came out.
enum Verdict {
  /// Every square worked out, from the clues alone.
  solved,

  /// Consistent so far, but nothing more follows from any single line. A
  /// puzzle that ends here needs a guess, and a puzzle that needs a guess is
  /// not one this game will hand anybody.
  stuck,

  /// No picture fits these clues.
  impossible,
}

/// A solve, and how much work it took.
class Solve {
  const Solve({required this.verdict, required this.grid, required this.passes});

  final Verdict verdict;

  /// Everything that was worked out, which for a stuck puzzle is as far as
  /// line logic gets.
  final Grid grid;

  /// How many times every line had to be looked at again. This is the closest
  /// honest measure of how hard a puzzle is: an easy one falls out in two or
  /// three, and one that takes eight has deductions buried behind other
  /// deductions.
  final int passes;

  bool get isSolved => verdict == Verdict.solved;
}

/// Solves a puzzle the way a person does, and only the way a person does.
///
/// One line at a time, taking from each line only what that line's clue forces
/// on its own, and going round again because a square settled in a row changes
/// what the column through it forces. Nothing here ever tries a square to see
/// what happens.
///
/// That restriction is the point. A solver allowed to guess can crack puzzles
/// that no player could reason their way through, so it would happily wave
/// through a puzzle whose only route is trial and error. This one gets stuck
/// exactly where a player would, which is what makes it a fit judge of whether
/// a puzzle is fair. See [Maker], which throws away everything it cannot
/// solve.
Solve solve(Clues clues, {Grid? from, int limit = 200}) {
  var grid = from ??
      Grid(width: clues.width, height: clues.height);

  for (var pass = 1; pass <= limit; pass++) {
    var moved = false;

    for (var row = 0; row < clues.height; row++) {
      final was = grid.row(row);
      final now = Line(clues.rows[row], was).deduce();
      if (now == null) {
        return Solve(verdict: Verdict.impossible, grid: grid, passes: pass);
      }
      if (_differs(was, now)) {
        grid = grid.withRow(row, now);
        moved = true;
      }
    }

    for (var col = 0; col < clues.width; col++) {
      final was = grid.column(col);
      final now = Line(clues.columns[col], was).deduce();
      if (now == null) {
        return Solve(verdict: Verdict.impossible, grid: grid, passes: pass);
      }
      if (_differs(was, now)) {
        grid = grid.withColumn(col, now);
        moved = true;
      }
    }

    if (grid.isComplete) {
      return Solve(verdict: Verdict.solved, grid: grid, passes: pass);
    }
    if (!moved) {
      return Solve(verdict: Verdict.stuck, grid: grid, passes: pass);
    }
  }

  // Only reachable if a pass keeps changing something without ever finishing,
  // which cannot happen: every change settles a square that was unknown, and
  // there are finitely many. The limit is here so a bug is a failed test
  // rather than a hung phone.
  return Solve(verdict: Verdict.stuck, grid: grid, passes: limit);
}

bool _differs(List<Square> was, List<Square> now) {
  for (var i = 0; i < was.length; i++) {
    if (was[i] != now[i]) return true;
  }
  return false;
}
