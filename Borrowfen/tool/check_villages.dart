import 'dart:io';

import 'package:borrowfen/debt/rules.dart';
import 'package:borrowfen/debt/villages.dart';

/// Burns, censuses and searches every village, and refuses the
/// bake on any disagreement: this is what `make villages` runs,
/// and the README quotes its ledger verbatim.
void main() {
  for (final village in Villages.all) {
    final rules = Rules(village.houses, village.roads);

    // Census against Kirchhoff: two counts that share nothing.
    final census = rules.superstables().length;
    final trees = rules.spanningTrees();
    if (census != trees) {
      stderr.writeln('${village.name}: census $census, '
          'Kirchhoff $trees');
      exit(1);
    }

    // The three verdicts on the level's own spread.
    final burning = rules.winnable(village.spread);
    final searched = rules.fewest(village.spread);
    if (burning != (searched != null)) {
      stderr.writeln('${village.name}: burning says $burning, '
          'search says $searched');
      exit(1);
    }
    if (burning != village.winnable) {
      stderr.writeln('${village.name}: label lies');
      exit(1);
    }
    if (searched != village.fewest) {
      stderr.writeln('${village.name}: fewest is $searched, '
          'label says ${village.fewest}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  final lane = Rules(3, const [(0, 1), (1, 2)]);
  if (lane.spanningTrees() != 1 || lane.genus != 0) {
    stderr.writeln('THE LANE GREW A RING');
    exit(1);
  }
  final green = Rules(4, const [(0, 1), (1, 2), (2, 3), (3, 0)]);
  if (green.genus != 1 || green.winnableClasses(1) != 4) {
    stderr.writeln('THE GREEN\'S POUND FAILED');
    exit(1);
  }
  final charity =
      Rules(4, const [(0, 1), (1, 2), (0, 2), (1, 3), (2, 3)]);
  if (charity.genus != 2 ||
      charity.winnableClasses(2) != 8 ||
      charity.winnableClasses(1) != 4) {
    stderr.writeln('THE CHARITY MISCOUNTED');
    exit(1);
  }
  final round = Rules(3, const [(0, 1), (1, 2), (0, 2)]);
  if (round.spanningTrees() != 3 || round.winnableClasses(0) != 1) {
    stderr.writeln('THE ROUND MISCOUNTED');
    exit(1);
  }
  // The hopeless pound, all three ways.
  final pound = Villages.at(4);
  final poundRules = Rules(pound.houses, pound.roads);
  if (poundRules.tidy(pound.spread)[0] >= 0 ||
      poundRules.fewest(pound.spread) != null ||
      pound.total != 0) {
    stderr.writeln('THE SHORT POUND SETTLED');
    exit(1);
  }

  stdout.writeln(
      'every village censused twice: the tidy spreads number '
      'exactly the spanning trees, 1, 4, 8, 8 and 3, Dhar\'s '
      'burning against Kirchhoff\'s determinant, and on every '
      'level the burning\'s verdict, the label and the search '
      'agree');
  stdout.writeln('');

  for (var number = 0; number < Villages.count; number++) {
    final village = Villages.at(number);
    final name = village.name.padRight(20);
    stdout.writeln(village.winnable
        ? ' ${number + 1} $name ${village.task}: fewest '
            '${village.fewest} move${village.fewest == 1 ? '' : 's'}, '
            'proven by the search'
        : ' ${number + 1} $name ${village.task}: the burning, the '
            'census and the search all refuse it');
  }
}
