import 'dart:io';

import 'package:cellarwick/glass/levels.dart';
import 'package:cellarwick/glass/play.dart';
import 'package:cellarwick/glass/rules.dart';

/// Pours every setting of the two glasses and the spoon three ways in
/// exact fractions, holds every pouring to the account, and refuses the
/// bake on any disagreement: this is what `make spoons` runs, and the
/// README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, the aim landing it, and no
  // level over at the opening.
  for (final level in Levels.all) {
    final (met, all, first) = Rules.sweep(level.meets);
    if (met != level.ways || all != Rules.settings || Rules.settings != 500) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${Rules.settings}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? first != null : !level.meets(aim.$1, aim.$2, aim.$3)) {
      stderr.writeln('${level.name}: the aim $aim does not land it, the sweep finds $first');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }
  // The two voices on every setting and every stir: the pouring against
  // the account; and the well-stirred water back against its formula.
  var pourings = 0, misfits = 0;
  Frac biggest = Frac.zero;
  for (var wine = 1; wine <= Rules.most; wine++) {
    for (var water = 1; water <= Rules.most; water++) {
      for (var spoon = 1; spoon <= Rules.spoonMost; spoon++) {
        final stirs = [Rules.stirred(wine, water, spoon), Rules.floating(wine, water, spoon), Rules.sunk(wine, water, spoon)];
        if (stirs.any((p) => p == null)) {
          if (spoon <= wine || stirs.any((p) => p != null)) {
            stderr.writeln('$wine $water $spoon: A POURING WITHOUT A SPOONFUL');
            exit(1);
          }
          misfits++;
          continue;
        }
        for (final p in stirs) {
          pourings++;
          if (!Rules.accountHolds(p!)) {
            stderr.writeln('$wine $water $spoon: THE ACCOUNT FAILS, ${p.$1} WATER IN THE WINE, ${p.$2} WINE IN THE WATER');
            exit(1);
          }
        }
        final s = stirs[0]!;
        if (s.$1 != Frac.of(spoon * water, water + spoon)) {
          stderr.writeln('$wine $water $spoon: THE WATER BACK IS ${s.$1}');
          exit(1);
        }
        if (s.$1.compareTo(biggest) > 0) biggest = s.$1;
      }
    }
  }
  if (pourings != 1200 || misfits != 100 || biggest != Frac.of(10, 3)) {
    stderr.writeln('$pourings POURINGS, $misfits MISFITS, THE BIGGEST $biggest');
    exit(1);
  }
  // The named pourings.
  final tenths = <String>[];
  for (var wine = 1; wine <= 10; wine++) {
    for (var water = 1; water <= 10; water++) {
      for (var spoon = 1; spoon <= 5; spoon++) {
        if (Levels.at(1).meets(wine, water, spoon)) tenths.add('$wine,$water,$spoon');
      }
    }
  }
  if (tenths.join(' ') != '5,1,1 8,1,4 8,4,1 9,9,1 10,2,2' || Rules.stirred(10, 10, 1) != (Frac.of(10, 11), Frac.of(10, 11)) ||
      Rules.stirred(2, 2, 2) != (Frac.one, Frac.one) || Rules.stirred(10, 4, 4) != (Frac.of(2), Frac.of(2)) || Rules.stirred(10, 6, 3) != (Frac.of(2), Frac.of(2)) ||
      Rules.floating(10, 10, 1) != (Frac.zero, Frac.zero) || Rules.sunk(10, 10, 1) != (Frac.one, Frac.one) || Rules.sunk(10, 1, 3) != (Frac.one, Frac.one)) {
    stderr.writeln('THE NAMED POURINGS ARE OFF: $tenths');
    exit(1);
  }

  stdout.writeln(
      'every setting of the wine glass, the water glass and the spoon poured in '
      'exact fractions, one to ten units in each glass and one to five in the '
      'spoon, 500 settings, the spoon too big for the wine in 100 of them and the '
      'other 400 poured three ways, well stirred, unstirred with the wine afloat '
      'and unstirred with the wine sunk, 1,200 pourings, and in every one the '
      'water in the wine glass equals the wine in the water glass exactly; well '
      'stirred the water back is spoon times water over water plus spoon on every '
      'setting, 10/11 of a unit for ten, ten and one and 10/3 at the most; one '
      'unit comes back 9 ways of 500, all with two of water and a spoon of two, '
      'the wine glass ends one tenth water 5 ways, whole units come back 24 ways, '
      'the water glass ends half wine 40 ways, when the spoon holds as much as '
      'the water did, and more water in the wine than wine in the water never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(17);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the 500 settings land it'
        : ' ${number + 1} $name ${level.task}: none of the 500, and the account said so first');
  }
}
