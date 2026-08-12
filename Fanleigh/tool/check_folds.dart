import 'dart:io';

import 'package:fanleigh/fold/folds.dart';
import 'package:fanleigh/fold/rules.dart';

/// Lays every fence, counts every pen, finds every ear, and
/// refuses the bake on any disagreement: this is what
/// `make hurdles` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Catalan's counts and the whole law, both paddocks.
  final counts = {5: 5, 6: 14};
  for (final posts in [5, 6]) {
    final rules = Rules(posts);
    if (rules.foldings() != counts[posts]) {
      stderr.writeln('CATALAN PARTED AT $posts: '
          '${rules.foldings()}');
      exit(1);
    }
    if (!rules.lawHolds()) {
      stderr.writeln('THE LAW BROKE AT $posts');
      exit(1);
    }
  }

  for (final fold in Folds.all) {
    final ways = Rules(fold.posts).waysTo(fold.lands);
    if (ways != fold.ways) {
      stderr.writeln('${fold.name}: sweep finds $ways, '
          'label says ${fold.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  final six = Rules(6);
  var threeEars = 0;
  var zigzags = 0;
  six.fencings((hurdles) {
    if (six.ears(hurdles).length == 3) threeEars++;
    final crowned = six.crown(hurdles);
    if (crowned.every((pens) => pens == 1 || pens == 3)) {
      zigzags++;
    }
  });
  if (threeEars != 2 || zigzags != 2) {
    stderr.writeln('THE ZIGZAGS MOVED: $threeEars, $zigzags');
    exit(1);
  }
  if (six.waysTo((crown) => crown.contains(4)) +
          six.waysTo((crown) => crown.every((pens) => pens <= 3)) !=
      14) {
    stderr.writeln('THE FANS AND THE EVEN DO NOT SPLIT');
    exit(1);
  }
  final five = Rules(5);
  var pentEars = true;
  five.fencings((hurdles) {
    if (five.ears(hurdles).length != 2) pentEars = false;
  });
  if (!pentEars) {
    stderr.writeln('A PENTAGON WITHOUT ITS TWO EARS');
    exit(1);
  }

  stdout.writeln(
      'every fencing of both paddocks laid: five foldings of the '
      'pentagon and fourteen of the hexagon, Catalan\'s own, '
      'every crown summing to three pens a fold, no two foldings '
      'sharing a crown, and never fewer than two ears anywhere');
  stdout.writeln('');

  for (var number = 0; number < Folds.count; number++) {
    final fold = Folds.at(number);
    final name = fold.name.padRight(16);
    stdout.writeln(fold.winnable
        ? ' ${number + 1} $name ${fold.task}: ${fold.ways} '
            'folding${fold.ways == 1 ? '' : 's'} of the sweep '
            'land${fold.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${fold.task}: none of the '
            'fourteen, by the two-ears theorem');
  }
}
