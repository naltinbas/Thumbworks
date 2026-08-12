import 'dart:io';

import 'package:brackenside/hill/hills.dart';
import 'package:brackenside/hill/play.dart';
import 'package:brackenside/hill/rules.dart';

/// Counts every patch, walks the rim, sweeps every colouring, and
/// refuses the bake on any disagreement: this is what
/// `make patches` runs, and the README quotes its ledger verbatim.
void main() {
  // The law over every size shipped: census parity == rim parity,
  // and no even count anywhere.
  for (final side in [3, 4, 5]) {
    final rules = Rules(side);
    if (rules.rimEdges() != 1) {
      stderr.writeln('THE RIM WALK MOVED AT SIDE $side');
      exit(1);
    }
    if (!rules.lawHolds()) {
      stderr.writeln('THE LAW BROKE AT SIDE $side');
      exit(1);
    }
  }

  for (final hill in Hills.all) {
    // No hill opens already landed: there must be something to do.
    if (Play.of(hill).isDone) {
      stderr.writeln('${hill.name}: opens already landed');
      exit(1);
    }
    final ways = Rules(hill.side).waysTo(hill.asked);
    if (ways != hill.ways) {
      stderr.writeln('${hill.name}: sweep finds $ways, '
          'label says ${hill.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  final five = Rules(5);
  final spread = five.spread();
  if ('${spread.keys.toList()..sort()}' != '[1, 3, 5, 7, 9, 11]') {
    stderr.writeln('THE ODD LADDER BROKE: ${spread.keys}');
    exit(1);
  }
  if (spread[11] != 1) {
    stderr.writeln('THE ELEVEN IS NOT ALONE');
    exit(1);
  }
  final four = Rules(4);
  if ('${four.spread().keys.toList()..sort()}' != '[1, 3, 5]') {
    stderr.writeln('THE LITTLE HILL WENT EVEN');
    exit(1);
  }

  stdout.writeln(
      'every planting of every hill swept, 3 and 27 and 729 of '
      'them by size: the patch census matches the rim walk\'s '
      'parity on every one, the counts climb 1, 3, 5, 7, 9, 11 '
      'with never an even step, and the eleven belongs to '
      'exactly one planting');
  stdout.writeln('');

  for (var number = 0; number < Hills.count; number++) {
    final hill = Hills.at(number);
    final name = hill.name.padRight(16);
    stdout.writeln(hill.winnable
        ? ' ${number + 1} $name ${hill.task}: ${hill.ways} '
            'planting${hill.ways == 1 ? '' : 's'} of the sweep '
            'land${hill.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${hill.task}: none, the rim walk '
            'says odd and the sweep never saw an even count');
  }
}
