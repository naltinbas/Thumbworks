import 'dart:io';

import 'package:wheelford/wheel/cordings.dart';
import 'package:wheelford/wheel/rules.dart';

/// Cords every three and four of the twelve, holds Thales' reading to
/// the corner test on every triangle, and refuses the bake on any
/// disagreement: this is what `make wheels` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // The twelve pegs all sit on the rim, and they are all the
  // whole-number places that do.
  final rim = <(int, int)>[];
  for (var x = -5; x <= 5; x++) {
    for (var y = -5; y <= 5; y++) {
      if (x * x + y * y == Rules.radiusSquared) rim.add((x, y));
    }
  }
  if (rim.length != 12 || !Rules.pegs.every(Rules.onRim) || !rim.every(Rules.pegs.contains)) {
    stderr.writeln('THE RIM HAS ${rim.length} PEGS');
    exit(1);
  }

  // Thales both ways on every triangle: a square corner exactly
  // where the far cord is a diameter.
  var triples = 0, right = 0, sharp = 0, blunt = 0;
  Rules.triples((three) {
    triples++;
    final corners = Rules.squareCorners(three);
    final across = Rules.cornersAcrossDiameters(three);
    if ('$corners' != '$across') {
      stderr.writeln('THALES PARTED AT $three: corners $corners, diameters $across');
      exit(1);
    }
    if (corners.isNotEmpty) right++;
    if (Rules.sharp(three)) sharp++;
    if (corners.isEmpty && !Rules.sharp(three)) blunt++;
  });
  if (triples != 220 || right != 60 || sharp != 40 || blunt != 120) {
    stderr.writeln('THE TRIANGLES MOVED: $triples $right $sharp $blunt');
    exit(1);
  }
  var quads = 0, squares = 0;
  Rules.quads((four) {
    quads++;
    if (Rules.makesSquare(four)) {
      squares++;
      // Two diameters crossing square.
      final ds = <(int, int)>[];
      for (var i = 0; i < 4; i++) {
        for (var j = i + 1; j < 4; j++) {
          if (Rules.isDiameter(four[i], four[j])) ds.add(Rules.diff(four[i], four[j]));
        }
      }
      if (ds.length != 2 || Rules.dot(ds[0], ds[1]) != 0) {
        stderr.writeln('A SQUARE WITHOUT TWO SQUARE DIAMETERS: $four');
        exit(1);
      }
    }
  });
  if (quads != 495 || squares != 3) {
    stderr.writeln('THE SQUARES MOVED: $quads $squares');
    exit(1);
  }
  for (final cording in Cordings.all) {
    var sets = 0, ways = 0;
    void consider(List<Peg> set) {
      if (!cording.given.every(set.contains)) return;
      sets++;
      if (cording.meets(set)) ways++;
    }

    if (cording.pegs == 3) {
      Rules.triples(consider);
    } else {
      Rules.quads(consider);
    }
    if (sets != cording.sets || ways != cording.ways) {
      stderr.writeln('${cording.name}: sweep finds $ways of $sets, label says ${cording.ways} of ${cording.sets}');
      exit(1);
    }
  }
  // The given two: the third peg is across from one of them.
  final given = Cordings.at(3).given;
  final thirds = <Peg>[];
  for (final peg in Rules.pegs) {
    if (given.contains(peg)) continue;
    if (Rules.squareCorners([...given, peg]).isNotEmpty) thirds.add(peg);
  }
  if ('$thirds' != '[(-5, 0), (0, -5)]') {
    stderr.writeln('THE THIRDS MOVED: $thirds');
    exit(1);
  }

  stdout.writeln(
      'every three of the twelve rim pegs corded, 220 triangles, and every '
      'corner tested two ways, by the dot product and by whether the cord '
      'across runs through the hub: sixty triangles have a square corner '
      'and every one of them looks across at a diameter, forty are sharp '
      'all round and a hundred and twenty blunt, three of the 495 fours '
      'are squares, each two diameters crossing square, and no square '
      'corner on the wheel ever looks across at anything but a diameter');
  stdout.writeln('');

  for (var number = 0; number < Cordings.count; number++) {
    final cording = Cordings.at(number);
    final name = cording.name.padRight(17);
    stdout.writeln(cording.winnable
        ? ' ${number + 1} $name ${cording.task}: ${cording.ways} of the ${cording.sets} '
            'cordings land it'
        : ' ${number + 1} $name ${cording.task}: none of the ${cording.sets}, and Thales said so first');
  }
}
