import 'package:tallyloom/game/clues.dart';
import 'package:tallyloom/game/picture.dart';

/// Every picture that fits a set of clues, found by trying all of them.
///
/// This shares nothing with the game's solver. It does not reason about lines,
/// it lays out each row every way its clue allows and throws away the layouts
/// whose columns come out wrong. That makes it the right thing to check the
/// solver's promises against: if the two ever disagree, the disagreement is
/// real rather than the same mistake made twice.
///
/// It is exponential and only fit for the small end of the book.
List<Picture> everySolution(Clues clues, {int most = 8}) {
  final width = clues.width;
  final rows = [
    for (final clue in clues.rows) _everyLine(clue, width),
  ];

  final found = <Picture>[];
  final grid = <List<bool>>[];

  void place(int row) {
    if (found.length >= most) return;
    if (row == clues.height) {
      found.add(Picture(
        width: width,
        height: clues.height,
        filled: [for (final line in grid) ...line],
      ));
      return;
    }
    for (final line in rows[row]) {
      grid.add(line);
      if (_columnsStillPossible(grid, clues)) place(row + 1);
      grid.removeLast();
      if (found.length >= most) return;
    }
  }

  place(0);
  return found;
}

/// Every arrangement of one clue in a line of [width].
List<List<bool>> _everyLine(List<int> clue, int width) {
  final runs = clue.where((run) => run > 0).toList();
  final lines = <List<bool>>[];

  void place(int i, List<bool> soFar) {
    if (i == runs.length) {
      if (soFar.length <= width) {
        lines.add([...soFar, ...List.filled(width - soFar.length, false)]);
      }
      return;
    }
    for (var gap = soFar.isEmpty ? 0 : 1; ; gap++) {
      final start = soFar.length + gap;
      if (start + runs[i] > width) return;
      place(i + 1, [
        ...soFar,
        ...List.filled(gap, false),
        ...List.filled(runs[i], true),
      ]);
    }
  }

  place(0, <bool>[]);
  return lines;
}

/// Whether the rows laid out so far could still lead to the right columns.
///
/// Without this the search is hopeless even on a small grid; with it the rows
/// that cannot work are dropped as soon as they are put down.
bool _columnsStillPossible(List<List<bool>> grid, Clues clues) {
  final done = grid.length == clues.height;
  for (var col = 0; col < clues.width; col++) {
    final column = <bool>[];
    for (final row in grid) {
      column.add(row[col]);
    }
    // An empty line reads as [0] so a clue always has something written next
    // to it; here it is easier to have nothing mean nothing.
    final read = Picture.runsIn(column);
    final runs = (read.length == 1 && read.first == 0) ? <int>[] : read;
    final clue = clues.columns[col].where((run) => run > 0).toList();

    if (done) {
      if (runs.length != clue.length) return false;
      for (var i = 0; i < runs.length; i++) {
        if (runs[i] != clue[i]) return false;
      }
      continue;
    }

    // Part way down: the runs that are finished must match the clue so far,
    // and the run still open must not have outgrown the one it belongs to.
    final open = column.isNotEmpty && column.last;
    final settled = open ? runs.length - 1 : runs.length;
    if (settled > clue.length) return false;
    for (var i = 0; i < settled; i++) {
      if (runs[i] != clue[i]) return false;
    }
    if (open) {
      if (runs.length > clue.length) return false;
      if (runs.last > clue[runs.length - 1]) return false;
    }
  }
  return true;
}
