import 'dart:io';

import 'package:beadlow/bead/rings.dart';
import 'package:beadlow/bead/rules.dart';

/// Holds the counting against the shelf on every ring, and refuses
/// the bake on any disagreement: this is what `make rings` runs,
/// and the README quotes its ledger verbatim.
void main() {
  for (final ring in Rings.all) {
    final counted = Rules.byCounting(ring.beads, ring.dyes);
    final shelved = Rules.shelf(ring.beads, ring.dyes).length;
    if (counted != shelved || counted != ring.holds) {
      stderr.writeln('${ring.name}: counting $counted, shelf '
          '$shelved, label ${ring.holds}');
      exit(1);
    }
  }

  // The note-figures, each recomputed.
  if ('${Rules.fixedByTurn(6, 2)}' != '[64, 2, 4, 8, 4, 2]' ||
      '${Rules.fixedByTurn(4, 2)}' != '[16, 2, 4, 2]') {
    stderr.writeln('A FIXED-COUNT NOTE BROKE');
    exit(1);
  }
  // Five is prime: thirty mixed strings fold to six.
  final fiveShelf = Rules.shelf(5, 2);
  final mixedFive = fiveShelf
      .where((necklace) => necklace.toSet().length > 1)
      .length;
  if (fiveShelf.length != 8 || mixedFive != 6) {
    stderr.writeln('THE FIVE MISCOUNTED');
    exit(1);
  }
  // Three of three: three solids and eight mixed.
  final threeThree = Rules.shelf(3, 3);
  final solids = threeThree
      .where((necklace) => necklace.toSet().length == 1)
      .length;
  if (threeThree.length != 11 || solids != 3) {
    stderr.writeln('THE THREE OF THREE MISCOUNTED');
    exit(1);
  }

  stdout.writeln(
      'every ring counted two ways that share nothing: what each '
      'turn fixes, summed and divided by the turns, against the '
      'shelf of every string folded by turning: bead for bead '
      'they agree on every ring that ships');
  stdout.writeln('');

  for (var number = 0; number < Rings.count; number++) {
    final ring = Rings.at(number);
    final name = ring.name.padRight(19);
    final sizes = '${ring.beads} beads, ${ring.dyes} dyes';
    stdout.writeln(ring.winnable
        ? ' ${number + 1} $name $sizes  ${ring.task}: the ring '
            'holds exactly ${ring.holds}'
        : ' ${number + 1} $name $sizes  ${ring.task}: the ring '
            'holds only ${ring.holds}, and a seventh was never '
            'there');
  }
}
