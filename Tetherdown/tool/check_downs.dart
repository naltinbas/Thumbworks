import 'dart:io';

import 'package:tetherdown/down/downs.dart';
import 'package:tetherdown/down/rules.dart';

/// Knots every triple, splits the pastures, sweeps every
/// tethering, and refuses the bake on any disagreement: this is
/// what `make ropes` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Mantel's line and shape over every size shipped.
  for (final posts in [4, 5, 6]) {
    final rules = Rules(posts);
    if (rules.fenceLine != rules.pastureMost()) {
      stderr.writeln('THE PASTURES MOVED THE FENCE AT $posts');
      exit(1);
    }
    if (rules.waysTo(rules.fenceLine + 1) != 0) {
      stderr.writeln('A ROPE PAST THE LINE AT $posts');
      exit(1);
    }
    if (!rules.fullestSplit()) {
      stderr.writeln('A FULLEST TETHERING THAT DOES NOT SPLIT '
          'AT $posts');
      exit(1);
    }
  }

  for (final down in Downs.all) {
    final ways = Rules(down.posts).waysTo(down.asked);
    if (ways != down.ways) {
      stderr.writeln('${down.name}: sweep finds $ways, '
          'label says ${down.ways}');
      exit(1);
    }
  }

  stdout.writeln(
      'every tethering of every down swept: the fence lines 4, 6 '
      'and 9 match the pasture arithmetic to the rope, no '
      'tethering past a line ever comes triangle-free, and every '
      'fullest tethering splits into two pastures with every '
      'crossing roped');
  stdout.writeln('');

  for (var number = 0; number < Downs.count; number++) {
    final down = Downs.at(number);
    final name = down.name.padRight(18);
    stdout.writeln(down.winnable
        ? ' ${number + 1} $name ${down.task}: ${down.ways} '
            'tethering${down.ways == 1 ? '' : 's'} of the sweep '
            'land${down.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${down.task}: none of the 120 '
            'tried, and the pastures say why');
  }
}
