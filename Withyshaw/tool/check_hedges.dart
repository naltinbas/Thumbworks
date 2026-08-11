// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:withyshaw/hedge/hedges.dart';
import 'package:withyshaw/hedge/rules.dart';

/// Walks every shipped hedge and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_hedges.dart  (or `make hedges`)
void main() {
  // The worth against the search on every small hedge first.
  final kinds = <(int, int)>[];
  for (var length = 1; length <= 4; length++) {
    for (var bits = 0; bits < (1 << length); bits++) {
      kinds.add((bits, length));
    }
  }
  var checked = 0;
  for (var a = 0; a < kinds.length; a++) {
    for (var b = a; b < kinds.length; b++) {
      final pair = [kinds[a], kinds[b]];
      final worth = Rules.worthOfHedge(pair);
      if (Rules.isLoss(pair, true) != !worth.isPositive) {
        throw StateError('worth and search part at $pair');
      }
      checked++;
    }
  }
  print('the worth and the search agree on all $checked two-stalk hedges '
      'of up to four withies\n');

  var wrong = 0;
  for (var number = 0; number < Hedges.count; number++) {
    final hedge = Hedges.at(number);
    final worth = Rules.worthOfHedge(hedge.stalks);
    final winnable = !Rules.isLoss(hedge.stalks, true);

    final agree =
        winnable == hedge.winnable && winnable == worth.isPositive;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${hedge.name.padRight(22)} '
        'worth ${worth.said.padLeft(6)}  '
        '${winnable ? "yours to hold" : "the hedger${"'"}s"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong hedge${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped hedges are not what they claim');
  }
}
