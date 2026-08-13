import 'dart:io';

import 'package:dealstone/deal/handfuls.dart';
import 'package:dealstone/deal/rules.dart';

/// Deals every hand there is, holds Brandt's law whole, and
/// refuses the bake on any disagreement: this is what
/// `make deals` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final handful in Handfuls.all) {
    final ways = Rules.waysTo(handful.stones, handful.asked);
    if (ways != handful.ways) {
      stderr.writeln('${handful.name}: sweep finds $ways, '
          'label says ${handful.ways}');
      exit(1);
    }
    // No handful opens landed.
    if (Rules.dealsByWalk(handful.opens) == handful.asked) {
      stderr.writeln('${handful.name} OPENS LANDED');
      exit(1);
    }
  }

  // The laws over every hand of six, eight and ten.
  if (!Rules.lawsHold()) {
    stderr.writeln('A LAW BROKE');
    exit(1);
  }

  // The spreads, pinned whole.
  final six = <int, int>{};
  Rules.hands(6, (hand) {
    final deals = Rules.dealsByWalk(hand);
    six[deals] = (six[deals] ?? 0) + 1;
  });
  if ('${six.entries.map((held) => '${held.key}:${held.value}').toList()..sort()}' !=
      '[0:1, 1:1, 2:2, 3:3, 4:2, 5:1, 6:1]') {
    stderr.writeln('THE SIX SPREAD MOVED: $six');
    exit(1);
  }
  var tens = 0;
  var twelves = 0;
  Rules.hands(10, (hand) {
    tens++;
    if (Rules.dealsByWalk(hand) == 12) {
      twelves++;
      if (hand.first != 3) {
        stderr.writeln('A LONG TEN GREW PAST THREE: $hand');
        exit(1);
      }
    }
  });
  if (tens != 42 || twelves != 3) {
    stderr.writeln('THE TENS MOVED: $tens hands, $twelves twelves');
    exit(1);
  }
  var eights = 0;
  Rules.hands(8, (hand) {
    if (Rules.standsStill(hand)) eights++;
  });
  if (eights != 0) {
    stderr.writeln('AN EIGHT STOOD STILL');
    exit(1);
  }

  stdout.writeln(
      'every hand dealt, the 11 of six, the 22 of eight and the '
      '42 of ten: triangular counts always walk to their stair, '
      'the stair alone stands still, no hand of eight ever '
      'does, the longest road of ten runs twelve deals and all '
      'three hands that walk it keep their biggest pile at '
      'three');
  stdout.writeln('');

  for (var number = 0; number < Handfuls.count; number++) {
    final handful = Handfuls.at(number);
    final name = handful.name.padRight(18);
    stdout.writeln(handful.winnable
        ? ' ${number + 1} $name ${handful.task}: '
            '${handful.ways} hand${handful.ways == 1 ? '' : 's'} '
            'of the sweep land${handful.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${handful.task}: none of the '
            '22, and the stair count said so first');
  }
}
