import 'dart:io';

import 'package:wardsby/parish/levels.dart';
import 'package:wardsby/parish/rules.dart';

/// Walks every drawing of the parish, holds the wins to the three-vote
/// bound, and refuses the bake on any disagreement: this is what `make
/// wards` runs, and the README quotes its ledger verbatim.
void main() {
  final drawings = Rules.drawings;
  if (drawings.length != 4006 || Rules.countTurned() != 4006) {
    stderr.writeln('${drawings.length} DRAWINGS, ${Rules.countTurned()} TURNED');
    exit(1);
  }
  // Every drawing sound, and no two alike.
  final seen = <String>{};
  for (final d in drawings) {
    if (!Rules.sound(d)) {
      stderr.writeln('A DRAWING THAT IS NOT SOUND: $d');
      exit(1);
    }
    if (!seen.add(d.join(','))) {
      stderr.writeln('A DRAWING TWICE: $d');
      exit(1);
    }
  }
  // Every level's label against the walk, and no drawing giving a side
  // more wards than three votes a ward allow.
  for (final level in Levels.all) {
    var met = 0;
    for (final d in drawings) {
      if (level.meets(d)) met++;
    }
    if (met != level.ways) {
      stderr.writeln('${level.name}: walk finds $met, label says ${level.ways}');
      exit(1);
    }
    final blue = level.blue;
    final most = Rules.mostWards(level.blues);
    final mostRed = Rules.mostWards(25 - level.blues);
    for (final d in drawings) {
      final w = Rules.blueWins(d, blue);
      if (w > most || Rules.wards - w > mostRed) {
        stderr.writeln('${level.name}: A DRAWING BEATS THE THREE-VOTE BOUND');
        exit(1);
      }
    }
  }
  // The spreads.
  final spreads = <String, List<int>>{
    'BBRRRBBRRRBBRRRBBRRRBBRRR': [1, 696, 3033, 276, 0, 0],
    'BBBBBBBBBBBBBBBRRRRRRRRRR': [0, 0, 276, 3033, 696, 1],
    'BRBRBRRRRRBRBRBRRRRRBRBRB': [1382, 2124, 490, 10, 0, 0],
    'BBBBBBBBRRRRRRRRRRRRRRRRR': [18, 2072, 1916, 0, 0, 0],
    'BRBRBRBRBRBRBRBRBRBRBRBRB': [0, 0, 56, 3930, 20, 0],
  };
  for (final e in spreads.entries) {
    final blue = e.key.split('').map((c) => c == 'B').toList();
    final got = Rules.spread(blue);
    if (got.toString() != e.value.toString()) {
      stderr.writeln('${e.key}: SPREAD $got, NOT ${e.value}');
      exit(1);
    }
  }
  // The sweep is the columns; the winning tallies of the packed ten.
  final rows = 'BBBBBBBBBBBBBBBRRRRRRRRRR'.split('').map((c) => c == 'B').toList();
  final sweep = drawings.where((d) => Rules.blueWins(d, rows) == 5).toList();
  if (sweep.length != 1 || sweep.first.join() != '0123401234012340123401234') {
    stderr.writeln('THE SWEEP IS NOT THE COLUMNS: $sweep');
    exit(1);
  }
  final packed = 'BBRRRBBRRRBBRRRBBRRRBBRRR'.split('').map((c) => c == 'B').toList();
  final tallies = <String, int>{};
  for (final d in drawings) {
    if (Rules.blueWins(d, packed) == 3) {
      final t = List.generate(5, (w) => [for (var c = 0; c < 25; c++) if (d[c] == w && packed[c]) c].length)..sort();
      tallies[t.join(',')] = (tallies[t.join(',')] ?? 0) + 1;
    }
  }
  if (tallies['0,0,3,3,4'] != 232 || tallies['0,1,3,3,3'] != 44) {
    stderr.writeln('THE PACKED TEN TALLY $tallies');
    exit(1);
  }

  stdout.writeln(
      'every drawing of the five-by-five parish into five wards of five in one '
      'piece walked, 4,006 drawings, each sound and none twice, the set the same '
      'turned a quarter, and every one told for the wards each side wins, three '
      'votes to a ward: ten Blues in the two left columns win three wards in 276 '
      'drawings, two in 3,033, one in 696 and none in one, the columns; fifteen '
      'Blues in the top three rows win all five in one drawing, the columns, four '
      'in 696, three in 3,033 and two in 276, so the Reds take three wards in 276; '
      'nine Blues on the odd squares of the odd rows win three wards in 10 '
      'drawings, every one three Blues to each won ward; eight Blues win two wards '
      'in 1,916 drawings, one in 2,072, none in 18 and three never, since three '
      'wards take nine votes; and no drawing of any parish gives a side more wards '
      'than a third of its votes');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the 4,006 drawings land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the 4,006, and the three votes said so first');
  }
}
