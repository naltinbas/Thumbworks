import 'dart:io';

import 'package:cornerstow/yard/levels.dart';
import 'package:cornerstow/yard/rules.dart';

/// Finds every paving of every yard two ways, lays Nicomachus's own by
/// formula, holds the whole flags to their nought, and refuses the bake
/// on any disagreement: this is what `make yards` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // The identity itself, to a hundred.
  for (var n = 1; n <= 100; n++) {
    if (Rules.cubes(n) != Rules.side(n) * Rules.side(n)) {
      stderr.writeln('THE CUBES TO $n ARE NOT THE SQUARE OF THE SUM');
      exit(1);
    }
  }
  // Every level's label against the search, both ways.
  for (final level in Levels.all) {
    final (rows, first) = Rules.pavings(level.side, level.flags);
    final (cols, _) = Rules.pavings(level.side, level.flags, byColumns: true);
    if (rows != level.ways || cols != level.ways) {
      stderr.writeln('${level.name}: search finds $rows by rows and $cols by columns, label says ${level.ways}');
      exit(1);
    }
    if (first != null && !level.meets(first)) {
      stderr.writeln('${level.name}: THE FIRST PAVING FOUND DOES NOT PAVE');
      exit(1);
    }
    // The flags' cells come to the yard's.
    final cells = level.flags.fold(0, (sum, f) => sum + f.$1 * f.$2 * f.$4);
    if (cells != level.side * level.side) {
      stderr.writeln('${level.name}: THE FLAGS COME TO $cells CELLS, THE YARD ${level.side * level.side}');
      exit(1);
    }
  }
  // Nicomachus's own paving, by formula, paves every yard to eight, with
  // exactly the flags.
  for (var n = 1; n <= 8; n++) {
    final g = Rules.gnomons(n);
    final kinds = Rules.flags(n);
    final used = List.filled(kinds.length, 0);
    for (final (i, _, _, _, _) in g) {
      used[i]++;
    }
    final same = List.generate(kinds.length, (i) => used[i] == kinds[i].$4).every((b) => b);
    if (!Rules.paves(Rules.side(n), g) || !same) {
      stderr.writeln('NICOMACHUS\'S PAVING FAILS AT $n');
      exit(1);
    }
  }
  // Whole flags never pave, two to five, and every two-by-two in the
  // three-by-three covers the middle.
  for (var n = 2; n <= 5; n++) {
    final (whole, _) = Rules.pavings(Rules.side(n), Rules.flags(n, whole: true));
    if (whole != 0) {
      stderr.writeln('WHOLE FLAGS PAVE THE YARD OF $n IN $whole WAYS');
      exit(1);
    }
  }
  var places = 0, middles = 0;
  for (var x = 0; x <= 1; x++) {
    for (var y = 0; y <= 1; y++) {
      places++;
      if (x <= 1 && 1 < x + 2 && y <= 1 && 1 < y + 2) middles++;
    }
  }
  if (places != 4 || middles != 4) {
    stderr.writeln('TWO-BY-TWO IN THREE-BY-THREE: $middles OF $places COVER THE MIDDLE');
    exit(1);
  }

  stdout.writeln(
      'the cubes of one to n summed against the square of one to n summed, equal '
      'to a hundred; every paving of every yard found by laying a flag at the '
      'first bare cell, top row first, and found again column by column, the '
      'flags one of one, two of two, three of three and on, the last even flag '
      'cut in halves: the three-by-three is paved 12 ways, the six-by-six 80, the '
      'ten-by-ten 6,892 and the fifteen-by-fifteen 51,536; Nicomachus\'s own '
      'paving, band by band round the corner with the halves at the ends of the '
      'even bands, laid by formula and paving every yard to the thirty-six-by-'
      'thirty-six with exactly the flags; and the whole flags, no halves, paving '
      'none of the four yards a single way, the three-by-three plainly, since '
      'every two-by-two in it covers the middle cell, all 4 places it can lie');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(16);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${_commas(level.ways)} pavings do it'
        : ' ${number + 1} $name ${level.task}: none, and the middle cell said so first');
  }
}

String _commas(int n) {
  final s = '$n';
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}
