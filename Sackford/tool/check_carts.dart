import 'dart:io';

import 'package:sackford/yard/levels.dart';
import 'package:sackford/yard/rules.dart';

/// Searches every loading of every yard, holds the fewest carts to the
/// floor and the carrier's rule to its bound, and refuses the bake on
/// any disagreement: this is what `make carts` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the search.
  for (final level in Levels.all) {
    final (found, first) = Rules.loadings(level.sacks, level.carts);
    if (found != level.ways) {
      stderr.writeln('${level.name}: search finds $found, label says ${level.ways}');
      exit(1);
    }
    if (first != null && !level.meets(first)) {
      stderr.writeln('${level.name}: THE FIRST LOADING DOES NOT LOAD');
      exit(1);
    }
    if (level.winnable && Rules.floor(level.sacks) > level.carts) {
      stderr.writeln('${level.name}: LOADED UNDER THE FLOOR');
      exit(1);
    }
  }
  // Named facts.
  final ffdSlip = Rules.firstFitDecreasing([7, 5, 4, 4, 3, 3, 2, 2]);
  if (ffdSlip.length != 4 || ffdSlip.toString() != '[[7, 3], [5, 4], [4, 3, 2], [2]]') {
    stderr.writeln('THE CARRIER ON THE SLIP: $ffdSlip');
    exit(1);
  }
  if (Rules.fewest([7, 5, 4, 4, 3, 3, 2, 2]) != 3 || Rules.fewest([8, 7, 6, 5, 3, 2]) != 4 || Rules.floor([8, 7, 6, 5, 3, 2]) != 4 || Rules.loadings([8, 7, 6, 5, 3, 2], 4).$1 != 10) {
    stderr.writeln('THE FEWEST OR THE FLOOR MISREAD');
    exit(1);
  }
  final labelled = [
    Rules.loadings([6, 5, 5, 4, 4, 4, 2], 3, labelled: true).$1,
    Rules.loadings([7, 6, 5, 4, 3, 2, 1, 1, 1], 3, labelled: true).$1,
    Rules.loadings([7, 5, 4, 4, 3, 3, 2, 2], 3, labelled: true).$1,
  ];
  if (labelled.toString() != '[3, 14, 4]') {
    stderr.writeln('LABELLED COUNTS $labelled');
    exit(1);
  }
  // Every load of six sacks of one to nine stone: the fewest never under
  // the floor, the carrier never past eleven ninths of the fewest and
  // two thirds of a cart, and the count of loads he needs a cart too
  // many on.
  var loads = 0, slips = 0, tight = 0;
  void sweep(List<int> so, int from) {
    if (so.length == 6) {
      loads++;
      final few = Rules.fewest(so);
      final floor = Rules.floor(so);
      final carrier = Rules.firstFitDecreasing(so).length;
      if (few < floor) {
        stderr.writeln('$so: LOADED UNDER THE FLOOR');
        exit(1);
      }
      if (9 * carrier > 11 * few + 6) {
        stderr.writeln('$so: THE CARRIER PAST HIS BOUND');
        exit(1);
      }
      if (carrier > few) slips++;
      if (few == floor) tight++;
      return;
    }
    for (var v = from; v <= 9; v++) {
      sweep([...so, v], v);
    }
  }

  sweep([], 1);
  if (loads != 3003 || slips != 4 || tight != 2201) {
    stderr.writeln('$loads LOADS, $slips SLIPS, $tight AT THE FLOOR');
    exit(1);
  }

  stdout.writeln(
      'every loading of every yard searched, sack by sack into a cart in use or '
      'the next fresh one, no cart past ten stone, and told by the weights each '
      'cart carries: the sacks of six, four, three, three, two and two go into '
      'two carts 2 ways, the six, five, five, four, four, four and two into three '
      '1 way, every cart full, the seven, six, five, four, three, two, one, one '
      'and one into three 5 ways, and the seven, five, four, four, three, three, '
      'two and two into three 1 way, where the carrier\'s rule, heaviest first '
      'into the first cart with room, needs a fourth; the eight, seven, six, '
      'five, three and two, thirty-one stone, go into three carts no way and into '
      'four 10 ways, the floor being the weight over ten rounded up; and on every '
      'load of six sacks of one to nine stone, 3,003 loads, the fewest carts never '
      'beat the floor, meet it on 2,201, and the carrier\'s rule needs a cart too '
      'many on 4 and never more than eleven ninths of the fewest and two thirds');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(24);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} loading${level.ways == 1 ? '' : 's'} do${level.ways == 1 ? 'es' : ''} it'
        : ' ${number + 1} $name ${level.task}: none, and the floor said so first');
  }
}
