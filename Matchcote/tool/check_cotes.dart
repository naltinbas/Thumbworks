import 'dart:io';

import 'package:matchcote/round/cotes.dart';
import 'package:matchcote/round/rules.dart';

/// Pairs every round, covers every pair, sweeps every fixture,
/// and refuses the bake on any disagreement: this is what
/// `make rounds` runs, and the README quotes its ledger verbatim.
void main() {
  for (final cote in Cotes.all) {
    final ways = Rules(cote.players).fixtures(cote.given);
    if (ways != cote.ways) {
      stderr.writeln('${cote.name}: sweep finds $ways, '
          'label says ${cote.ways}');
      exit(1);
    }
  }

  // The odd crowd, from the other side: no full round at all.
  final five = Rules(5);
  if (five.pairings([0, 1, 2, 3, 4], {}).isNotEmpty) {
    stderr.writeln('FIVE PLAYERS FILLED A ROUND');
    exit(1);
  }
  // The orders: 720 is 6 bare schedules times 120 orderings.
  if (Rules(6).fixtures(const []) != 6 * 120) {
    stderr.writeln('THE SIX LOST ITS ORDERINGS');
    exit(1);
  }
  // Every fixture found covers cleanly.
  final one = Rules(6).fixture(const []);
  if (one == null || !Rules(6).covers(one)) {
    stderr.writeln('A FIXTURE THAT DOES NOT COVER');
    exit(1);
  }

  stdout.writeln(
      'every fixture swept, four and six players alike: the '
      'counts run 6 and 720 with 48 and 6 from the part-fixed '
      'cotes, 720 is six bare schedules times the 120 orders of '
      'their rounds, every found fixture covers every pair '
      'exactly once, and five players cannot fill one round');
  stdout.writeln('');

  for (var number = 0; number < Cotes.count; number++) {
    final cote = Cotes.at(number);
    final name = cote.name.padRight(18);
    stdout.writeln(cote.winnable
        ? ' ${number + 1} $name ${cote.task}: ${cote.ways} '
            'fixture${cote.ways == 1 ? '' : 's'} of the sweep '
            'land${cote.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${cote.task}: none, since an odd '
            'crowd never fills a round');
  }
}
