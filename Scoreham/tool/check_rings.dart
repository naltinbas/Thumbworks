import 'dart:io';

import 'package:scoreham/score/rings.dart';
import 'package:scoreham/score/rules.dart';

/// Walks every start of every ring, holds the ledger and the ebb
/// against the walk on every ring to a dozen marks, and refuses the
/// bake on any disagreement: this is what `make rings` runs, and
/// the README quotes its ledger verbatim.
void main() {
  if (!Rules.allThreeAgree(12)) {
    stderr.writeln('THE THREE VOICES PARTED');
    exit(1);
  }

  for (final ring in Rings.all) {
    final goods = Rules.goodStarts(ring.marks);
    final ran = Rules.ahead(ring.marks);
    if (goods.length != ring.goods ||
        (ran > 0 ? ran : 0) != ring.goods) {
      stderr.writeln('${ring.name}: walk finds ${goods.length}, '
          'the lead says $ran, label says ${ring.goods}');
      exit(1);
    }
    if (ring.winnable &&
        !goods.contains(Rules.pastTheEbb(ring.marks))) {
      stderr.writeln('${ring.name}: THE EBB START FAILED');
      exit(1);
    }
  }

  stdout.writeln(
      'a ring holds exactly as many good starts as it runs ahead, '
      'and the start just past the last lowest ebb is always one '
      'of them: the walk, the ledger, and the ebb agree on every '
      'ring of up to a dozen marks, all 8,190 of them');
  stdout.writeln('');

  for (var number = 0; number < Rings.count; number++) {
    final ring = Rings.at(number);
    final notches =
        ring.marks.where((mark) => mark == 1).length;
    final wipes = ring.marks.length - notches;
    final name = ring.name.padRight(14);
    stdout.writeln(ring.winnable
        ? ' ${number + 1} $name $notches notches, $wipes wipes  '
            '${ring.task}: the ring runs ${ring.goods} ahead and '
            'holds exactly ${ring.goods}'
        : ' ${number + 1} $name $notches notches, $wipes wipes  '
            '${ring.task}: the ring runs nothing ahead, and no '
            'start stays off the ground');
  }
}
