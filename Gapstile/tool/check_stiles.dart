import 'dart:io';

import 'package:gapstile/gap/rules.dart';
import 'package:gapstile/gap/stiles.dart';

/// Dials every stride of every round, hammers every count of pegs,
/// and refuses the bake on any disagreement: this is what
/// `make stiles` runs, and the README quotes its ledger verbatim.
void main() {
  if (!Rules.lawHolds()) {
    stderr.writeln('THE THREE-GAP LAW BROKE');
    exit(1);
  }

  for (final stile in Stiles.all) {
    final dials = Rules.dialsThatGive(stile.pegs, stile.asked);
    if (dials.length != stile.ways) {
      stderr.writeln('${stile.name}: sweep finds ${dials.length}, '
          'label says ${stile.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  final needle = Rules.dialsThatGive(7, 3);
  if ('$needle' != '[(4, 11), (7, 11)]') {
    stderr.writeln('THE NEEDLE MOVED: $needle');
    exit(1);
  }
  final eleven = Rules.dialsThatGive(11, 2);
  for (final (_, round) in eleven) {
    if (round != 12) {
      stderr.writeln('AN ELEVEN OFF THE TWELVE');
      exit(1);
    }
  }
  final nine = Rules.dialsThatGive(9, 2);
  for (final (_, round) in nine) {
    if (round < 10) {
      stderr.writeln('A NINE ON A SMALL ROUND');
      exit(1);
    }
  }

  stdout.writeln(
      'every stride of every round to twelfths, every count of '
      'pegs to thirty, all 1,980 fences: the gaps take one, two, '
      'or three lengths and never a fourth, and whenever three '
      'show, the longest is the other two put together');
  stdout.writeln('');

  for (var number = 0; number < Stiles.count; number++) {
    final stile = Stiles.at(number);
    final name = stile.name.padRight(18);
    stdout.writeln(stile.winnable
        ? ' ${number + 1} $name ${stile.task}: ${stile.ways} '
            'dial${stile.ways == 1 ? '' : 's'} of the sweep land it'
        : ' ${number + 1} $name ${stile.task}: no dial of any '
            'round, no count of pegs, has ever shown a fourth');
  }
}
