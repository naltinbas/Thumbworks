import 'dart:io';

import 'package:mintcombe/coin/levels.dart';
import 'package:mintcombe/coin/play.dart';
import 'package:mintcombe/coin/rules.dart';

/// Sums every picking of the purse, finds the tidy ones, runs the greedy
/// purse on every price, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_purses.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  // The coins.
  final coins = Rules.coins;
  check(coins.length == 10 && coins.first == 1 && coins[1] == 2, 'the coins $coins');
  for (var i = 2; i < coins.length; i++) {
    check(coins[i] == coins[i - 1] + coins[i - 2], 'coin $i is not the two before it added');
  }
  check(Rules.purse == 231 && Rules.unminted == 144 && Rules.tidyTop == 143, 'purse ${Rules.purse}, unminted ${Rules.unminted}, tidy top ${Rules.tidyTop}');

  // The sweep.
  final pickings = Rules.pickings;
  check(pickings.length == 1024, 'pickings ${pickings.length}');
  final all = <int, int>{}, tidy = <int, int>{}, fewest = <int, int>{};
  final tidyWay = <int, List<int>>{};
  var tidyCount = 0, withoutTop = 0, withoutTopMax = 0;
  for (final p in pickings) {
    final s = Rules.sumOf(p);
    all[s] = (all[s] ?? 0) + 1;
    if (Rules.tidy(p)) {
      tidyCount++;
      tidy[s] = (tidy[s] ?? 0) + 1;
      tidyWay[s] = p;
      if (!p.contains(coins.last)) {
        withoutTop++;
        if (s > withoutTopMax) withoutTopMax = s;
      }
    }
    if (!fewest.containsKey(s) || p.length < fewest[s]!) fewest[s] = p.length;
  }
  check(all.length == 232 && [for (var n = 0; n <= 231; n++) all[n] ?? 0].every((k) => k > 0), 'prices paid: ${all.length}');
  check(tidyCount == 144 && tidy.length == 144, 'tidy pickings $tidyCount for ${tidy.length} prices');
  for (var n = 0; n <= 143; n++) {
    check(tidy[n] == 1, 'price $n paid tidily ${tidy[n] ?? 0} ways');
  }
  for (var n = 144; n <= 231; n++) {
    check(!tidy.containsKey(n), 'price $n paid tidily');
  }
  check(withoutTop == 89 && withoutTopMax == 88, 'tidy without the 89: $withoutTop pickings, $withoutTopMax at most');

  // The greedy purse, the second voice.
  for (var n = 0; n <= 143; n++) {
    final g = Rules.greedy(n);
    check(g != null && Rules.tidy(g) && Rules.sumOf(g) == n, 'greedy $n: $g');
    check(g!.join(',') == tidyWay[n]!.join(','), 'greedy $n $g is not the sweep\'s ${tidyWay[n]}');
    check(g.length == fewest[n], 'greedy $n uses ${g.length} coins, the fewest is ${fewest[n]}');
  }
  for (var n = 144; n <= 231; n++) {
    final g = Rules.greedy(n);
    check(g != null && Rules.sumOf(g) == n && !Rules.tidy(g), 'greedy $n: $g');
  }
  check(Rules.greedy(232) == null, 'greedy pays 232');

  // The alternate runs.
  final oneShort = <int>[];
  for (var i = 0; i < coins.length; i++) {
    final run = Rules.alternate(coins[i]);
    final above = i + 1 < coins.length ? coins[i + 1] : Rules.unminted;
    check(Rules.tidy(run) && Rules.sumOf(run) == above - 1, 'the run from ${coins[i]}, $run, adds to ${Rules.sumOf(run)}');
    oneShort.add(Rules.sumOf(run));
  }
  check(oneShort.join(',') == '1,2,4,7,12,20,33,54,88,143', 'one short: $oneShort');
  final once = [for (var n = 0; n < 144; n++) if (all[n] == 1) n];
  check(once.join(',') == '0,1,2,4,7,12,20,33,54,88,143', 'paid one way below 144: $once');
  var most = 0;
  for (final k in all.values) {
    if (k > most) most = k;
  }
  final mostAt = [for (var n = 0; n <= 231; n++) if (all[n] == most) n];
  check(most == 10 && mostAt.join(',') == '105,113,118,126', 'most ways $most at $mostAt');

  // The named prices.
  check(all[90] == 5 && tidyWay[90]!.join(',') == '89,1', '90: ${all[90]} ways, tidy ${tidyWay[90]}');
  check(all[143] == 1 && tidyWay[143]!.join(',') == '89,34,13,5,2', '143: ${all[143]} ways, tidy ${tidyWay[143]}');
  check(all[100] == 9 && tidyWay[100]!.join(',') == '89,8,3' && fewest[100] == 3, '100: ${all[100]} ways, tidy ${tidyWay[100]}, fewest ${fewest[100]}');
  check(all[144] == 5 && !tidy.containsKey(144) && fewest[144] == 2, '144: ${all[144]} ways, fewest ${fewest[144]}');

  // The asks.
  for (final level in Levels.all) {
    final ways = pickings.where(level.meets).length;
    final paid = pickings.where((p) => Rules.sumOf(p) == level.price).length;
    check(ways == level.ways, '${level.name}: ${level.ways} said, $ways swept');
    check(paid == level.all, '${level.name}: ${level.all} pickings said to pay, $paid swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 12) {
        final (coin, lift) = play.next!;
        play = lift ? play.lift(coin) : play.pick(coin);
        steps++;
      }
      check(play.isDone && play.moves == aim.length, '${level.name}: the pointer never lands, or takes ${play.moves} taps');
    }
  }
  check(Levels.at(0).aim!.join(',') == '89,1', 'the ninety\'s aim');
  check(Levels.at(1).aim!.join(',') == '89,34,13,5,2', 'the tidy top\'s aim');
  check(Levels.at(2).aim!.join(',') == '55,34,8,3', 'the untidy hundred\'s aim');
  check(Levels.at(3).aim!.join(',') == '89,55', 'the unminted\'s aim');
  check(Levels.at(4).barred == 89 && Play.of(Levels.at(4)).pick(89).picked.isEmpty, 'the held-back coin is laid');
  final stuck = Play.of(Levels.at(4)).pick(55).pick(21).pick(8).pick(3).pick(1);
  check(stuck.sum == 88 && stuck.stuck && stuck.gaveUp, 'the held-back coin does not admit it at 88');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every picking of the purse\'s ten coins taken, ${commas(pickings.length)}, and every price from nought to 231 paid by one at least; the tidy pickings, no two coins neighbours on the rack, are 144 and pay the prices from nought to 143 once each and none higher, and the greedy purse, the dearest coin not over what is left again and again, pays every one of those 144 prices tidily, lands the sweep\'s tidy picking every time and with the fewest coins any picking uses, and pays every price from 144 to 231 as well, untidily every time; every other coin from a coin down adds to one short of the coin above it, 1, 2, 4, 7, 12, 20, 33, 54, 88 and 143, and those and nought are the prices below 144 paid one way only, while 105, 113, 118 and 126 are paid ten ways, the most; 90 is 89 and 1 tidily and five ways in all, 100 is 89, 8 and 3 tidily and nine ways, 143 is 89, 34, 13, 5 and 2 and no other way, and 144, the coin the mint never struck, is paid five ways and never tidily; without the 89 the tidy purse pays 88 at most, 89 pickings for the prices to 88\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(pickings.length)} pickings land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(pickings.length)}, and the run of alternate coins said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
