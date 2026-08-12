import 'dart:io';

import 'package:addlemoor/sum/moors.dart';
import 'package:addlemoor/sum/rules.dart';

/// Adds every triple, walks every painting, finds the walls, and
/// refuses the bake on any disagreement: this is what
/// `make tokens` runs, and the README quotes its ledger verbatim.
void main() {
  for (final moor in Moors.all) {
    final ways = Rules(moor.stones, moor.paints).ways();
    if (ways != moor.ways) {
      stderr.writeln('${moor.name}: sweep finds $ways, '
          'label says ${moor.ways}');
      exit(1);
    }
  }

  // The walls, recomputed from both sides.
  if (Rules(4, 2).ways() != 2 || Rules(5, 2).ways() != 0) {
    stderr.writeln('THE FIRST WALL MOVED');
    exit(1);
  }
  if (Rules(13, 3).ways() != 18 || Rules(14, 3).ways() != 0) {
    stderr.writeln('THE SECOND WALL MOVED');
    exit(1);
  }
  // The two four-paintings are each other's swap.
  final fours = <String>[];
  Rules(4, 2).paintings((painting) {
    fours.add(painting.join());
  });
  final swapped = fours.first
      .split('')
      .map((paint) => paint == '0' ? '1' : '0')
      .join();
  if (fours.length != 2 || fours.last != swapped) {
    stderr.writeln('THE FOURS ARE NOT SWAPS: $fours');
    exit(1);
  }
  // Every clean thirteen dies at the fourteenth stone.
  var extended = 0;
  Rules(13, 3).paintings((painting) {
    for (var paint = 0; paint < 3; paint++) {
      final longer = [...painting, paint];
      if (Rules.badSums(longer).isEmpty) extended++;
    }
  });
  if (extended != 0) {
    stderr.writeln('A THIRTEEN STRETCHED: $extended');
    exit(1);
  }

  stdout.writeln(
      'every painting walked with the bad sums pruned: two '
      'paints carry four stones exactly two ways and die at '
      'five, three paints thin from 288 at eight to 186 at '
      'eleven to 18 at thirteen and to nothing at fourteen, and '
      'not one of the eighteen thirteens takes a fourteenth '
      'stone in any paint');
  stdout.writeln('');

  for (var number = 0; number < Moors.count; number++) {
    final moor = Moors.at(number);
    final name = moor.name.padRight(20);
    stdout.writeln(moor.winnable
        ? ' ${number + 1} $name ${moor.task}: ${moor.ways} '
            'painting${moor.ways == 1 ? '' : 's'} of the sweep '
            'land${moor.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${moor.task}: none, which is '
            'Schur\'s wall standing where he left it');
  }
}
