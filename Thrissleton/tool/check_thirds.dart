import 'dart:io';

import 'package:thrissleton/third/hands.dart';
import 'package:thrissleton/third/rules.dart';

/// Dials every hand there is, holds the quantised count and
/// the two-case argument on each, and refuses the bake on any
/// disagreement: this is what `make thirds` runs, and the
/// README quotes its ledger verbatim.
void main() {
  for (final hand in Hands.all) {
    final ways = Rules.waysTo(hand.asked, locked: hand.locked);
    if (ways != hand.ways) {
      stderr.writeln('${hand.name}: sweep finds $ways, '
          'label says ${hand.ways}');
      exit(1);
    }
    // No hand opens landed.
    if (Rules.thirds(hand.opens).length == hand.asked) {
      stderr.writeln('${hand.name} OPENS LANDED');
      exit(1);
    }
  }

  // The laws over the whole sweep.
  if (!Rules.lawsHold()) {
    stderr.writeln('A LAW BROKE');
    exit(1);
  }

  // The spreads, pinned whole.
  final free = Rules.spread();
  if (free[1] != 1920 ||
      free[4] != 5760 ||
      free[10] != 96 ||
      free.length != 3) {
    stderr.writeln('THE SPREAD MOVED: $free');
    exit(1);
  }
  final locked = Rules.spread(locked: (0, 6));
  if (locked[1] != 320 ||
      locked[4] != 960 ||
      locked[10] != 16 ||
      locked.length != 3) {
    stderr.writeln('THE LOCKED SPREAD MOVED: $locked');
    exit(1);
  }

  stdout.writeln(
      'every hand of five stones dialled, all 7,776, and the '
      'locked 1,296 besides: the count of thirds lands only on '
      'one, four or ten, ten exactly when one remainder rules, '
      'never on nought, and the two-case argument stands on '
      'every hand, a remainder shown thrice or all three shown '
      'at once');
  stdout.writeln('');

  for (var number = 0; number < Hands.count; number++) {
    final hand = Hands.at(number);
    final name = hand.name.padRight(18);
    stdout.writeln(hand.winnable
        ? ' ${number + 1} $name ${hand.task}: '
            '${hand.ways} hand${hand.ways == 1 ? '' : 's'} of '
            'the sweep land${hand.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${hand.task}: none of the '
            '7,776, and the two cases said so first');
  }
}
