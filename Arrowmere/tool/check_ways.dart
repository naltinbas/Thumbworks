import 'dart:io';

import 'package:arrowmere/ways/levels.dart';
import 'package:arrowmere/ways/play.dart';
import 'package:arrowmere/ways/rules.dart';

/// Points every street of every village every way it can be pointed,
/// counts the orientations that work twice over, and refuses the bake
/// on any disagreement.
///
/// Run with: dart run tool/check_ways.dart
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

  var tried = 0;
  final strongOf = <String, int>{};
  final bridgesOf = <String, List<int>>{};
  final bestOf = <String, int>{};

  for (final village in Rules.villages) {
    check(Rules.joined(village), '${village.name} is not joined');
    check(village.opening.length == village.streetCount,
        '${village.name} opens on the wrong count of arrows');

    // The two voices on how many orientations work.
    var strong = 0, best = 0;
    for (var mask = 0; mask < village.orientations; mask++) {
      final ways = Rules.waysOf(village, mask);
      final pairs = Rules.pairs(village, ways);
      tried++;
      if (pairs > best) best = pairs;
      if (Rules.strong(village, ways)) {
        strong++;
        check(pairs == village.placeCount * (village.placeCount - 1),
            '${village.name} counted $pairs pairs on a working orientation');
        // Every street on a working orientation lies on a round trip:
        // leave it and you can still come back.
        for (var s = 0; s < village.streetCount; s++) {
          final (from, to) = Rules.pointed(village, ways, s);
          check(Rules.reaches(village, ways, to).contains(from),
              '${village.name}: no way back over street $s');
        }
      }
    }
    check(strong == Rules.strongByTutte(village),
        '${village.name}: $strong by the sweep, '
        '${Rules.strongByTutte(village)} by the polynomial');
    check(strong == Rules.strongCount(village), '${village.name}: cached count');
    check(best == Rules.best(village), '${village.name}: best pairs');

    // The bridges, found by closing each street and by the walk.
    final byClosing = Rules.bridges(village);
    final byWalk = Rules.bridgesByWalk(village);
    check(byClosing.join(',') == byWalk.join(','),
        '${village.name}: bridges $byClosing against $byWalk');

    // Robbins: it can be done exactly when there is no bridge.
    check((strong > 0) == byClosing.isEmpty,
        '${village.name}: $strong working with ${byClosing.length} bridges');

    // The opening never lands the ask on its own.
    check(!Rules.strong(village, village.opening),
        '${village.name} opens on an answer');

    strongOf[village.name] = strong;
    bridgesOf[village.name] = byClosing;
    bestOf[village.name] = best;
  }

  // A round is always two ways round and no more, whatever its length.
  for (var n = 3; n <= 8; n++) {
    final ring = Village(
      name: 'a ring of $n',
      places: [for (var k = 0; k < n; k++) (k, 0)],
      streets: [for (var k = 0; k < n; k++) (k, (k + 1) % n)],
      opening: [for (var k = 0; k < n; k++) k == 0],
    );
    check(Rules.strongCount(ring) == 2, 'a ring of $n: ${Rules.strongCount(ring)}');
    check(Rules.strongByTutte(ring) == 2, 'a ring of $n by the polynomial');
  }

  // The asks, their counts and the turns they take.
  for (final level in Levels.all) {
    final village = level.village;
    check(strongOf[village.name] == level.ways,
        '${level.name}: ${strongOf[village.name]} against ${level.ways}');
    final aim = level.aim;
    if (level.winnable) {
      check(aim != null && level.meets(aim), '${level.name} aim');
    } else {
      check(aim == null, '${level.name} has an aim');
    }
    check(level.bestPairs == bestOf[village.name], '${level.name} best pairs');
  }

  // The pointer lands every ask it can, in the fewest turns the village
  // allows, and never wanders.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final street = play.next;
      check(street != null, '${level.name} lost its pointer');
      if (street == null) break;
      final was = play.away!;
      play = play.turn(street);
      check(play.away == was - 1, '${level.name} wandered at turn $steps');
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  // The hopeless ask, worn down either way it is played.
  final toll = Levels.all.firstWhere((l) => !l.winnable);
  var stuck = Play.of(toll);
  for (var k = 0; k < Play.gaveUpAt && !stuck.gaveUp; k++) {
    stuck = stuck.turn(k % stuck.village.streetCount);
  }
  check(stuck.gaveUp, 'the toll lane never admitted it');

  if (failed) {
    stderr.writeln('the village is not sound; no bake');
    exit(1);
  }

  final tollVillage = Rules.toll;
  final lane = bridgesOf[tollVillage.name]!.single;
  final (laneFrom, laneTo) = tollVillage.streets[lane];

  final ledger = StringBuffer()
    ..write('every way of pointing every street of all five villages tried, '
        '${commas(tried)} orientations in all, and the ones that leave every '
        'place reachable from every other counted twice, once by walking the '
        'arrows out of each place in turn and once by the village\'s Tutte '
        'polynomial at (0, 2), which never points a street: the two agree on '
        'all five, ')
    ..write(Rules.villages
        .map((v) => '${strongOf[v.name] == 0 ? 'none' : commas(strongOf[v.name]!)} '
            'of ${v.name}${v.name.endsWith('s') ? '\'' : '\'s'} '
            '${commas(v.orientations)}')
        .join(', '))
    ..write('; on every working orientation every street lies on a round '
        'trip, so what is left by one street can be come back to by others')
    ..write('; the toll lane is the only village with a bridge, the lane '
        '${Rules.tellPlace(laneFrom)} to ${Rules.tellPlace(laneTo)}, found '
        'both by closing each street in turn and by the depth-first walk that '
        'keeps the earliest place a branch can climb back to, and '
        '${bestOf[tollVillage.name]} of its 30 ordered pairs is the most any '
        'orientation gets, the nine across the lane going one way only')
    ..write('; a ring of any length from three to eight works two ways and no '
        'more, by both counts')
    ..write('; ')
    ..write(Levels.all
        .where((l) => l.winnable)
        .map((l) => '${l.name} opens ${l.fewest} turns from the nearest '
            'answer')
        .join(', '))
    ..write(', and the pointer takes each of them in that many, never more');
  stdout.writeln(ledger);
  stdout.writeln();
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the '
            '${commas(level.village.orientations)} orientations land it, the '
            'fewest ${level.fewest} turns from the opening'
        : 'none of the ${commas(level.village.orientations)}, and the lane '
            'says so on a finger';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
