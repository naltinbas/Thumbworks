import 'dart:io';

import 'package:rowsworth/pebble/askings.dart';
import 'package:rowsworth/pebble/rules.dart';

/// Lays every heap up to a hundred out by trial, holds the powers
/// to it, and refuses the bake on any disagreement: this is what
/// `make rows` runs, and the README quotes its ledger verbatim.
void main() {
  final rules = Rules();
  for (final asking in Askings.all) {
    final heaps = rules.heapsWith(asking.rows);
    if ('$heaps' != '${asking.heaps}') {
      stderr.writeln('${asking.name}: sweep finds $heaps, label says ${asking.heaps}');
      exit(1);
    }
  }

  // Trial and the powers agree on every heap to a thousand.
  for (var n = 1; n <= 1000; n++) {
    if (Rules.rowsByTrial(n) != Rules.rowsByPowers(n)) {
      stderr.writeln('TRIAL AND POWERS PART AT $n: ${Rules.rowsByTrial(n)} ${Rules.rowsByPowers(n)}');
      exit(1);
    }
    var product = 1;
    for (final (p, e) in Rules.factors(n)) {
      for (var i = 0; i < e; i++) {
        product *= p;
      }
    }
    if (product != n) {
      stderr.writeln('THE FACTORS OF $n DO NOT MULTIPLY BACK');
      exit(1);
    }
  }

  // The notes' numbers: the smallest heaps anywhere.
  const smallest = {7: 64, 9: 36, 10: 48, 12: 60, 13: 4096};
  for (final entry in smallest.entries) {
    if (Rules.smallestWith(entry.key) != entry.value) {
      stderr.writeln('THE SMALLEST HEAP WITH ${entry.key} ROWS IS ${Rules.smallestWith(entry.key)}');
      exit(1);
    }
  }
  if (Rules.rowsByTrial(729) != 7 || Rules.rowsByTrial(256) != 9 || Rules.rowsByTrial(512) != 10) {
    stderr.writeln('THE NEXT HEAPS MOVED');
    exit(1);
  }
  // No heap under 4096 has thirteen rows, and 4096 does.
  for (var n = 1; n < 4096; n++) {
    if (Rules.rowsByPowers(n) == 13) {
      stderr.writeln('$n HAS THIRTEEN ROWS');
      exit(1);
    }
  }
  // The records up to a hundred.
  if ('${rules.records()}' != '[1, 2, 4, 6, 12, 24, 36, 48, 60]') {
    stderr.writeln('THE RECORDS MOVED: ${rules.records()}');
    exit(1);
  }
  // A prime count of rows means a single prime power, on every heap
  // to a thousand.
  for (var n = 2; n <= 1000; n++) {
    final rows = Rules.rowsByPowers(n);
    var rowsPrime = rows > 1;
    for (var d = 2; d * d <= rows; d++) {
      if (rows % d == 0) rowsPrime = false;
    }
    if (rowsPrime && Rules.factors(n).length != 1) {
      stderr.writeln('$n HAS A PRIME COUNT OF ROWS, $rows, FROM MORE THAN ONE PRIME');
      exit(1);
    }
  }

  stdout.writeln(
      'every heap up to a hundred laid out by trial and read by its powers, '
      'the two agreeing there and on to a thousand: seven even rows come '
      'from sixty-four alone, nine from thirty-six and a hundred, ten from '
      'forty-eight and eighty, twelve from sixty first and four more, and '
      'thirteen from nothing under four thousand and ninety-six, since a '
      'prime count of rows is a single prime raised, on every heap to a '
      'thousand; the records up to a hundred run 1, 2, 4, 6, 12, 24, 36, '
      '48 and 60');
  stdout.writeln('');

  for (var number = 0; number < Askings.count; number++) {
    final asking = Askings.at(number);
    final name = asking.name.padRight(18);
    stdout.writeln(asking.winnable
        ? ' ${number + 1} $name ${asking.task}: ${asking.ways} heap${asking.ways == 1 ? '' : 's'} '
            'of the hundred, ${asking.heaps.join(', ')}'
        : ' ${number + 1} $name ${asking.task}: none of the hundred, and the '
            'powers said so first');
  }
}
