// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:staplemere/yard/fewest.dart';

/// Digs up mornings worth shipping.
///
/// A deal is kept only when the three answers agree, which they always do,
/// and when setting every bale on the heaviest top that can take it, the
/// hoarder's way, ends at least one pile over. That way every shipped deal
/// has somewhere for the tempting mistake to fall.
///
/// Run with: dart run tool/find_deals.dart
void main() {
  final random = Random(28);

  for (final want in [
    (bales: 5, fewest: 2),
    (bales: 7, fewest: 3),
    (bales: 12, fewest: 4),
    (bales: 16, fewest: 5),
  ]) {
    for (var go = 0; go < 200000; go++) {
      final tods = _weighed(random, want.bales);
      final fewest = Runs.thread(tods).length;
      if (fewest != want.fewest) continue;
      if (Runs.byBestFit(const [], tods) != fewest) continue;
      if (_hoarded(tods) <= fewest) continue;
      if (Runs.byBrute(const [], tods) != fewest) continue;

      print('// ${want.bales} bales, fewest $fewest, '
          'hoarding ends in ${_hoarded(tods)}');
      print('tods: $tods');
      print('');
      break;
    }
  }
}

/// So many distinct weights, in tods, shuffled.
List<int> _weighed(Random random, int bales) {
  final all = [for (var tod = 2; tod <= 40; tod++) tod]..shuffle(random);
  return all.take(bales).toList();
}

/// How the morning ends for the hoarder, who keeps snug tops free by setting
/// each bale on the heaviest top that can take it.
int _hoarded(List<int> tods) {
  final tops = <int>[];
  for (final tod in tods) {
    var loosest = -1;
    for (var pile = 0; pile < tops.length; pile++) {
      if (tops[pile] <= tod) continue;
      if (loosest == -1 || tops[pile] > tops[loosest]) loosest = pile;
    }
    if (loosest == -1) {
      tops.add(tod);
    } else {
      tops[loosest] = tod;
    }
  }
  return tops.length;
}
