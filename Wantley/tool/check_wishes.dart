import 'dart:io';

import 'package:wantley/wish/rules.dart';
import 'package:wantley/wish/wishes.dart';

/// Treads every yard, holds the three voices together over
/// every wish list there is, and refuses the bake on any
/// disagreement: this is what `make wishes` runs, and the
/// README quotes its ledger verbatim.
void main() {
  for (final wish in Wishes.all) {
    final ways = Rules(wish.farms).waysTo(wish.wishes);
    if (ways != wish.ways) {
      stderr.writeln('${wish.name}: sweep finds $ways, '
          'label says ${wish.ways}');
      exit(1);
    }
  }

  // The three voices, over every wish list of four and five.
  if (!Rules(4).voicesAgree() || !Rules(5).voicesAgree()) {
    stderr.writeln('THE VOICES PARTED');
    exit(1);
  }

  // Every landing of the round wish is one ring of all five.
  final five = Rules(5);
  var rings = true;
  five.treadings((trodden) {
    final walked = five.counts(trodden);
    if ('$walked' != '[2, 2, 2, 2, 2]') return;
    // Walk the ring from farm 0; it must visit all five.
    final beside = [
      for (var farm = 0; farm < 5; farm++) <int>[],
    ];
    for (var at = 0; at < five.pairs.length; at++) {
      if (!trodden[at]) continue;
      final (a, b) = five.pairs[at];
      beside[a].add(b);
      beside[b].add(a);
    }
    final seen = {0};
    var here = 0, from = -1;
    while (true) {
      final onward = beside[here]
          .where((farm) => farm != from)
          .toList();
      if (onward.isEmpty) break;
      from = here;
      here = onward.first;
      if (here == 0) break;
      seen.add(here);
    }
    if (seen.length != 5) rings = false;
  });
  if (!rings) {
    stderr.writeln('A ROUND WISH LANDED OFF THE RING');
    exit(1);
  }

  // Every landing of the seven ways spends exactly six paths.
  var six = true;
  five.treadings((trodden) {
    if ('${five.counts(trodden)}' != '[3, 3, 2, 2, 2]') return;
    if (trodden.where((tread) => tread).length != 6) six = false;
  });
  if (!six) {
    stderr.writeln('THE SEVEN WAYS MISPAID');
    exit(1);
  }

  // The one way is the built way, path for path.
  final built = five.build([4, 4, 3, 3, 2]);
  var only = <(int, int)>[];
  five.treadings((trodden) {
    if ('${five.counts(trodden)}' != '[4, 4, 3, 3, 2]') return;
    only = [
      for (var at = 0; at < five.pairs.length; at++)
        if (trodden[at]) five.pairs[at],
    ];
  });
  final one = built == null ? null : (List.of(built)..sort(
      (a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2));
  if ('$one' != '$only') {
    stderr.writeln('THE ONE WAY IS NOT THE BUILT WAY');
    exit(1);
  }

  // The dead list fails past parity: its sum is even.
  final deadSum = Wishes.at(4).wishes.reduce((a, b) => a + b);
  if (deadSum.isOdd || Rules.arithmeticSays(Wishes.at(4).wishes)) {
    stderr.writeln('THE DEAD LIST DIED WRONG');
    exit(1);
  }

  stdout.writeln(
      'every treading of every green swept, 64 of four farms and '
      '1,024 of five: the sweep, Erdos and Gallai\'s arithmetic '
      'and Havel and Hakimi\'s build agree on every wish list '
      'there is, every round-wish landing is one ring of all '
      'five, and the three threes fail with an even sum, since '
      'evenness is not the whole law');
  stdout.writeln('');

  for (var number = 0; number < Wishes.count; number++) {
    final wish = Wishes.at(number);
    final name = wish.name.padRight(18);
    stdout.writeln(wish.winnable
        ? ' ${number + 1} $name ${wish.task}: ${wish.ways} '
            'treading${wish.ways == 1 ? '' : 's'} of the sweep '
            'land${wish.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${wish.task}: none of the 64, '
            'and the arithmetic said so first');
  }
}
