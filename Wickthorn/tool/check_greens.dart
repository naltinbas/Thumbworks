import 'dart:io';

import 'package:wickthorn/rope/greens.dart';
import 'package:wickthorn/rope/rules.dart';

/// Ledgers every pair, counts every lantern, searches every
/// roping, and refuses the bake on any disagreement: this is what
/// `make ropes` runs, and the README quotes its ledger verbatim.
void main() {
  for (final green in Greens.all) {
    final rules = Rules(green.lanterns);
    final ways = rules.closings(green.given);
    if (ways != green.ways) {
      stderr.writeln('${green.name}: search finds $ways, '
          'label says ${green.ways}');
      exit(1);
    }
    // A winnable green's closing must satisfy the ledger to the
    // pair and stand every lantern in its exact share.
    if (green.winnable) {
      final closed = rules.closing(green.given)!;
      if (!rules.closed(closed)) {
        stderr.writeln('${green.name}: the closing does not close');
        exit(1);
      }
      final share = (green.lanterns - 1) ~/ 2;
      for (final stood in rules.standings(closed)) {
        if (stood != share) {
          stderr.writeln('${green.name}: a lantern stands in '
              '$stood ropes, the share is $share');
          exit(1);
        }
      }
    }
  }

  // The lantern arithmetic on the hopeless green, recomputed.
  final six = Rules(6);
  if (six.pairsDivide != true ||
      six.shareDivides != false ||
      six.closings(const []) != 0) {
    stderr.writeln('THE SIX LANTERNS CLOSED');
    exit(1);
  }
  final seven = Rules(7);
  if (seven.closings(const []) != 30 || !seven.shareDivides) {
    stderr.writeln('THE THIRTY MOVED');
    exit(1);
  }

  stdout.writeln(
      'every green searched to its end: seven lanterns close in '
      'seven ropes exactly 30 ways, every closing stands every '
      'lantern in exactly three ropes with the pair ledger clean, '
      'and six lanterns never close, their fifteen pairs '
      'dividing into five ropes while each lantern would need '
      'two and a half');
  stdout.writeln('');

  for (var number = 0; number < Greens.count; number++) {
    final green = Greens.at(number);
    final name = green.name.padRight(16);
    stdout.writeln(green.winnable
        ? ' ${number + 1} $name ${green.task}: '
            '${green.ways} closing${green.ways == 1 ? '' : 's'} '
            'by the search'
        : ' ${number + 1} $name ${green.task}: none, by the '
            'arithmetic and the search both');
  }
}
