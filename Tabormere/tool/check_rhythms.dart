import 'dart:io';

import 'package:tabormere/drum/levels.dart';
import 'package:tabormere/drum/play.dart';
import 'package:tabormere/drum/rules.dart';

/// Tries every pattern of every ring here and every ring to twelve steps,
/// holds the even ones to Euclid's rhythm and its turnings, and refuses
/// the bake on any disagreement: this is what `make rhythms` runs, and
/// the README quotes its ledger verbatim.
void main() {
  String commas(int n) {
    final s = n.toString();
    final out = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
      out.write(s[i]);
    }
    return out.toString();
  }

  // Every level's label against the sweep, the aim landing it, and no
  // level over at the opening.
  for (final level in Levels.all) {
    final met = Rules.patterns(level.steps, level.hits).where(level.meets).length;
    if (met != level.ways) {
      stderr.writeln('${level.name}: sweep finds $met of ${level.patterns}, label says ${level.ways}');
      exit(1);
    }
    final aim = level.aim;
    if (aim != null && !level.meets(aim)) {
      stderr.writeln('${level.name}: the aim $aim does not land it');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
    if (!level.equalGapsAsked) {
      final sweep = Rules.evenBySweep(level.steps, level.hits), euclid = Rules.evenByEuclid(level.steps, level.hits);
      if (sweep.length != euclid.length || !sweep.containsAll(euclid)) {
        stderr.writeln('${level.name}: THE SWEEP FINDS $sweep, EUCLID $euclid');
        exit(1);
      }
    }
  }

  // The two voices on every ring to twelve steps with every count of
  // hits: the even patterns of the sweep are exactly Euclid's rhythm and
  // its turnings, and Euclid's is always even.
  var rings = 0, patterns = 0, even = 0;
  for (var n = 1; n <= 12; n++) {
    for (var k = 0; k <= n; k++) {
      rings++;
      final all = Rules.patterns(n, k);
      patterns += all.length;
      final sweep = Rules.evenBySweep(n, k), euclid = Rules.evenByEuclid(n, k);
      even += sweep.length;
      if (sweep.length != euclid.length || !sweep.containsAll(euclid) || !Rules.isEven(n, Rules.euclid(n, k))) {
        stderr.writeln('$k IN $n: THE SWEEP FINDS ${sweep.length}, EUCLID ${euclid.length}');
        exit(1);
      }
      // The turnings of Euclid's rhythm number n over the greatest common
      // divisor of n and k, when there is a hit at all.
      if (k > 0 && euclid.length != n ~/ n.gcd(k)) {
        stderr.writeln('$k IN $n: ${euclid.length} TURNINGS');
        exit(1);
      }
      // Equal gaps come exactly when k divides n.
      final equal = all.where((p) => Rules.equalGaps(n, p)).length;
      if (k > 0 && (equal > 0) != (n % k == 0)) {
        stderr.writeln('$k IN $n: $equal PATTERNS WITH EQUAL GAPS');
        exit(1);
      }
    }
  }
  if (rings != 90 || patterns != 8190 || even != 474) {
    stderr.writeln('$rings RINGS, $patterns PATTERNS, $even EVEN');
    exit(1);
  }
  // The named rhythms.
  final named = <(int, int, String, String)>[
    (8, 3, 'x.x..x..', '3, 3, 2'),
    (8, 5, 'xx.xx.x.', '2, 1, 2, 1, 2'),
    (16, 5, 'x..x..x..x..x...', '3, 3, 4, 3, 3'),
    (12, 7, 'xx.x.xx.x.x.', '2, 1, 2, 2, 1, 2, 2'),
    (12, 5, 'x.x.x..x.x..', '2, 2, 3, 2, 3'),
    (9, 3, 'x..x..x..', '3, 3, 3'),
  ];
  for (final (n, k, told, gapsTold) in named) {
    final e = Rules.euclid(n, k);
    final g = (List.of(Rules.gaps(n, e))..sort()).reversed.toList();
    final want = (gapsTold.split(', ').map(int.parse).toList()..sort()).reversed.toList();
    if (Rules.told(n, e) != told || g.join(', ') != want.join(', ')) {
      stderr.writeln('$k IN $n: EUCLID IS ${Rules.told(n, e)} WITH GAPS ${Rules.gaps(n, e)}');
      exit(1);
    }
  }
  if (!Rules.evenBySweep(8, 3).contains('0,3,6') || !Rules.evenBySweep(8, 5).contains('0,2,3,5,6') || !Rules.evenBySweep(16, 5).contains('0,3,6,10,13') || !Rules.evenBySweep(12, 7).contains('0,2,3,5,7,8,10')) {
    stderr.writeln('THE NAMED TURNINGS ARE MISSING');
    exit(1);
  }
  if (Rules.patterns(8, 3).where((p) => Rules.equalGaps(8, p)).isNotEmpty || Rules.patterns(9, 3).where((p) => Rules.equalGaps(9, p)).length != 3) {
    stderr.writeln('THE EQUAL GAPS ARE OFF');
    exit(1);
  }

  stdout.writeln(
      'every pattern of every ring to twelve steps with every count of hits tried, '
      '90 rings and 8,190 patterns, and the even ones, 474 in all, are exactly '
      'Euclid\'s rhythm and its turnings on every ring, n over the greatest common '
      'divisor of n and k of them, with equal gaps exactly when the hits divide '
      'the steps; on the rings here three in eight go evenly 8 ways of 56, x.x..x.. '
      'and its turnings with gaps of 3, 3 and 2, five in eight 8 ways of 56, '
      'xx.xx.x. with gaps of 2, 1, 2, 1 and 2, five in sixteen 16 ways of 4,368, '
      'x..x..x..x..x... with gaps of 3, 3, 4, 3 and 3, and seven in twelve 12 ways '
      'of 792, xx.x.xx.x.x. with gaps of 2, 1, 2, 2, 1, 2 and 2; and no pattern of '
      'three in eight has equal gaps, while three in nine, x..x..x.., has them '
      'three ways');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${commas(level.patterns)} patterns land it'
        : ' ${number + 1} $name ${level.task}: none of the ${commas(level.patterns)}, and eight into three said so first');
  }
}
