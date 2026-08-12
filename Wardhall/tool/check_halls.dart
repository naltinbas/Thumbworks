import 'dart:io';

import 'package:wardhall/hall/halls.dart';
import 'package:wardhall/hall/rules.dart';

/// Posts every watch of every hall, holds the three-colouring
/// against the sweep, and refuses the bake on any disagreement:
/// this is what `make halls` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final hall in Halls.all) {
    // The sweep's fewest.
    final fewest = Rules.fewestWards(hall.corners);
    if (fewest != hall.fewest) {
      stderr.writeln('${hall.name}: sweep says $fewest, label says '
          '${hall.fewest}');
      exit(1);
    }
    // The three-colouring's watch: at most a third of the corners,
    // no triangle repeating a colour, and the whole floor lit.
    final colours = Rules.threeColours(hall.corners);
    for (final (a, b, c) in Rules.triangles(hall.corners)) {
      if (colours[a] == colours[b] ||
          colours[b] == colours[c] ||
          colours[a] == colours[c]) {
        stderr.writeln('${hall.name}: A TRIANGLE REPEATS A COLOUR');
        exit(1);
      }
    }
    final watch = Rules.fiskWatch(hall.corners);
    if (watch.length > hall.corners.length ~/ 3 ||
        Rules.unlit(hall.corners, watch).isNotEmpty) {
      stderr.writeln('${hall.name}: THE COLOURING\'S WATCH FAILED');
      exit(1);
    }
  }

  stdout.writeln(
      'the three-colouring cuts each hall into triangles, colours '
      'the corners so no triangle repeats one, and posts the '
      'scarcest colour: a watch of at most a third of the corners '
      'that lights the whole floor. The sweep posts every set of '
      'corners and finds the true fewest; the colouring is a roof, '
      'and on the comb the sweep walks under it');
  stdout.writeln('');

  for (var number = 0; number < Halls.count; number++) {
    final hall = Halls.at(number);
    final watch = Rules.fiskWatch(hall.corners);
    final name = hall.name.padRight(15);
    stdout.writeln(hall.winnable
        ? ' ${number + 1} $name ${hall.corners.length} corners  '
            '${hall.task}: the sweep needs ${hall.fewest}, the '
            'colouring posts ${watch.length}'
        : ' ${number + 1} $name ${hall.corners.length} corners  '
            '${hall.task}: the sweep needs ${hall.fewest}, and '
            'every pair leaves the floor part dark');
  }
}
