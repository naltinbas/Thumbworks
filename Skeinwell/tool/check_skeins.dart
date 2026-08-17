import 'dart:io';

import 'package:skeinwell/skein/frac.dart';
import 'package:skeinwell/skein/levels.dart';
import 'package:skeinwell/skein/play.dart';
import 'package:skeinwell/skein/rules.dart';

/// Strings every village the board can hold, works out every lane's
/// share two ways, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_skeins.dart
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

  final four = Frac.of(Rules.greens - 1);
  final half = Frac.of(1, 2);

  var villages = 0, cutOff = 0;
  final ways = <String, int>{for (final level in Levels.all) level.name: 0};
  final cheapest = <String, int>{};
  final byStringings = <int, int>{};
  final shareValues = <String, int>{};
  var mostHalves = 0;
  var mostHalvesAt = 0;
  final evenByLanes = <int, int>{};
  final evenShare = <int, String>{};
  var butterflies = 0, twoAndThree = 0;
  for (var mask = 0; mask < 1 << Rules.howManyLanes; mask++) {
    if (!Rules.joinedUp(mask)) {
      cutOff++;
      continue;
    }
    villages++;
    final all = Rules.stringings(mask);
    check(all.isNotEmpty, 'the village ${Rules.tellVillage(mask)} strings no way');
    for (final stringing in all) {
      check(Rules.howMany(stringing) == Rules.inAStringing,
          'a stringing of ${Rules.howMany(stringing)} lanes');
      check(Rules.joinedUp(stringing), 'a stringing that leaves a green out');
    }
    byStringings[all.length] = (byStringings[all.length] ?? 0) + 1;
    final shares = Rules.shares(mask);
    check(shares.length == Rules.howMany(mask),
        'the village ${Rules.tellVillage(mask)} lost a share');
    var total = Frac.zero;
    var halves = 0;
    for (final lane in Rules.laidLanes(mask)) {
      final share = shares[lane]!;
      // The two voices: counting the stringings, and the traffic put
      // through the lane.
      check(share == Rules.resistance(mask, lane),
          'the lane ${Rules.tellLane(lane)} of ${Rules.tellVillage(mask)}: '
          '$share counted, ${Rules.resistance(mask, lane)} carried');
      check(share > Frac.zero && share <= Frac.one,
          'the lane ${Rules.tellLane(lane)} takes $share');
      // A lane takes all of them exactly when lifting it cuts a green
      // off.
      check((share == Frac.one) == !Rules.joinedUp(Rules.toggle(mask, lane)),
          'the lane ${Rules.tellLane(lane)} takes $share and lifting it');
      total = total + share;
      if (share == half) halves++;
      shareValues['$share'] = (shareValues['$share'] ?? 0) + 1;
    }
    check(total == four,
        'the village ${Rules.tellVillage(mask)} adds to $total');
    if (halves > mostHalves) {
      mostHalves = halves;
      mostHalvesAt = mask;
    }
    final seen = shares.values.toSet();
    if (seen.length == 1 && seen.first < Frac.one) {
      final lanes = Rules.howMany(mask);
      evenByLanes[lanes] = (evenByLanes[lanes] ?? 0) + 1;
      evenShare[lanes] = '${seen.first}';
      if (lanes == 6) {
        final at = List.filled(Rules.greens + 1, 0);
        for (final lane in Rules.laidLanes(mask)) {
          final (a, b) = Rules.lanes[lane];
          at[a]++;
          at[b]++;
        }
        final busiest = at.reduce((a, b) => a > b ? a : b);
        if (busiest == 4) {
          butterflies++;
        } else {
          twoAndThree++;
        }
      }
    }
    for (final level in Levels.all) {
      if (!level.meets(mask)) continue;
      ways[level.name] = ways[level.name]! + 1;
      final taps = Rules.taps(Rules.opening, mask);
      final held = cheapest[level.name];
      if (held == null || taps < held) cheapest[level.name] = taps;
    }
  }
  check(villages == 728, 'villages swept: $villages');
  check(villages + cutOff == 1024, 'masks swept: ${villages + cutOff}');
  check(byStringings[125] == 1 && byStringings[1] == 125,
      'the stringing counts: $byStringings');
  check(mostHalves == 6, 'the most lanes at a half: $mostHalves');
  check(evenByLanes[5] == 12 && evenByLanes[6] == 25 && evenByLanes[10] == 1,
      'the even villages: $evenByLanes');
  check(
      evenShare[5] == '4/5' && evenShare[6] == '2/3' && evenShare[10] == '2/5',
      'the even shares: $evenShare');
  check(butterflies == 15 && twoAndThree == 10,
      'the six-lane even villages: $butterflies and $twoAndThree');
  check(shareValues['1'] == 1000 && shareValues['1/2'] == 300,
      'the share values: $shareValues');

  // The village the board opens on: the smallest that joins every
  // green, and none of the asks.
  check(Rules.howMany(Rules.opening) == Rules.inAStringing,
      'the opening has ${Rules.howMany(Rules.opening)} lanes');
  check(Rules.stringings(Rules.opening).length == 1,
      'the opening strings more than one way');
  for (final level in Levels.all) {
    check(!level.meets(Rules.opening), '${level.name} is landed at the opening');
  }

  // The asks.
  for (final level in Levels.all) {
    check(ways[level.name] == level.ways,
        '${level.name}: ${ways[level.name]} against ${level.ways}');
    if (level.winnable) {
      check(level.meets(level.aimMask!), '${level.name}: the aim misses');
      check(Rules.taps(Rules.opening, level.aimMask!) == cheapest[level.name],
          '${level.name}: the aim takes '
          '${Rules.taps(Rules.opening, level.aimMask!)}, cheapest '
          '${cheapest[level.name]}');
    } else {
      check(level.aim == null && ways[level.name] == 0,
          '${level.name} was landed');
    }
  }

  // The pointer lands every ask it can, in the fewest taps, and never
  // asks for a lift that would cut a green off.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      check(aim.$2 != play.has(aim.$1), '${level.name}: the pointer is confused');
      check(aim.$2 || !play.wouldCut(aim.$1),
          '${level.name}: the pointer would cut a green off');
      play = play.tap(aim.$1);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  if (failed) {
    stderr.writeln('the village is not sound; no bake');
    exit(1);
  }

  final trees = byStringings.keys.toList()..sort();
  final ledger = StringBuffer()
    ..write('every village the board can hold taken, all '
        '${commas(1 << Rules.howManyLanes)} ways the ten lanes can lie, of '
        'which ${commas(villages)} join every green up and $cutOff leave a '
        'green cut off; each of the ${commas(villages)} strung in full, its '
        'stringings listed one by one, and every lane\'s share found twice, '
        'once by counting the stringings that run along it and once by '
        'putting a unit of traffic in at one end of the lane and out at the '
        'other and reading the difference across it in exact fractions: the '
        'two agree on every lane of every village')
    ..write('; and the shares add to $four on all ${commas(villages)} of '
        'them, never once to anything else')
    ..write('; a lane takes all the stringings exactly when lifting it cuts '
        'a green off, which happens ${commas(shareValues['1']!)} times over '
        'the sweep, and a lane takes exactly half '
        '${commas(shareValues['1/2']!)} times, no village getting more than '
        '$mostHalves of its lanes to a half at once, which one does: '
        '${Rules.tellVillage(mostHalvesAt)}')
    ..write('; the villages string up in ')
    ..write([for (final t in trees) '${commas(byStringings[t]!)} at $t']
        .join(', '))
    ..write(' ways, the ${byStringings[1]} that string a single way being '
        'the smallest villages there are and the one that strings '
        '${trees.last} ways being the full skein')
    ..write('; and ${evenByLanes.values.reduce((a, b) => a + b)} villages '
        'give every lane the same share without giving any lane all of them: '
        '${evenByLanes[5]} rings of five at ${evenShare[5]} a lane, '
        '${evenByLanes[6]} of six lanes at ${evenShare[6]}, being '
        '$butterflies pairs of triangles meeting at a green and '
        '$twoAndThree joining two greens to the other three, and the full '
        'skein at ${evenShare[10]}');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(villages)} villages '
            '${level.ways == 1 ? 'lands' : 'land'} it, the cheapest in '
            '${level.fewest} ${level.fewest == 1 ? 'tap' : 'taps'}'
        : 'none of the ${commas(villages)}, and the four lanes of a '
            'stringing say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
