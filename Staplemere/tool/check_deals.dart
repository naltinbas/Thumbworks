// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:staplemere/yard/deals.dart';
import 'package:staplemere/yard/fewest.dart';

/// Walks every shipped deal and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_deals.dart  (or `make deals`)
void main() {
  var wrong = 0;

  for (var number = 0; number < Deals.count; number++) {
    final deal = Deals.at(number);
    final thread = Runs.thread(deal.tods).length;
    final best = Runs.byBestFit(const [], deal.tods);
    final brute = Runs.byBrute(const [], deal.tods);
    final hoard = _hoarded(deal.tods);
    final falling = Runs.falling(deal.tods);

    final agree = thread == deal.fewest &&
        best == deal.fewest &&
        brute == deal.fewest;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${deal.name.padRight(18)} '
        '${deal.many.toString().padLeft(2)} bales  '
        'fewest $brute  written down ${deal.fewest}  '
        'thread $thread  best fit $best  hoarding $hoard  '
        'falling $falling'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong deal${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped deals are not what they claim');
  }
}

/// The hoarder's morning: each bale on the heaviest top that can take it.
int _hoarded(List<int> tods) {
  final tops = <int>[];
  for (final tod in tods) {
    var loosest = -1;
    for (var pile = 0; pile < tops.length; pile++) {
      if (tops[pile] <= tod) continue;
      if (loosest == -1 || tops[pile] > tops[loosest]) loosest = pile;
    }
    if (loosest == -1) {
      tops.add(tod);
    } else {
      tops[loosest] = tod;
    }
  }
  return tops.length;
}
