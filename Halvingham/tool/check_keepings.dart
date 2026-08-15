import 'dart:io';

import 'package:halvingham/ledger/levels.dart';
import 'package:halvingham/ledger/rules.dart';

/// Sweeps every keeping of the rows for every pair up to sixty by
/// sixty, holds the rule to the sweep, and refuses the bake on any
/// disagreement: this is what `make keepings` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, and the rule's keeping.
  for (final level in Levels.all) {
    final rules = level.rules;
    final (landing, all) = rules.sweep(exactly: level.exactly);
    if (landing != level.ways || all != level.keepings) {
      stderr.writeln('${level.name}: sweep finds $landing of $all, label says ${level.ways} of ${level.keepings}');
      exit(1);
    }
    if (rules.lands(rules.oddRows, exactly: level.exactly) != level.winnable) {
      stderr.writeln('${level.name}: THE RULE ${rules.lands(rules.oddRows) ? 'LANDS' : 'FAILS'}, LABEL ${level.winnable ? 'WINNABLE' : 'HOPELESS'}');
      exit(1);
    }
  }

  // Every pair from one by one to sixty by sixty: the doubles beside
  // the odd halves add to the product, that keeping is the only one
  // that does, and the rows number the twos it takes to write the first
  // number.
  var ledgers = 0, rowsInAll = 0;
  for (var a = 1; a <= 60; a++) {
    for (var b = 1; b <= 60; b++) {
      final rules = Rules(a, b);
      ledgers++;
      rowsInAll += rules.rows.length;
      if (rules.sumOf(rules.oddRows) != a * b) {
        stderr.writeln('$a BY $b: THE ODD ROWS ADD TO ${rules.sumOf(rules.oddRows)}');
        exit(1);
      }
      final (landing, all) = rules.sweep();
      if (landing != 1 || all != (1 << rules.rows.length)) {
        stderr.writeln('$a BY $b: $landing OF $all KEEPINGS LAND');
        exit(1);
      }
      if (rules.rows.length != a.bitLength) {
        stderr.writeln('$a BY $b: ${rules.rows.length} ROWS, ${a.bitLength} TWOS');
        exit(1);
      }
      // The odd rows are the twos of the first number: row i is odd
      // exactly when the i-th two is in it.
      for (var i = 0; i < rules.rows.length; i++) {
        if (rules.rows[i].$1.isOdd != ((a >> i) & 1 == 1)) {
          stderr.writeln('$a BY $b: ROW $i ODD ${rules.rows[i].$1.isOdd}, TWO ${(a >> i) & 1}');
          exit(1);
        }
      }
    }
  }

  stdout.writeln(
      'every pair from one by one to sixty by sixty halved and doubled, '
      '${_commas(ledgers)} ledgers and ${_commas(rowsInAll)} rows, and every keeping '
      'of the rows swept: the doubles beside the odd halves add to the product '
      'every time, and no other keeping does, since a row is odd exactly when '
      'its two is in the first number and a number is its twos one way only; '
      'thirteen by seven keeps 1 way of 16, twenty-seven by nineteen 1 of 32, '
      'forty by twenty-five 1 of 64, ninety-nine by nine 1 of 128, and thirteen '
      'by seven in two rows never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(24);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.keepings} keepings land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.keepings}, and the twos said so first');
  }
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
