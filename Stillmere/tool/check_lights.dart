import 'dart:io';

import 'package:stillmere/mere/lightings.dart';
import 'package:stillmere/mere/rules.dart';

/// Sweeps every lighting of the mere for every count, counts the
/// shapes, runs the three-light argument, and refuses the bake on
/// any disagreement: this is what `make lights` runs, and the README
/// quotes its ledger verbatim.
void main() {
  final rules = Rules();
  for (final lighting in Lightings.all) {
    final (ways, shapes) = rules.sweep(lighting.count);
    if (ways != lighting.ways || shapes != lighting.shapes) {
      stderr.writeln('${lighting.name}: sweep finds $ways ways in $shapes shapes, '
          'label says ${lighting.ways} in ${lighting.shapes}');
      exit(1);
    }
  }

  // The rule itself on the block, the tub, the boat, and a blinker
  // that is not still.
  const block = {(1, 1), (2, 1), (1, 2), (2, 2)};
  const tub = {(1, 0), (0, 1), (2, 1), (1, 2)};
  const boat = {(1, 0), (0, 1), (2, 1), (1, 2), (2, 2)};
  const blinker = {(1, 0), (1, 1), (1, 2)};
  if (!Rules.still(block) || !Rules.still(tub) || !Rules.still(boat) || Rules.still(blinker)) {
    stderr.writeln('THE RULE MOVED ON THE NAMED SHAPES');
    exit(1);
  }
  final turned = Rules.next(blinker);
  if (turned.length != 3 || !turned.containsAll(const {(0, 1), (1, 1), (2, 1)})) {
    stderr.writeln('THE BLINKER DID NOT TURN: $turned');
    exit(1);
  }
  // Four: sixteen blocks and nine tubs; five: the boat four ways in
  // nine places.
  var blocks = 0, tubs = 0;
  rules.lightings(4, (lit) {
    if (!Rules.still(lit)) return;
    if (Rules.shapeOf(lit) == Rules.shapeOf(block)) blocks++;
    if (Rules.shapeOf(lit) == Rules.shapeOf(tub)) tubs++;
  });
  if (blocks != 16 || tubs != 9) {
    stderr.writeln('BLOCKS $blocks, TUBS $tubs');
    exit(1);
  }
  final boatShapes = <String, int>{};
  rules.lightings(5, (lit) {
    if (!Rules.still(lit)) return;
    final shape = Rules.shapeOf(lit);
    boatShapes[shape] = (boatShapes[shape] ?? 0) + 1;
  });
  if (boatShapes.length != 4 || boatShapes.values.any((n) => n != 9) || !boatShapes.containsKey(Rules.shapeOf(boat))) {
    stderr.writeln('THE BOATS MOVED: $boatShapes');
    exit(1);
  }

  // Three lights: those where every light has two or more lit
  // neighbours are exactly 64, every one three corners of a square,
  // and every one lights its fourth corner.
  var touching = 0;
  rules.lightings(3, (lit) {
    if (lit.any((s) => Rules.litRound(lit, s) < 2)) return;
    touching++;
    var mx = 9, my = 9, wx = -1, wy = -1;
    for (final (x, y) in lit) {
      if (x < mx) mx = x;
      if (y < my) my = y;
      if (x > wx) wx = x;
      if (y > wy) wy = y;
    }
    if (wx - mx != 1 || wy - my != 1) {
      stderr.writeln('THREE TOUCHING LIGHTS NOT IN A SQUARE: $lit');
      exit(1);
    }
    if (Rules.births(lit).length != 1) {
      stderr.writeln('THREE CORNERS DID NOT LIGHT THE FOURTH: $lit');
      exit(1);
    }
  });
  if (touching != 64) {
    stderr.writeln('$touching THREE-LIGHTINGS TOUCH, NOT 64');
    exit(1);
  }

  stdout.writeln(
      'every lighting of the mere swept for four, five, six and seven '
      'lanterns and the rule run on the whole plane: four lie still 25 '
      'ways in two shapes, sixteen blocks and nine tubs, five 36 ways in '
      'the boat\'s four turnings, six 94 ways in fourteen shapes and seven 76 '
      'ways in twenty; three lanterns never lie still, since the '
      'lightings where every light has two lit neighbours, 64 of them, are all three '
      'corners of a square and every one lights the fourth');
  stdout.writeln('');

  for (var number = 0; number < Lightings.count; number++) {
    final lighting = Lightings.at(number);
    final name = lighting.name.padRight(17);
    stdout.writeln(lighting.winnable
        ? ' ${number + 1} $name ${lighting.task}: ${lighting.ways} lightings of the sweep '
            'lie still, ${lighting.shapes} shape${lighting.shapes == 1 ? '' : 's'}'
        : ' ${number + 1} $name ${lighting.task}: none, and the fourth corner said so first');
  }
}
