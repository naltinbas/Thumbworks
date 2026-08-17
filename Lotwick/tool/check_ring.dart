import 'dart:io';

import 'package:lotwick/ring/levels.dart';
import 'package:lotwick/ring/play.dart';
import 'package:lotwick/ring/rules.dart';

/// Runs every bid against every rival bid in both rings, holds each one
/// to the window, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_ring.dart
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

  // The big sweep: a hundred crowns on each dial, and both rings.
  const high = 99;
  var triples = 0, sealedBeats = 0, openBeats = 0, openShading = 0;
  var windowUsed = 0;
  for (var worth = 0; worth <= high; worth++) {
    for (var bid = 0; bid <= high; bid++) {
      for (var rival = 0; rival <= high; rival++) {
        triples++;
        final ran = Rules.paidBy(Rules.sealed, worth, bid, rival) -
            Rules.truthPays(Rules.sealed, worth, rival);
        final window = Rules.windowGap(worth, bid, rival);
        check(ran == window,
            'worth $worth, bid $bid, rival $rival: ran $ran, window $window');
        if (window != 0) windowUsed++;
        check(window <= 0, 'the window opened upward at $worth, $bid, $rival');
        if (ran > 0) sealedBeats++;
        final openRan = Rules.paidBy(Rules.open, worth, bid, rival) -
            Rules.truthPays(Rules.open, worth, rival);
        check((openRan > 0) == Rules.shadingPays(worth, bid, rival),
            'the open ring at $worth, $bid, $rival: $openRan');
        if (openRan > 0) {
          openBeats++;
          if (bid < worth) openShading++;
        }
        // The truthful bid earns nothing at all in the open ring.
        check(Rules.truthPays(Rules.open, worth, rival) == 0,
            'the open ring paid the truth at $worth, $rival');
      }
    }
  }
  check(triples == 1000000, 'triples swept: $triples');
  check(sealedBeats == 0, 'bids that beat the truth in the sealed ring: $sealedBeats');
  check(openBeats == 161700 && openShading == openBeats,
      'bids that beat the truth in the open ring: $openBeats, shading $openShading');
  // A tie goes to the rivals, which is what makes the window closed at
  // its lower end.
  check(!Rules.wins(5, 5) && Rules.wins(6, 5), 'the tie rule');
  check(Rules.windowGap(1, 0, 0) == -1, 'the window at its lower end');

  // The dials the game gives.
  var settings = 0;
  final ways = <String, int>{for (final level in Levels.all) level.name: 0};
  final cheapest = <String, int>{};
  final opening = (Rules.openWorth, Rules.openBid, Rules.openRival);
  for (final (worth, bid, rival) in Rules.settings()) {
    settings++;
    for (final level in Levels.all) {
      if (!level.meets(worth, bid, rival)) continue;
      ways[level.name] = ways[level.name]! + 1;
      final taps = Rules.taps(opening, (worth, bid, rival));
      final held = cheapest[level.name];
      if (held == null || taps < held) cheapest[level.name] = taps;
    }
  }
  check(settings == Rules.howManySettings && settings == 2197,
      'settings swept: $settings');
  for (final level in Levels.all) {
    check(ways[level.name] == level.ways,
        '${level.name}: ${ways[level.name]} against ${level.ways}');
    if (level.winnable) {
      final aim = level.aim!;
      check(level.meets(aim.$1, aim.$2, aim.$3), '${level.name}: the aim misses');
      check(Rules.taps(opening, aim) == cheapest[level.name],
          '${level.name}: the aim takes ${Rules.taps(opening, aim)}, cheapest '
          '${cheapest[level.name]}');
    } else {
      check(level.aim == null && ways[level.name] == 0,
          '${level.name} was landed');
    }
    // Nothing is landed before a tap is taken.
    check(!level.meets(Rules.openWorth, Rules.openBid, Rules.openRival),
        '${level.name} is landed at the opening');
  }

  // The pointer lands every ask it can, in the fewest taps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 40) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.step(aim.$1, aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  if (failed) {
    stderr.writeln('the ring is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every setting of the three dials taken at a hundred crowns a '
        'dial, what the beast is worth, what you bid and the best bid '
        'against you, ${commas(triples)} in all, and each one run in both '
        'rings and held to the window, which runs no auction: the two agree '
        'on every setting, and the window opens downward on all '
        '${commas(windowUsed)} settings where it opens at all')
    ..write('; in the sealed ring, where the winner pays the second bid, not '
        'one of the ${commas(triples)} settings has a bid earning more than '
        'bidding what the beast is worth, whichever way the rivals go')
    ..write('; in the open ring, where the winner pays what he bid, '
        '${commas(openBeats)} settings beat the truthful bid and every one of '
        'them is a bid under the worth, since the truthful bid there pays its '
        'whole worth away and earns nothing at all')
    ..write('; a tie goes to the rivals, so a bid level with the best rival '
        'bid loses, which is why the window is closed at its lower end: with '
        'a beast worth one crown and a rival bidding nothing, the truthful '
        'bid of one takes it for nothing and earns the whole crown, while a '
        'bid of nothing ties with the rival and comes away with neither')
    ..write('; and on the ${commas(settings)} settings the dials of this sham '
        'reach, the same holds and the asks are counted');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(settings)} settings land it, '
            'the cheapest in ${level.fewest} '
            '${level.fewest == 1 ? 'tap' : 'taps'}'
        : 'none of the ${commas(settings)}, nor of the ${commas(triples)}, '
            'and the window says why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
