import 'dart:io';

import 'package:trayford/count/rules.dart';
import 'package:trayford/count/trays.dart';

/// Sweeps every count of every tray, holds Sun Tzu's construction
/// and the shared-factor test to it over every asking, and refuses
/// the bake on any disagreement: this is what `make counts` runs,
/// and the README quotes its ledger verbatim.
void main() {
  for (final tray in Trays.all) {
    final rules = Rules(tray.rows);
    final counts = rules.counts(tray.asked);
    if (counts.length != tray.ways) {
      stderr.writeln('${tray.name}: sweep finds ${counts.length}, label says ${tray.ways}');
      exit(1);
    }
  }

  // The named counts.
  if ('${Rules([3, 5]).counts([2, 4])}' != '[14, 29]' ||
      '${Rules([3, 5, 7]).counts([2, 3, 2])}' != '[23]' ||
      '${Rules([5, 7]).counts([3, 4])}' != '[18]' ||
      '${Rules([4, 6]).counts([1, 3])}' != '[9, 21]' ||
      Rules([4, 6]).counts([1, 2]).isNotEmpty) {
    stderr.writeln('THE NAMED COUNTS MOVED');
    exit(1);
  }
  // Sun Tzu's construction for the old count: 140 + 63 + 30 = 233,
  // which is 23 over 105.
  final old = Rules([3, 5, 7]);
  if (old.span != 105 || old.byConstruction([2, 3, 2]) != 23 || (140 + 63 + 30) % 105 != 23) {
    stderr.writeln('THE OLD COUNT MOVED: ${old.byConstruction([2, 3, 2])}');
    exit(1);
  }

  // Coprime rows: every asking is met by exactly one count below
  // the span, and it is the construction's, for threes and fives,
  // fives and sevens, and threes, fives and sevens.
  for (final rows in [[3, 5], [5, 7], [3, 5, 7]]) {
    final rules = Rules(rows, capacity: Rules(rows).span - 1);
    if (!rules.coprime) {
      stderr.writeln('$rows SHARE A FACTOR');
      exit(1);
    }
    var askings = 0;
    rules.askings((asked) {
      askings++;
      final counts = rules.counts(asked);
      if (counts.length != 1 || counts.first != rules.byConstruction(asked) || !rules.meetable(asked)) {
        stderr.writeln('ROWS $rows ASKING $asked: $counts, CONSTRUCTION ${rules.byConstruction(asked)}');
        exit(1);
      }
    });
    if (askings != rules.span) {
      stderr.writeln('ROWS $rows: $askings ASKINGS, SPAN ${rules.span}');
      exit(1);
    }
  }

  // Fours and sixes: an asking is met exactly when the leftovers
  // agree on the shared factor two, 12 of the 24, and then by two
  // counts in the tray, twelve apart.
  final shared = Rules([4, 6]);
  var metCount = 0, all = 0;
  shared.askings((asked) {
    all++;
    final counts = shared.counts(asked);
    final agree = asked[0] % 2 == asked[1] % 2;
    if ((counts.isNotEmpty) != agree || shared.meetable(asked) != agree) {
      stderr.writeln('FOURS AND SIXES ASKING $asked: $counts, MEETABLE ${shared.meetable(asked)}');
      exit(1);
    }
    if (agree) {
      metCount++;
      if (counts.length != 3 && counts.length != 2) {
        stderr.writeln('FOURS AND SIXES ASKING $asked HAS ${counts.length} COUNTS IN THE TRAY');
        exit(1);
      }
      for (var i = 1; i < counts.length; i++) {
        if (counts[i] - counts[i - 1] != 12) {
          stderr.writeln('FOURS AND SIXES ASKING $asked NOT TWELVE APART: $counts');
          exit(1);
        }
      }
    }
  });
  if (all != 24 || metCount != 12 || shared.span != 12) {
    stderr.writeln('FOURS AND SIXES: $metCount OF $all MET, SPAN ${shared.span}');
    exit(1);
  }

  stdout.writeln(
      'every count of the tray swept for every tray, and every asking '
      'there is besides: by threes and fives, fives and sevens, and '
      'threes, fives and sevens, each asking is met by exactly one count '
      'below the span and it is Sun Tzu\'s construction to the egg, '
      'while by fours and sixes only the 12 askings of 24 whose '
      'leftovers agree on the shared two are met at all, twelve apart '
      'when they are, and one over by fours with two over by sixes is '
      'odd against even and never met');
  stdout.writeln('');

  for (var number = 0; number < Trays.count; number++) {
    final tray = Trays.at(number);
    final name = tray.name.padRight(21);
    final counts = Rules(tray.rows).counts(tray.asked);
    stdout.writeln(tray.winnable
        ? ' ${number + 1} $name ${tray.task}: ${tray.ways} count${tray.ways == 1 ? '' : 's'} '
            'in the tray of thirty, ${counts.join(' and ')}'
        : ' ${number + 1} $name ${tray.task}: none in the tray nor beyond it, '
            'and the shared two said so first');
  }
}
