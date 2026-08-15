import 'dart:io';

import 'package:bakerley/tray/levels.dart';
import 'package:bakerley/tray/rules.dart';

/// Finds every filling of every tray two ways, holds the fives to the
/// chequered colouring, and refuses the bake on any disagreement: this
/// is what `make trays` runs, and the README quotes its ledger verbatim.
void main() {
  // The fours: their orientations and their shades.
  final orientationCounts = List.generate(5, (k) => Rules.orientations(k).length);
  if (orientationCounts.toString() != '[2, 1, 4, 4, 8]') {
    stderr.writeln('THE ORIENTATIONS COUNT $orientationCounts');
    exit(1);
  }
  for (var k = 0; k < 5; k++) {
    final shades = Rules.orientations(k).map(Rules.shade).toSet();
    final want = k == 2 ? {2, -2} : {0};
    if (shades.toString() != want.toString() && !(shades.length == want.length && shades.containsAll(want))) {
      stderr.writeln('${Rules.kinds[k]} SHADES $shades');
      exit(1);
    }
  }
  // Every level's label against the search, both ways, and the colouring.
  for (final level in Levels.all) {
    final (rows, first) = Rules.fillings(level.width, level.height, level.counts);
    final (cols, _) = Rules.fillings(level.width, level.height, level.counts, byColumns: true);
    if (rows != level.ways || cols != level.ways) {
      stderr.writeln('${level.name}: search finds $rows by rows and $cols by columns, label says ${level.ways}');
      exit(1);
    }
    if (first != null && !level.meets(first)) {
      stderr.writeln('${level.name}: THE FIRST FILLING DOES NOT FILL');
      exit(1);
    }
    if (level.pieces * 4 != level.width * level.height) {
      stderr.writeln('${level.name}: THE FOURS DO NOT COME TO THE TRAY');
      exit(1);
    }
    final allowed = Rules.colouringAllows(level.width, level.height, level.counts);
    if (allowed != level.winnable && level.name == 'The Five') {
      stderr.writeln('${level.name}: THE COLOURING ALLOWS IT');
      exit(1);
    }
    if (!allowed && level.winnable) {
      stderr.writeln('${level.name}: THE COLOURING FORBIDS A FILLED TRAY');
      exit(1);
    }
  }
  // Named facts.
  final facts = <(String, int, int, List<int>, int, bool)>[
    ('six tees on six by four', 6, 4, [0, 0, 6, 0, 0], 0, true),
    ('eight tees on eight by four', 8, 4, [0, 0, 8, 0, 0], 6, true),
    ('four skews on four by four', 4, 4, [0, 0, 0, 4, 0], 0, true),
    ('one of each on five by four', 5, 4, [1, 1, 1, 1, 1], 0, false),
    ('a bar, a square, two skews and an elbow on five by four', 5, 4, [1, 1, 0, 2, 1], 0, true),
  ];
  for (final (name, w, h, counts, ways, allowed) in facts) {
    final (found, _) = Rules.fillings(w, h, counts);
    if (found != ways || Rules.colouringAllows(w, h, counts) != allowed) {
      stderr.writeln('$name: $found FILLINGS, COLOURING ${Rules.colouringAllows(w, h, counts)}');
      exit(1);
    }
  }
  // Turning four times and flipping twice come home, for every four.
  for (var k = 0; k < 5; k++) {
    for (var o = 0; o < Rules.orientations(k).length; o++) {
      var t = o;
      for (var i = 0; i < 4; i++) {
        t = Rules.turned(k, t);
      }
      if (t != o || Rules.flipped(k, Rules.flipped(k, o)) != o) {
        stderr.writeln('${Rules.kinds[k]} $o DOES NOT COME HOME');
        exit(1);
      }
    }
  }

  stdout.writeln(
      'every filling of every tray found by laying a four over the first bare '
      'cell, top row first, and found again column by column, the fours turned '
      'and flipped every way, the bar 2 ways, the square 1, the tee 4, the skew '
      '4 and the elbow 8: four tees fill the four-by-four 2 ways, four elbows 10, '
      'two tees, two skews and an elbow fill the five-by-four 12 ways, two bars, '
      'two squares and two elbows fill the six-by-four 92; the tray chequered, '
      'the bar, the square, the skew and the elbow cover two dark and two light '
      'whichever way they lie and the tee three of one and one of the other, so '
      'one of each of the five covers eleven and nine on a tray of ten and ten, '
      'and the search finds no filling of the five-by-four by one of each; six '
      'tees fill no six-by-four and four skews no four-by-four, though the '
      'colouring allows both, and eight tees fill the eight-by-four 6 ways');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(16);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} fillings do it'
        : ' ${number + 1} $name ${level.task}: none, and the colouring said so first');
  }
}
