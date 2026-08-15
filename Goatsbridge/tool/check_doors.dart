import 'dart:io';

import 'package:goatsbridge/stall/levels.dart';
import 'package:goatsbridge/stall/rules.dart';

/// Counts every case of every stall on the sham, holds the count to the
/// formula, and refuses the bake on any disagreement: this is what
/// `make doors` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep.
  for (final level in Levels.all) {
    final (met, all) = Rules.sweep(level.meets);
    if (met != level.ways || all != level.settings) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
  }
  // The cases against the formula on all 72 settings; staying never
  // beating or tying switching; the worst switch; the eight over half.
  var settings = 0;
  (int, int)? worst;
  (int, int, bool)? worstAt;
  var overHalf = 0, overHalfAllButOne = 0;
  Rules.sweep((n, k, sw) {
    settings++;
    final f = Rules.byFormula(n, k, sw), c = Rules.byCases(n, k, sw);
    if (f != c) {
      stderr.writeln('$n DOORS, $k OPENED, ${sw ? 'SWITCH' : 'STAY'}: FORMULA $f, CASES $c');
      exit(1);
    }
    if (!sw && Rules.compare(f, Rules.byFormula(n, k, true)) >= 0) {
      stderr.writeln('$n DOORS, $k OPENED: STAYING $f IS NOT BEATEN BY SWITCHING');
      exit(1);
    }
    if (sw && (worst == null || Rules.compare(f, worst!) < 0)) {
      worst = f;
      worstAt = (n, k, sw);
    }
    if (Rules.compare(f, (1, 2)) > 0) {
      overHalf++;
      if (sw && k == n - 2) overHalfAllButOne++;
    }
    return false;
  });
  if (settings != 72 || worst != (9, 80) || worstAt != (10, 1, true) || overHalf != 8 || overHalfAllButOne != 8) {
    stderr.writeln('$settings SETTINGS, WORST $worst AT $worstAt, $overHalf OVER HALF, $overHalfAllButOne OF THEM ALL BUT ONE');
    exit(1);
  }
  final named = <(int, int, bool), (int, int)>{
    (3, 1, false): (1, 3),
    (3, 1, true): (2, 3),
    (4, 1, true): (3, 8),
    (4, 2, true): (3, 4),
    (5, 3, true): (4, 5),
    (10, 8, true): (9, 10),
    (10, 1, true): (9, 80),
  };
  for (final e in named.entries) {
    final (n, k, sw) = e.key;
    if (Rules.byFormula(n, k, sw) != e.value) {
      stderr.writeln('$n DOORS, $k OPENED, ${sw ? 'SWITCH' : 'STAY'}: ${Rules.byFormula(n, k, sw)}, NOT ${e.value}');
      exit(1);
    }
  }
  if (Rules.inHundred((9, 80)) != '11.25' || Rules.inHundred((2, 3)) != '66.66') {
    stderr.writeln('IN A HUNDRED MISREAD');
    exit(1);
  }

  stdout.writeln(
      'every stall of three to ten doors with the host opening one to all but '
      'one, staying or switching, 72 settings, every case counted, the cart\'s '
      'door and the pick each of n, the host\'s choice of goat doors and the '
      'switch\'s landing each equally, and held to the formula, staying 1/n and '
      'switching (n - 1)/n times 1/(n - 1 - k), the two agreeing on all 72: three '
      'doors and one opened, staying wins 1 in 3 and switching 2 in 3; four doors, '
      'switching wins 3 in 8 with one opened and 3 in 4 with two; ten doors and '
      'eight opened, 9 in 10; ten doors and one opened, 9 in 80, 11.25 in a '
      'hundred, the least switching ever wins on the sham and still more than '
      'staying\'s 1 in 10; eight settings win more than half, every one of them '
      'switching with all the doors but one opened; and staying never wins more '
      'than switching, nor as many, on any of the 72');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(16);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.settings} settings land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.settings}, and the count said so first');
  }
}
