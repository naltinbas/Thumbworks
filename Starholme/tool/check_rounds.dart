import 'dart:io';

import 'package:starholme/round/rules.dart';
import 'package:starholme/round/tours.dart';

/// Walks every round of the star at every length, holds the
/// census and the two-per-post law, and refuses the bake on
/// any disagreement: this is what `make rounds` runs, and the
/// README quotes its ledger verbatim.
void main() {
  for (final tour in Tours.all) {
    final ways = Rules.waysTo(tour.posts);
    if (ways != tour.ways) {
      stderr.writeln('${tour.name}: sweep finds $ways, '
          'label says ${tour.ways}');
      exit(1);
    }
  }

  // The census whole, the missing seven included, and the
  // nines two per left-out post.
  if (!Rules.lawsHold()) {
    stderr.writeln('A LAW BROKE');
    exit(1);
  }

  // Every eight-round leaves out two posts sharing a lane.
  var eightsSound = true;
  Rules.rounds(8, (walk) {
    final out = [
      for (var post = 0; post < 10; post++)
        if (!walk.contains(post)) post,
    ];
    if (out.length != 2 || !Rules.beside(out[0], out[1])) {
      eightsSound = false;
    }
  });
  if (!eightsSound) {
    stderr.writeln('AN EIGHT LEFT A PARTED PAIR');
    exit(1);
  }

  stdout.writeln(
      'every closed round of the star walked at every length: '
      'twelve pentagons, ten hexagons, fifteen eights and '
      'twenty nines, never a seven-round and never the full '
      'ten, the nines splitting two apiece over the ten posts '
      'left out, and every eight leaving out a pair that '
      'shares a lane');
  stdout.writeln('');

  for (var number = 0; number < Tours.count; number++) {
    final tour = Tours.at(number);
    final name = tour.name.padRight(18);
    stdout.writeln(tour.winnable
        ? ' ${number + 1} $name ${tour.task}: ${tour.ways} '
            'round${tour.ways == 1 ? '' : 's'} of the sweep '
            'stand${tour.ways == 1 ? 's' : ''}'
        : ' ${number + 1} $name ${tour.task}: none at all, and '
            'the twenty nines are the nearest misses');
  }
}
