import 'dart:io';

import 'package:braidfell/braid/rules.dart';
import 'package:braidfell/braid/yards.dart';

/// Holds the lightest-first rule against the sweep of every order
/// on every yard, and refuses the bake on any disagreement: this is
/// what `make yards` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final yard in Yards.all) {
    final rule = Rules.lightestFirst(yard.bundles);
    final swept = Rules.leastWork(yard.bundles);
    if (rule != swept || swept != yard.least) {
      stderr.writeln('${yard.name}: rule $rule, sweep $swept, '
          'label ${yard.least}');
      exit(1);
    }
    if (yard.winnable != (yard.asked >= yard.least)) {
      stderr.writeln('${yard.name}: the label lied');
      exit(1);
    }
  }

  // The note-figures, each recomputed.
  if (Rules.mostWork(const [1, 2, 4, 8, 16]) != 113 ||
      Rules.mostWork(const [2, 3, 5, 7, 11]) != 95 ||
      Rules.mostWork(const [1, 2, 3]) != 11 ||
      Rules.mostWork(const [1, 1, 1, 1]) != 9 ||
      Rules.orders(5) != 180 ||
      Rules.orders(3) != 3) {
    stderr.writeln('A NOTE-FIGURE BROKE');
    exit(1);
  }

  stdout.writeln(
      'the lightest-first rule against the sweep of every braid '
      'order: they agree to the pound on every yard that ships, '
      'and the sweep knows the dearest order and everything '
      'between');
  stdout.writeln('');

  for (var number = 0; number < Yards.count; number++) {
    final yard = Yards.at(number);
    final name = yard.name.padRight(17);
    final bundles = yard.bundles.join(', ');
    stdout.writeln(yard.winnable
        ? ' ${number + 1} $name [$bundles]  ${yard.task}: '
            'lightest-first lands ${yard.least} over '
            '${Rules.orders(yard.bundles.length)} orders'
        : ' ${number + 1} $name [$bundles]  ${yard.task}: the '
            'sweep of all ${Rules.orders(yard.bundles.length)} '
            'orders bottoms out at ${yard.least}');
  }
}
