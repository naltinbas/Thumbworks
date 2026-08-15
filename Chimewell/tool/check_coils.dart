import 'dart:io';
import 'dart:math';

import 'package:chimewell/coil/levels.dart';
import 'package:chimewell/coil/rules.dart';

/// Sweeps every setting of the two dials with exact fractions, holds
/// them against the cents, and refuses the bake on any disagreement:
/// this is what `make coils` runs, and the README quotes its ledger
/// verbatim.
void main() {
  BigInt n(int x) => BigInt.from(x);
  String cents(double c) => c.toStringAsFixed(2);

  // Every level's label against the sweep, and its aim lands it.
  for (final level in Levels.all) {
    final (met, all, first) = Rules.sweep(level.meets);
    if (met != level.ways || all != Rules.settings) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${Rules.settings}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? first != null : !level.meets(aim.$1, aim.$2)) {
      stderr.writeln('${level.name}: the aim $aim does not land it, the sweep finds $first');
      exit(1);
    }
  }

  // The two voices on every setting: the cents by the dials against the
  // cents by the fraction, the sign of the cents against the fraction's
  // side of home, and the twentieth by fraction against the twentieth by
  // cents. Every fraction is in lowest terms.
  final twentiethUp = 1200 * log(21 / 20) / log(2), twentiethDown = 1200 * log(19 / 20) / log(2);
  var withinTwentieth = 0, home = 0;
  final near = <(int, int)>[];
  for (var f = -Rules.fifths; f <= Rules.fifths; f++) {
    for (var o = -Rules.octaves; o <= Rules.octaves; o++) {
      final r = Rules.note(f, o);
      final byDials = Rules.cents(f, o), byFraction = Rules.centsOf(r);
      if ((byDials - byFraction).abs() > 1e-6) {
        stderr.writeln('CENTS DISAGREE AT $f, $o: $byDials BY THE DIALS, $byFraction BY THE FRACTION');
        exit(1);
      }
      if (r.$1.gcd(r.$2) != BigInt.one) {
        stderr.writeln('NOT IN LOWEST TERMS AT $f, $o: $r');
        exit(1);
      }
      if (Rules.home(r) != (f == 0 && o == 0) || Rules.home(r) != (byDials.abs() < 1e-9) || Rules.sharp(r) != (byDials > 1e-9)) {
        stderr.writeln('THE SIDE OF HOME DISAGREES AT $f, $o');
        exit(1);
      }
      final byFractionNear = Rules.within(r, 20), byCentsNear = byDials <= twentiethUp + 1e-9 && byDials >= twentiethDown - 1e-9;
      if (byFractionNear != byCentsNear) {
        stderr.writeln('THE TWENTIETH DISAGREES AT $f, $o');
        exit(1);
      }
      if (f != 0 && byFractionNear) {
        withinTwentieth++;
        near.add((f, o));
      }
      if (f != 0 && Rules.home(r)) home++;
    }
  }
  if (withinTwentieth != 2 || near.toString() != '[(-12, 7), (12, -7)]' || home != 0) {
    stderr.writeln('$withinTwentieth WITHIN A TWENTIETH, $near, $home HOME');
    exit(1);
  }

  // The named notes, as fractions and in cents.
  final named = <(int, int, int, int, String)>[
    (1, 0, 3, 2, '701.96'),
    (2, -1, 9, 8, '203.91'),
    (4, -2, 81, 64, '407.82'),
    (-5, 3, 256, 243, '90.22'),
    (5, -3, 243, 256, '-90.22'),
    (7, -4, 2187, 2048, '113.69'),
    (12, 0, 531441, 4096, '8423.46'),
    (12, -7, 531441, 524288, '23.46'),
    (-12, 7, 524288, 531441, '-23.46'),
  ];
  for (final (f, o, a, b, c) in named) {
    final r = Rules.note(f, o);
    if (r != (n(a), n(b)) || cents(Rules.cents(f, o)) != c) {
      stderr.writeln('$f, $o SOUNDS ${Rules.fraction(r)}, ${cents(Rules.cents(f, o))} CENTS, NOT $a/$b, $c');
      exit(1);
    }
  }
  // The comma is twelve fifths less seven octaves; the third of the
  // fifths is sharp of 5/4 by 81/80, 21.51 cents; the piano's fifth is
  // the pure fifth less a twelfth of the comma.
  if (n(3).pow(12) != n(531441) || n(2).pow(19) != n(524288) || n(4096) * n(128) != n(524288)) {
    stderr.writeln('THE POWERS ARE OFF');
    exit(1);
  }
  if (n(81) * n(4) * n(80) != n(64) * n(5) * n(81) || cents(Rules.cents(4, -2) - 1200 * log(5 / 4) / log(2)) != '21.51') {
    stderr.writeln('THE THIRD IS NOT 81/80 SHARP OF 5/4');
    exit(1);
  }
  if (cents(Rules.cents(1, 0) - Rules.cents(12, -7) / 12) != '700.00') {
    stderr.writeln('THE PIANO FIFTH IS NOT THE PURE FIFTH LESS A TWELFTH OF THE COMMA');
    exit(1);
  }
  // Five fifths miss the twentieth by 13 in 256, seven by 139 in 2,048;
  // 3 to any power is odd and 2 to any power even, on the dials' range.
  if ((n(256) - n(243)) * n(20) <= n(256) || (n(2187) - n(2048)) * n(20) <= n(2048)) {
    stderr.writeln('FIVE OR SEVEN FIFTHS COME WITHIN A TWENTIETH');
    exit(1);
  }
  for (var k = 1; k <= 2 * Rules.fifths + Rules.octaves; k++) {
    if (n(3).pow(k).isEven || n(2).pow(k).isOdd) {
      stderr.writeln('THE PARITY IS OFF AT $k');
      exit(1);
    }
  }

  stdout.writeln(
      'every setting of the two dials swept with exact fractions, fifths from '
      'twelve down to twelve up and octaves from eight down to eight up, 425 '
      'settings, and every one held against the cents: the fifth sounds 3/2 of '
      'the start, 701.96 cents; twelve fifths up climb 531,441/4,096, and seven '
      'octaves down leave 531,441/524,288, the comma, 23.46 cents sharp of home, '
      'the piano\'s fifth of 700.00 cents being the pure fifth less a twelfth of '
      'it; five fifths up and three octaves down sound 243/256, 13 in 256 short '
      'of home, and seven fifths up and four down 2,187/2,048, 139 in 2,048 '
      'over, both past a twentieth, and only twelve fifths, up or down, come '
      'within one, 2 settings of 425; the third of the fifths, 81/64, is '
      '81/80 sharp of 5/4, 21.51 cents; and no setting with a fifth in it comes '
      'home, since 3 to any power is odd and 2 to any power even');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(15);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${Rules.commas(n(Rules.settings))} settings ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of the ${Rules.commas(n(Rules.settings))}, and the parity said so first');
  }
}
