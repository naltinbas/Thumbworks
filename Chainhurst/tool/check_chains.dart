import 'dart:io';

import 'package:chainhurst/chain/fields.dart';
import 'package:chainhurst/chain/rules.dart';

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// Strings every chain two ways over every placing, and refuses
/// the bake on any disagreement: this is what `make chains` runs,
/// and the README quotes its ledger verbatim.
void main() {
  // The whole sweep: both counts held together, and Sylvester and
  // Gallai held to, on every placing of three, four and five.
  for (final count in [3, 4, 5]) {
    if (!Rules.lawHolds(count)) {
      stderr.writeln('THE LAW BROKE AT $count STONES');
      exit(1);
    }
  }

  for (final field in Fields.all) {
    final ways = Rules.waysTo(field.stones, field.asked,
        inRow: field.offRow ? false : null);
    if (ways != field.ways) {
      stderr.writeln('${field.name}: sweep finds $ways, '
          'label says ${field.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  for (final bare in [1, 2, 4, 5]) {
    if (Rules.waysTo(4, bare) != 0) {
      stderr.writeln('FOUR STONES BROKE THE QUANTISATION AT $bare');
      exit(1);
    }
  }
  for (final bare in [0, 1, 2, 3]) {
    final ways = Rules.waysTo(5, bare, inRow: false);
    if (bare < 4 && ways != 0) {
      stderr.writeln('FIVE STONES WENT UNDER THE FLOOR: '
          '$bare bare, $ways ways');
      exit(1);
    }
  }
  if (Rules.waysTo(5, 0, inRow: true) != 12) {
    stderr.writeln('THE TWELVE ROWS OF FIVE MISCOUNTED');
    exit(1);
  }

  stdout.writeln(
      'every placing of three, four and five stones on the '
      'five-by-five field, all 68,080 of them: chains strung by '
      'line and counted by thirds agree on every one, and no '
      'placing off one row ever lacks a bare chain');
  stdout.writeln('');

  for (var number = 0; number < Fields.count; number++) {
    final field = Fields.at(number);
    final name = field.name.padRight(20);
    stdout.writeln(field.winnable
        ? ' ${number + 1} $name ${field.task}: '
            '${withComma(field.ways)} placings of the sweep land it'
        : ' ${number + 1} $name ${field.task}: no placing does, '
            'and only the twelve rows of five ever go bare-less');
  }
}
