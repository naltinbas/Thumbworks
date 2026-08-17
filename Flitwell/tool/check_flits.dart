import 'dart:io';

import 'package:flitwell/flit/levels.dart';
import 'package:flitwell/flit/play.dart';
import 'package:flitwell/flit/rules.dart';

/// Walks every street four tenants can have, all 331,776 of them, tries
/// all 24 lanes of each against every group, runs the trading rings as a
/// second voice that tries no lane, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_flits.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  final lanes = Rules.allocations();
  check(lanes.length == 24, 'lanes: ${lanes.length}');
  check(Rules.between(Rules.opening, Rules.opening) == 0, 'no swap at all');
  check(
      Rules.between(Rules.opening, [1, 0, 2, 3]) == 1, 'one swap');
  check(Rules.between(Rules.opening, [1, 2, 3, 0]) == 3, 'a ring of four');

  // Every order four tenants can hold.
  final orders = <List<int>>[];
  void spell(List<int> so, List<bool> taken) {
    if (so.length == Rules.cottages) {
      orders.add([...so]);
      return;
    }
    for (var c = 0; c < Rules.cottages; c++) {
      if (taken[c]) continue;
      taken[c] = true;
      spell([...so, c], taken);
      taken[c] = false;
    }
  }

  spell(const [], List.filled(Rules.cottages, false));
  check(orders.length == 24, 'orders one tenant can hold: ${orders.length}');

  var streets = 0, firmElsewhere = 0, topless = 0, beaten = 0;
  final settledSpread = <int, int>{};
  for (final a in orders) {
    for (final b in orders) {
      for (final c in orders) {
        for (final d in orders) {
          streets++;
          final street = [a, b, c, d];
          final byRings = Rules.rings(street);

          var firmCount = 0, settledCount = 0;
          for (final lane in lanes) {
            if (Rules.settled(street, lane)) settledCount++;
            if (!Rules.firm(street, lane)) continue;
            firmCount++;
            // The two voices: the rings' lane and the firm lane are one
            // and the same, every time.
            for (var t = 0; t < Rules.cottages; t++) {
              if (lane[t] != byRings[t]) firmElsewhere++;
            }
          }
          if (firmCount != 1) firmElsewhere++;
          settledSpread[settledCount] = (settledSpread[settledCount] ?? 0) + 1;

          // A firm lane is a lane nothing beats, so it is among the
          // settled ones and there is always at least one of those.
          if (!Rules.settled(street, byRings)) firmElsewhere++;
          // The tenants in the first ring take the cottage they want
          // most, so no lane ever beats the rings' lane.
          if (Rules.topped(street, byRings).isEmpty) topless++;
          for (final lane in lanes) {
            if (Rules.allBetterThan(street, lane, byRings)) beaten++;
          }
        }
      }
    }
  }

  check(streets == 331776, 'streets walked: $streets');
  check(firmElsewhere == 0,
      'the firm lane was not the rings\' lane $firmElsewhere times');
  check(topless == 0, 'the rings left nobody with a first choice $topless '
      'times');
  check(beaten == 0, 'the rings\' lane was beaten $beaten times');
  check(settledSpread.keys.reduce((x, y) => x > y ? x : y) == 7,
      'the most lanes a street leaves unbeaten: '
      '${settledSpread.keys.reduce((x, y) => x > y ? x : y)}');
  check(settledSpread[7] == 72, 'streets reaching seven: ${settledSpread[7]}');
  check(settledSpread[1] == 178716, 'streets with one: ${settledSpread[1]}');
  check(settledSpread.keys.length == 7,
      'counts a street can have: ${settledSpread.keys.length}');

  // The asks.
  for (final level in Levels.all) {
    final street = level.orders;
    check(street.length == Rules.cottages, '${level.name}: the street');
    var n = 0, cheapest = 9;
    for (final lane in lanes) {
      if (!level.meets(lane)) continue;
      n++;
      final away = Rules.between(Rules.opening, lane);
      if (away < cheapest) cheapest = away;
    }
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    check(!level.meets(Rules.opening),
        '${level.name} is landed before it is touched');
    if (level.winnable) {
      check(level.fewest == cheapest,
          '${level.name}: ${level.fewest} against $cheapest');
      // No lane of an ask stands further from a landing than three
      // swaps, which is as far as four cottages go, and the opening is
      // never further than that either.
      var furthest = 0;
      for (final lane in lanes) {
        var away = 9;
        for (final win in lanes) {
          if (!level.meets(win)) continue;
          final n = Rules.between(lane, win);
          if (n < away) away = n;
        }
        if (away > furthest) furthest = away;
      }
      check(furthest <= Rules.cottages - 1,
          '${level.name}: a lane stands $furthest swaps out');
      check(level.fewest! <= furthest,
          '${level.name}: the opening is past the furthest');
    } else {
      check(level.fewest == null && n == 0, '${level.name} was landed');
    }
    check(Rules.firm(street, level.firmLane), '${level.name}: the firm lane');
  }

  // The three asks on the shared street say three different things about
  // the one lane.
  final shared = Rules.read(Levels.shared);
  final firmLane = Rules.rings(shared);
  check(Levels.at(1).street == Levels.shared, 'the second ask moved street');
  check(Levels.at(3).street == Levels.shared, 'the fourth ask moved street');
  check(Levels.at(4).street == Levels.shared, 'the fifth ask moved street');
  check(Rules.write(firmLane) == 'BDCA', 'the firm lane: ${Rules.write(firmLane)}');
  check(Rules.settled(shared, firmLane), 'the firm lane is beaten');
  final tops = Rules.topped(shared, firmLane);
  check(tops.length == 3 && tops[0] == 0 && tops[1] == 1 && tops[2] == 3,
      'who gets their first choice: ${tops.map(Rules.letter).join()}');
  check(Rules.rank(shared, 2, firmLane[2]) == Rules.cottages - 1,
      'tenant C is not in the cottage it wants least');
  var alsoSettled = 0;
  for (final lane in lanes) {
    if (Rules.settled(shared, lane) && !Rules.firm(shared, lane)) alsoSettled++;
  }
  check(alsoSettled == 6, 'settled but not firm on the shared street: '
      '$alsoSettled');

  // The pointer lands every ask it can, in the fewest swaps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 8) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.tap(aim.$1).tap(aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} was never landed');
    check(play.swaps == level.fewest,
        '${level.name} in ${play.swaps} against ${level.fewest}');
  }

  // The hopeless ask, worn down by six lanes.
  var stuck = Play.of(Levels.all.last);
  for (final pair in [(0, 1), (2, 3), (0, 2), (1, 3), (0, 3), (1, 2)]) {
    final was = stuck;
    stuck = stuck.tap(pair.$1).tap(pair.$2);
    check(!identical(stuck, was), 'a swap that did nothing at ${was.where}');
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');
  check(!Play.of(Levels.all.last).gaveUp, 'it admitted it at once');

  if (failed) {
    stderr.writeln('the lane is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every street four tenants can have walked, all '
        '${commas(streets)} of them, and all ${lanes.length} lanes of each '
        'tried against every group of tenants, which is '
        '${commas(streets * lanes.length)} lanes tried')
    ..write('; on every street exactly one lane is firm, meaning no group '
        'can better one of its own without setting another back, and on '
        'every street that lane is the one the trading rings give, which '
        'are run as a second voice and try no lane at all')
    ..write('; a lane no group can better all at once is a weaker thing and '
        'a street can have several: ${commas(settledSpread[1]!)} streets '
        'have one, then ${commas(settledSpread[2]!)}, '
        '${commas(settledSpread[3]!)}, ${commas(settledSpread[4]!)}, '
        '${commas(settledSpread[5]!)}, ${commas(settledSpread[6]!)} and '
        '${commas(settledSpread[7]!)} have seven, which is the most any '
        'street of four reaches')
    ..write('; on all ${commas(streets)} the tenants in the first ring take '
        'the cottage they want most out of all four, and on all '
        '${commas(streets)} no lane whatever leaves every tenant better off '
        'than the rings\' lane does');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the 24 lanes do it, the nearest ${level.fewest} '
            'swaps away'
        : 'none of the 24, and the trading rings said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
