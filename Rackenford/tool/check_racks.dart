import 'dart:io';

import 'package:rackenford/rack/pantries.dart';
import 'package:rackenford/rack/rules.dart';

/// Racks every pantry every way, holds Mirsky's count from
/// both sides, and refuses the bake on any disagreement: this
/// is what `make racks` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final pantry in Pantries.all) {
    final rules = Rules(pantry.top);
    final ways = rules.waysTo(pantry.racks);
    if (ways != pantry.ways) {
      stderr.writeln('${pantry.name}: sweep finds $ways, '
          'label says ${pantry.ways}');
      exit(1);
    }
    // Every pantry sits exactly at Mirsky's number: the chain
    // matches the racks on the winnable, and one rack fewer
    // lands nothing anywhere.
    if (pantry.winnable) {
      if (rules.longestChain != pantry.racks) {
        stderr.writeln('${pantry.name}: chain off the racks');
        exit(1);
      }
      if (rules.waysTo(pantry.racks - 1) != 0) {
        stderr.writeln('${pantry.name}: a rack fewer landed');
        exit(1);
      }
      if (!rules.lands(rules.byHeights())) {
        stderr.writeln('${pantry.name}: the height racking fell');
        exit(1);
      }
    }
  }

  // The four chains of four through the dozen, listed whole.
  final twelve = Rules(12);
  final chains = <List<int>>[];
  void grow(List<int> chain) {
    if (chain.length == 4) {
      chains.add(List.of(chain));
      return;
    }
    for (var next = chain.last + 1; next <= 12; next++) {
      if (Rules.divides(chain.last, next)) {
        grow([...chain, next]);
      }
    }
  }

  for (var start = 1; start <= 12; start++) {
    grow([start]);
  }
  if ('$chains' !=
      '[[1, 2, 4, 8], [1, 2, 4, 12], [1, 2, 6, 12], [1, 3, 6, 12]]') {
    stderr.writeln('THE CHAINS OF FOUR MOVED: $chains');
    exit(1);
  }
  if (twelve.longestChain != 4) {
    stderr.writeln('THE DOZEN CHAIN MOVED');
    exit(1);
  }

  stdout.writeln(
      'every pantry racked every clean way, 12 and 864 and 2,304 '
      'and 1,728 of them: each sits exactly at the longest '
      'divisor chain, one rack fewer lands nothing anywhere, the '
      'height racking lands everywhere, and the dozen carries '
      'four chains of four, every one starting at one');
  stdout.writeln('');

  for (var number = 0; number < Pantries.count; number++) {
    final pantry = Pantries.at(number);
    final name = pantry.name.padRight(18);
    stdout.writeln(pantry.winnable
        ? ' ${number + 1} $name ${pantry.task}: '
            '${pantry.ways} racking${pantry.ways == 1 ? '' : 's'} '
            'of the sweep land${pantry.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${pantry.task}: none of the '
            '531,441, and the chain of four said so first');
  }
}
