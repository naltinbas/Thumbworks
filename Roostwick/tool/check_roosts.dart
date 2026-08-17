import 'dart:io';

import 'package:roostwick/roost/levels.dart';
import 'package:roostwick/roost/play.dart';
import 'package:roostwick/roost/rules.dart';

/// Walks every wood of six hollows and six or fewer birds, four voices
/// apiece, and refuses the bake on any disagreement.
///
/// The count of settling seatings depends only on which tethers are
/// used and how often, not on which bird is on which tether, so the
/// 12,204,240 woods collapse to 54,263 boards, each standing for as
/// many woods as there are ways of dealing its birds out. That claim is
/// not assumed: every ordered wood of four birds or fewer is walked as
/// well, all 54,240 of them, and each is held against its board.
///
/// Run with: dart run tool/check_roosts.dart
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

  final tethers = Rules.tethers;
  check(tethers.length == 15, 'tethers in the wood: ${tethers.length}');

  /// The ways of dealing [flock] birds out over a board that uses each
  /// tether the number of times counted in [times].
  int dealings(int flock, List<int> times) {
    var ways = 1, left = flock;
    for (final n in times) {
      // Choose which of the birds still to be dealt go on this tether.
      for (var k = 0; k < n; k++) {
        ways = ways * (left - k) ~/ (k + 1);
      }
      left -= n;
    }
    return ways;
  }

  var boards = 0, woods = 0, settling = 0, mismatch = 0;
  final layers = <int, (int, int)>{};
  final spread = <int, Map<int, int>>{};
  // The furthest any seating of any board stands from a settled one,
  // which is what caps how long an ask can be made to run.
  var deepest = 0, atDepth = 0;
  var hubIsDeepest = false;

  for (var flock = 1; flock <= 6; flock++) {
    var here = 0, live = 0;
    final counts = <int, int>{};
    // Every board of [flock] birds, tethers taken in order so that each
    // way of choosing them comes up once however often one is repeated.
    void walk(int from, int left, List<(int, int)> birds, List<int> times) {
      if (left == 0) {
        boards++;
        final byWalking = Rules.tally(birds);
        final byPatches = Rules.census(birds);
        final byHall = Rules.overfull(birds) == null;
        final byShoving = Rules.found(birds);
        if (byWalking != byPatches) mismatch++;
        check(byWalking == byPatches,
            'the two counts differ on ${Rules.write(birds)}: '
            '$byWalking against $byPatches');
        check(byHall == (byWalking > 0),
            'Hall differs on ${Rules.write(birds)}');
        check((byShoving != null) == (byWalking > 0),
            'the shoving differs on ${Rules.write(birds)}');
        if (byShoving != null) {
          check(Rules.settled(birds, byShoving),
              'the shoving left a crowd on ${Rules.write(birds)}');
        }
        if (byWalking > 0) {
          // How far this board's furthest seating stands from a settled
          // one. A board that beats the running best resets the tally of
          // boards that reach it, and no earlier board can have reached
          // the best, or it would have set it.
          final settled = Rules.landings(birds);
          var far = 0;
          for (var pick = 0; pick < 1 << flock; pick++) {
            var away = flock;
            for (final landing in settled) {
              final n = Rules.between(pick, landing);
              if (n < away) away = n;
            }
            if (away > far) far = away;
          }
          if (far > deepest) {
            deepest = far;
            atDepth = 0;
          }
          if (far == deepest) {
            atDepth++;
            if (Rules.write(birds) == 'AB AB AC AD AE AF') hubIsDeepest = true;
          }
        }
        final many = dealings(flock, times);
        here += many;
        if (byWalking > 0) live += many;
        counts[byWalking] = (counts[byWalking] ?? 0) + many;
        return;
      }
      if (from >= tethers.length) return;
      for (var n = 0; n <= left; n++) {
        walk(
          from + 1,
          left - n,
          [...birds, ...List.filled(n, tethers[from])],
          n > 0 ? [...times, n] : times,
        );
      }
    }

    walk(0, flock, <(int, int)>[], <int>[]);
    layers[flock] = (here, live);
    spread[flock] = counts;
    woods += here;
    settling += live;
  }

  check(boards == 54263, 'boards walked: $boards');
  check(woods == 12204240, 'woods stood for: $woods');
  check(mismatch == 0, 'the two counts differed $mismatch times');
  check(layers[6]!.$1 == 11390625, 'woods of six birds: ${layers[6]!.$1}');
  check(layers[6]!.$2 == 5295150, 'of those, settling: ${layers[6]!.$2}');
  check(spread[6]![0] == 6095475, 'woods of six birds that never settle');
  check(spread[6]![2] == 4968000, 'woods of six birds settling two ways');
  check(spread[6]![4] == 325800, 'woods of six birds settling four ways');
  check(spread[6]![8] == 1350, 'woods of six birds settling eight ways');
  check(spread[6]!.length == 4,
      'six birds on six hollows settle in ${spread[6]!.length} counts');
  check(deepest == 5, 'the furthest a seating stands from settled: $deepest');
  check(hubIsDeepest, 'The Hub does not reach that depth');
  check(Levels.at(3).board == 'ABABACADAEAF', 'The Hub is not that board');

  // The collapse to boards is checked rather than assumed: every
  // ordered wood of four birds or fewer, held against its board.
  var ordered = 0;
  for (var flock = 1; flock <= 4; flock++) {
    void walk(List<(int, int)> birds) {
      if (birds.length == flock) {
        ordered++;
        final sorted = [...birds]
          ..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
        check(Rules.tally(birds) == Rules.tally(sorted),
            'dealing the birds out differently changed the count on '
            '${Rules.write(birds)}');
        check(Rules.tally(birds) == Rules.census(birds),
            'the two counts differ on ${Rules.write(birds)}');
        return;
      }
      for (final tether in tethers) {
        walk([...birds, tether]);
      }
    }

    walk(const []);
  }
  check(ordered == 54240, 'ordered woods walked: $ordered');

  // The asks.
  for (final level in Levels.all) {
    final birds = level.birds;
    check(Rules.tally(birds) == level.ways,
        '${level.name}: ${Rules.tally(birds)} against ${level.ways}');
    check(Rules.census(birds) == level.ways,
        '${level.name} by patches: ${Rules.census(birds)}');
    check(birds.length == level.flock, '${level.name}: the flock');
    check(!level.meets(Rules.opening),
        '${level.name} is settled before it is touched');
    final near = Rules.nearest(birds, Rules.opening);
    if (level.winnable) {
      check(near != null && near.$2 == level.fewest,
          '${level.name}: ${near?.$2} taps against ${level.fewest}');
      // The opening is as far from settled as this board ever gets, so
      // the ask is the whole walk rather than a lucky short one.
      var furthest = 0;
      for (var pick = 0; pick < level.seatings; pick++) {
        final away = Rules.nearest(birds, pick)!.$2;
        if (away > furthest) furthest = away;
      }
      check(furthest == level.fewest,
          '${level.name}: the opening is $furthest from the furthest');
    } else {
      check(near == null && level.fewest == null, '${level.name} was settled');
      // Nowhere on the board is any better than anywhere else.
      for (var pick = 0; pick < level.seatings; pick++) {
        check(!Rules.settled(birds, pick),
            '${level.name} settles at seating $pick');
      }
    }
  }

  // The pointer settles every ask it can, in the fewest taps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 12) {
      final bird = play.next;
      check(bird != null, '${level.name} lost its pointer');
      if (bird == null) break;
      play = play.tap(bird);
      steps++;
    }
    check(play.isDone, '${level.name} was never settled');
    check(play.taps == level.fewest,
        '${level.name} in ${play.taps} against ${level.fewest}');
  }

  // The hopeless ask, and the reason it hands back.
  final dead = Levels.all.last;
  final stuck = Play.of(dead);
  final jam = stuck.overfull, penned = stuck.penned;
  check(jam.length == 2 && jam[0] == 0 && jam[1] == 1,
      'the overfull patch: ${jam.map(Rules.letter).join()}');
  check(penned.length == 3, 'birds penned in it: ${penned.length}');
  var crowdedEverywhere = 0;
  for (var pick = 0; pick < dead.seatings; pick++) {
    final at = Rules.seats(dead.birds, pick);
    if (at.where((h) => h == 0).length > 1 ||
        at.where((h) => h == 1).length > 1) {
      crowdedEverywhere++;
    }
  }
  check(crowdedEverywhere == dead.seatings,
      'seatings crowding A or B: $crowdedEverywhere of ${dead.seatings}');
  // The other three birds settle perfectly well, which is why hollows
  // stand empty while the jam refuses to clear.
  final rest = Rules.read('CDDEEF');
  check(Rules.tally(rest) == 4, 'the other three birds: ${Rules.tally(rest)}');
  check(Rules.tally(Rules.read('ABABAB')) == 0, 'the three on one tether');

  var worn = Play.of(dead);
  for (final bird in [0, 1, 2, 3, 4, 5, 0, 1]) {
    worn = worn.tap(bird);
  }
  check(worn.gaveUp, 'the hopeless ask did not admit it');
  check(!Play.of(dead).gaveUp, 'the hopeless ask admitted it at once');

  if (failed) {
    stderr.writeln('the wood is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every wood of six hollows and six or fewer birds walked, '
        '${commas(woods)} of them, each bird tethered between two hollows and '
        'sitting in one: ${commas(settling)} settle, meaning every bird gets '
        'a hollow to itself')
    ..write('; the count of settling seatings depends on which tethers are '
        'used and how often and not on which bird is on which, so the woods '
        'were walked as ${commas(boards)} boards, each standing for as many '
        'woods as there are ways of dealing its birds out, and that collapse '
        'is checked rather than assumed on all ${commas(ordered)} ordered '
        'woods of four birds or fewer')
    ..write('; every board was counted by walking all its seatings and '
        'counted again off its patches without walking any, and the two '
        'agreed ${commas(boards)} times out of ${commas(boards)}')
    ..write('; two further voices were asked whether each board settles at '
        'all, one taking all 63 sets of hollows in turn and looking for a set '
        'holding more birds than hollows, the other shoving birds along their '
        'tethers to make room, and both agreed with the count every time')
    ..write('; of the ${commas(layers[6]!.$1)} woods of six birds on six '
        'hollows, ${commas(spread[6]![0]!)} settle no way at all even though '
        'nothing is short of room, and the rest settle 2, 4 or 8 ways and '
        'nothing else: ${commas(spread[6]![2]!)}, ${commas(spread[6]![4]!)} '
        'and ${commas(spread[6]![8]!)} of them')
    ..write('; and no seating of any board that settles at all stands more '
        'than $deepest taps from one that does, a depth ${commas(atDepth)} boards '
        'of the ${commas(boards)} reach, the fourth ask among them');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of its ${level.seatings} seatings do it, the nearest '
            '${level.fewest} taps away'
        : 'none of its ${level.seatings}, and the patch A B said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
