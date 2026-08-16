import 'dart:io';

import 'package:ropeford/ford/level.dart';
import 'package:ropeford/ford/levels.dart';
import 'package:ropeford/ford/play.dart';
import 'package:ropeford/ford/rules.dart';

/// Sieves the numbers twice, asks every one of them for a dry stone
/// inside the rope's reach, walks the ford for the fewest hops both by
/// hand and by the greedy chain, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_ford.dart
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

  // The two voices on what is dry: the sieve, and trial division.
  const high = 200000, byHand = 20000;
  // Sieved a little past the sweep's end so that the last few numbers
  // still have a dry stone above them to point at.
  final dry = Rules.sieve(high + 1000);
  var counted = 0;
  for (var k = 0; k <= high; k++) {
    if (dry[k]) counted++;
    if (k <= byHand) check(dry[k] == Rules.dryByTrial(k), 'stone $k');
  }
  check(counted == 17984, 'dry stones to $high: $counted');

  // The first dry stone above n, by a pointer walking the sieve.
  final above = List.filled(high + 1001, 0);
  var pointer = high + 1001;
  for (var n = high + 1000; n >= 0; n--) {
    above[n] = pointer;
    if (dry[n]) pointer = n;
  }

  // The promise, twice over: the first dry stone above n is no further
  // than the rope's end.
  var promise = 0, strictFails = <int>[];
  var tightest = 0;
  for (var n = 1; n <= high; n++) {
    final p = above[n];
    check(p <= high + 1000, 'no dry stone above $n inside the sieve');
    if (p <= 2 * n) promise++;
    if (!(n < p && p < 2 * n)) strictFails.add(n);
    // Stone 1 is left out: the only stone its rope reaches is the rope's
    // own end, which is the strict form's one failure.
    if (n >= 2 && (tightest == 0 || p * tightest > above[tightest] * n)) {
      tightest = n;
    }
    if (n <= byHand) {
      var walked = n + 1;
      while (!Rules.dryByTrial(walked)) {
        walked++;
      }
      check(walked == p, 'the first dry stone above $n: $walked and $p');
    }
  }
  check(promise == high, 'the promise held on $promise of $high');
  check(strictFails.length == 1 && strictFails.first == 1,
      'the strict form failed on $strictFails');
  check(tightest == 3 && above[3] == 5, 'the closest call: $tightest');

  // The greedy chain: always the farthest dry stone the rope covers.
  final chain = <int>[2];
  while (true) {
    var far = 2 * chain.last;
    if (far > high) break;
    while (!dry[far]) {
      far--;
    }
    check(far > chain.last, 'the chain stalled at ${chain.last}');
    chain.add(far);
  }
  check(chain.take(9).join(',') == '2,3,5,7,13,23,43,83,163',
      'the chain opens $chain');

  // A walk over the hop graph of a longer ford, stone by stone, with no
  // chain in sight: the second voice on the fewest hops.
  const wide = 20000;
  final stones = [for (var k = 2; k <= wide; k++) if (dry[k]) k];
  final far = List.filled(stones.length, -1);
  far[0] = 0;
  final queue = <int>[0];
  for (var head = 0; head < queue.length; head++) {
    final here = queue[head];
    final reach = 2 * stones[here];
    for (var i = here + 1; i < stones.length && stones[i] <= reach; i++) {
      if (far[i] < 0) {
        far[i] = far[here] + 1;
        queue.add(i);
      }
    }
  }
  check(queue.length == stones.length, 'the walk left stones unreached');

  // The layers of that walk are exactly the chain's steps: everything
  // dry up to the chain's dth stone, and nothing beyond it.
  for (var i = 0; i < stones.length; i++) {
    final d = far[i];
    check(stones[i] <= chain[d] && (d == 0 || stones[i] > chain[d - 1]),
        'stone ${stones[i]} in $d hops against the chain');
  }

  int passing(int mark) {
    for (var i = 0; i < stones.length; i++) {
      if (stones[i] > mark) return far[i];
    }
    return -1;
  }

  int passingByChain(int mark) {
    for (var d = 0; d < chain.length; d++) {
      if (chain[d] > mark) return d;
    }
    return -1;
  }

  final marks = [100, 1000, 10000];
  for (final mark in marks) {
    check(passing(mark) == passingByChain(mark), 'the hops to pass $mark');
  }
  check(marks.map(passing).join(',') == '8,11,15', 'the hops to the marks');

  // The ford itself, 120 stones of it.
  check(Rules.dryStones.length == 30, 'dry stones on the ford');
  check(Rules.hops.length == Rules.dryStones.length,
      'unreachable stones on the ford');
  final deepest =
      Rules.hops.values.fold(0, (most, hops) => hops > most ? hops : most);
  check(deepest == 8, 'the farthest corner of the ford: $deepest');
  for (final stone in Rules.dryStones) {
    check(Rules.dryByTrial(stone), 'the ford says $stone is dry');
    final hops = Rules.hops[stone]!;
    check(stone <= Rules.chainFrom(2)[hops], 'the ford against the chain');
  }
  for (var k = 1; k <= Rules.stones; k++) {
    check(Rules.dry(k) == Rules.dryByTrial(k), 'the ford on stone $k');
    check(Rules.mossy(k) != Rules.dry(k), 'moss and dry on stone $k');
  }
  check(Rules.chain.join(',') == '2,3,5,7,13,23,43,83,113',
      'the ford\'s greedy crossing: ${Rules.chain}');

  // The long shallows, and the first run of seven mossy stones.
  var run = 0, firstSeven = 0;
  for (var k = 2; k <= high; k++) {
    run = dry[k] ? 0 : run + 1;
    if (run == 7 && firstSeven == 0) firstSeven = k - 6;
  }
  check(firstSeven == Rules.shallowsFrom, 'the first run of seven: $firstSeven');
  for (var k = Rules.shallowsFrom; k <= Rules.shallowsTo; k++) {
    check(Rules.mossy(k), 'shallow stone $k');
  }
  check(Rules.tellMoss(91) == 'stone 91 is 7 times 13', Rules.tellMoss(91));
  check(Rules.tellMoss(93) == 'stone 93 is 3 times 31', Rules.tellMoss(93));
  check(Rules.tellMoss(95) == 'stone 95 is 5 times 19', Rules.tellMoss(95));

  // The asks, counted over the ford.
  final ways = <Level, int>{};
  for (final level in Levels.all) {
    var n = 0;
    for (var k = 1; k <= Rules.stones; k++) {
      if (level.meets(k)) n++;
    }
    ways[level] = n;
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    final aim = level.aim;
    if (aim != null) check(level.meets(aim), '${level.name} aim $aim');
    if (!level.winnable) check(aim == null, '${level.name} has an aim');
  }

  // The pointer lands every ask it can, in the fewest hops the walk
  // allows.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final stone = play.next;
      check(stone != null, '${level.name} lost its pointer at ${play.at}');
      if (stone == null) break;
      play = play.hop(stone);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  final lonely = [for (final p in Rules.dryStones) if (Rules.lonely(p)) p];
  final twins = [for (final p in Rules.dryStones) if (Rules.upperTwin(p)) p];
  final past = [for (final p in Rules.dryStones) if (p > 100) p];
  final beyond = [
    for (final p in Rules.dryStones)
      if (Rules.ropePastFord(p)) p,
  ];
  final layers = <int, List<int>>{};
  for (final stone in Rules.dryStones) {
    layers.putIfAbsent(Rules.hops[stone]!, () => []).add(stone);
  }

  if (failed) {
    stderr.writeln('the ford is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every number from 1 to ${commas(high)} asked for a dry stone '
        'inside the rope\'s reach and given one, the first above it found '
        'twice, by a pointer walking the sieve and, up to ${commas(byHand)}, '
        'by trial division counting up from n + 1, the two agreeing on every '
        'one: the promise never fails, and the closest it comes is stone 3, '
        'where the next dry stone is 5 and the rope reaches 6; the strict '
        'form n < p < 2n holds from 2 up and fails at 1 alone, where the '
        'only stone in reach is the rope\'s own end')
    ..write('; the greedy crossing, always the farthest stone the rope '
        'covers, runs ${chain.join(', ')}, and a walk over the hop graph of '
        'the ${commas(stones.length)} dry stones below ${commas(wide)}, '
        'stone by stone and chain unseen, gives the same counts: '
        '${passing(100)} hops to pass a hundred, ${passing(1000)} a thousand, '
        '${passing(10000)} ten thousand, and the stones reachable in d hops '
        'are exactly the dry ones up to the chain\'s dth')
    ..write('; on the ford itself, ${Rules.stones} stones with '
        '${Rules.dryStones.length} dry, sieved and divided out and agreeing '
        'on every one, every dry stone can be reached and none takes more '
        'than $deepest hops: ${layers.entries.map((l) => '${l.value.length} at ${l.key}').join(', ')}')
    ..write('; ${past.length} dry stones lie past the hundredth, '
        '${past.join(', ')}, the rope runs past the ford\'s last stone from '
        '${beyond.first} on, ${beyond.length} of them, ${twins.length} stones '
        'have another dry stone two behind, and ${lonely.length} have nothing '
        'but moss for four either side, ${lonely.join(' and ')}')
    ..write('; the seven stones from ${Rules.shallowsFrom} to '
        '${Rules.shallowsTo} are all mossy, the first such run anywhere, '
        '${Rules.tellMoss(91)} and ${Rules.tellMoss(93)}, so no crossing ends '
        'in the shallows');
  stdout.writeln(ledger);
  stdout.writeln();
  final wide2 = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${ways[level]} of the ${Rules.stones} stones land it, the fewest '
            'crossing ${level.fewest} hops'
        : 'none of the ${Rules.stones}, and the seven mossy stones say so on '
            'a finger';
    stdout.writeln(' ${i + 1} ${level.name.padRight(wide2)} ${level.task}: $tail');
  }
}
