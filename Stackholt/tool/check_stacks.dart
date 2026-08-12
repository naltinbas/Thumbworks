import 'dart:io';

import 'package:stackholt/stack/boxsets.dart';
import 'package:stackholt/stack/play.dart';
import 'package:stackholt/stack/rules.dart';

/// Turns every cube every way, factors the colours, counts the
/// faces, and refuses the bake on any disagreement: this is what
/// `make stacks` runs, and the README quotes its ledger verbatim.
void main() {
  for (final set in BoxSets.all) {
    // No stack opens settled: there must be something to do.
    final opening = Play.of(set);
    if (opening.isDone) {
      stderr.writeln('${set.name}: opens already settled');
      exit(1);
    }
    final ways = Rules.settlings(set.boxes);
    if (ways != set.ways) {
      stderr.writeln('${set.name}: sweep finds $ways, '
          'label says ${set.ways}');
      exit(1);
    }
    // A winnable stack's first settling must satisfy the walls.
    if (set.winnable) {
      final stood = Rules.settling(set.boxes)!;
      if (!Rules.settled(stood)) {
        stderr.writeln('${set.name}: the settling does not settle');
        exit(1);
      }
    }
    // On four boxes of four colours, the factoring must agree
    // with the sweep about whether the stack settles at all.
    if (set.count == 4 && Rules.colours(set.boxes).length == 4) {
      if (Rules.factors(set.boxes) != set.winnable) {
        stderr.writeln('${set.name}: the factoring disagrees');
        exit(1);
      }
    }
  }

  // The red count on the hopeless stack, recomputed.
  final red = BoxSets.at(4);
  if (Rules.facesWearing(red.boxes, 'R') != 13 ||
      Rules.roomFor(4) != 12 ||
      Rules.settlings(red.boxes) != 0) {
    stderr.writeln('THE RED STACK FOUND ROOM');
    exit(1);
  }
  // The old four: 24 settlings in 3 classes, 5 fair picks in 3
  // pencil factorings, every number recomputed.
  final old = BoxSets.at(3);
  if (Rules.settlings(old.boxes) != 24 ||
      Rules.settlingClasses(old.boxes) != 3 ||
      Rules.fairPickCount(old.boxes) != 5 ||
      Rules.factorings(old.boxes) != 3) {
    stderr.writeln('THE OLD FOUR MOVED');
    exit(1);
  }

  stdout.writeln(
      'every stack swept standing by standing: the wall check, '
      'the sweep and the pencil factoring never part, the old '
      'four settles 24 ways that wear down to three once '
      'whole-stack turns and mirrorings go, its five fair picks '
      'pair into three pencil factorings, and the red stack is '
      'doomed by a count on one hand, thirteen red faces where a '
      'standing stack carries twelve');
  stdout.writeln('');

  for (var number = 0; number < BoxSets.count; number++) {
    final set = BoxSets.at(number);
    final name = set.name.padRight(14);
    stdout.writeln(set.winnable
        ? ' ${number + 1} $name ${set.task}: ${set.ways} '
            'settlings by the sweep'
        : ' ${number + 1} $name ${set.task}: none, by the count, '
            'the factoring and the sweep all three');
  }
}
