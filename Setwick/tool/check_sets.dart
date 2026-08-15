import 'dart:io';

import 'package:setwick/set/dances.dart';
import 'package:setwick/set/rules.dart';

/// Pairs off every set every way, holds Bezout's partners to the
/// sweep, takes Wilson's product whole, and refuses the bake on
/// any disagreement: this is what `make sets` runs, and the
/// README quotes its ledger verbatim.
void main() {
  for (final dance in Dances.all) {
    final rules = Rules(dance.caller);
    final (all, landed) = rules.sweep();
    if (all != dance.pairings || landed != dance.ways) {
      stderr.writeln('${dance.name}: sweep finds $landed of $all, '
          'label says ${dance.ways} of ${dance.pairings}');
      exit(1);
    }
    // Bezout's pairing is the sweep's, pair for pair, or null
    // where nothing lands.
    final bezout = rules.landing();
    if ((bezout != null) != dance.winnable) {
      stderr.writeln('${dance.name}: Bezout ${bezout == null ? 'finds nothing' : 'lands'}');
      exit(1);
    }
    if (bezout != null) {
      Map<int, int>? swept;
      rules.pairings((pairs) {
        if (rules.lands(pairs)) swept = Map.of(pairs);
      });
      for (final dancer in rules.dancers) {
        if (swept![dancer] != bezout[dancer]) {
          stderr.writeln('${dance.name}: Bezout parts from the sweep at $dancer');
          exit(1);
        }
      }
    }
  }

  // Wilson, both ways, for every caller from 2 to 30: the product
  // of the set comes to n - 1 exactly when n is prime, to 2 for
  // four, and to nought for every other composite.
  for (var n = 2; n <= 30; n++) {
    final over = Rules.factorialOver(n);
    final want = Rules.isPrime(n) ? n - 1 : (n == 4 ? 2 : 0);
    if (over != want) {
      stderr.writeln('WILSON PARTED AT $n: $over, NOT $want');
      exit(1);
    }
  }
  // And a partner exists exactly when the dancer shares no factor
  // with the caller, for every dancer of every caller to 30.
  for (var n = 2; n <= 30; n++) {
    final rules = Rules(n);
    for (var d = 1; d < n; d++) {
      final partner = rules.partnerOf(d);
      final coprime = _gcd(d, n) == 1;
      if ((partner != null) != coprime) {
        stderr.writeln('PARTNER OF $d OVER $n: $partner, COPRIME $coprime');
        exit(1);
      }
      if (partner != null && !rules.comesToOne(d, partner)) {
        stderr.writeln('BEZOUT LIED AT $d OVER $n');
        exit(1);
      }
      if (partner != null && rules.row(d)[partner - 1] != 1) {
        stderr.writeln('THE ROW OF $d OVER $n DISAGREES');
        exit(1);
      }
    }
  }

  // The notes' numbers, taken whole.
  final wholes = {
    7: ('720', '102', '6'),
    11: ('3628800', '329890', '10'),
    13: ('479001600', '36846276', '12'),
    17: ('20922789888000', '1230752346352', '16'),
    9: ('40320', '4480', '0'),
  };
  for (final entry in wholes.entries) {
    final n = entry.key;
    final f = Rules.factorial(n);
    final q = f ~/ BigInt.from(n);
    final r = f % BigInt.from(n);
    if ('$f' != entry.value.$1 || '$q' != entry.value.$2 || '$r' != entry.value.$3) {
      stderr.writeln('THE WHOLE PRODUCT OF $n MOVED: $f = $q x $n + $r');
      exit(1);
    }
  }
  // Dancer 3's row over nine, and dancer 6's.
  if ('${Rules(9).row(3)}' != '[3, 6, 0, 3, 6, 0, 3, 6]' ||
      '${Rules(9).row(6)}' != '[6, 3, 0, 6, 3, 0, 6, 3]') {
    stderr.writeln('THE ROWS OVER NINE MOVED: ${Rules(9).row(3)}');
    exit(1);
  }

  stdout.writeln(
      'every pairing of every set swept, 3 and 105 and 945 and 135,135 of '
      'them and 15 for the set of nine: exactly one lands for each prime '
      'caller and it is Bezout\'s, pair for pair, none lands for nine, '
      'where dancers 3 and 6 come to one with nobody, and the whole set '
      'multiplied comes to one less than the caller for every prime to '
      'thirty and to nought for every composite past four');
  stdout.writeln('');

  for (var number = 0; number < Dances.count; number++) {
    final dance = Dances.at(number);
    final name = dance.name.padRight(20);
    stdout.writeln(dance.winnable
        ? ' ${number + 1} $name ${dance.task}: 1 pairing of the '
            '${_commas(dance.pairings)} lands it'
        : ' ${number + 1} $name ${dance.task}: none of the '
            '${dance.pairings}, and the row of 3 said so first');
  }
}

int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

/// 135135 as 135,135.
String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
