import 'dart:io';

import 'package:beatstow/beat/levels.dart';
import 'package:beatstow/beat/play.dart';
import 'package:beatstow/beat/rules.dart';

/// Walks every rack of five single-figure throws and every laying of
/// every one of them, three voices apiece, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_beats.dart
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

  check(Rules.beats == 5, 'beats on the ring: ${Rules.beats}');

  // Every rack of five throws from nothing to nine, and every laying.
  final racks = Rules.racks(Rules.beats, 9);
  check(racks.length == 2002, 'racks of five: ${racks.length}');

  var layings = 0, juggled = 0, voicesDiffer = 0, averagesDiffer = 0;
  var evenRacks = 0, juggleRacks = 0, iffBroken = 0;
  final waysSeen = <int, int>{};
  for (final rack in racks) {
    final all = Rules.orderings(rack);
    var here = 0;
    for (final laying in all) {
      layings++;
      // The first voice: read the landing beats and ask whether they are
      // all different.
      final byLanding = Rules.juggles(laying);
      // The second: watch the pattern run and count the balls in the air
      // after each beat. It knows nothing of landings or averages.
      final bySteady = Rules.steady(laying);
      if (byLanding != bySteady) voicesDiffer++;
      check(byLanding == bySteady, 'the two voices differ on $laying');
      if (byLanding) {
        juggled++;
        here++;
        final up = Rules.aloft(laying);
        if (up.first * Rules.beats != Rules.total(laying)) averagesDiffer++;
        check(up.first * Rules.beats == Rules.total(laying),
            'the balls in the air are not the average on $laying');
      }
    }
    waysSeen[here] = (waysSeen[here] ?? 0) + 1;
    // Every count of ways divides by the beats, because turning a rack
    // round the ring sends a pattern to a pattern.
    final constant = rack.toSet().length == 1;
    check(here % Rules.beats == 0 || constant,
        'ways on $rack came to $here');
    // The rack decides the matter before a throw is laid: the total
    // going round evenly is the same as some laying juggling.
    final evens = Rules.total(rack) % Rules.beats == 0;
    if (evens) evenRacks++;
    if (here > 0) juggleRacks++;
    if (evens != (here > 0)) iffBroken++;
    check(evens == (here > 0), 'the rack $rack breaks the iff');
  }

  check(layings == 100000, 'layings walked: $layings');
  check(juggled == 3840, 'layings that juggle: $juggled');
  check(voicesDiffer == 0, 'the two voices differed $voicesDiffer times');
  check(averagesDiffer == 0, 'the average was wrong $averagesDiffer times');
  check(iffBroken == 0, 'the iff broke $iffBroken times');
  check(evenRacks == juggleRacks, 'racks that even out: $evenRacks, racks '
      'that juggle: $juggleRacks');
  check(waysSeen[0] == 1600, 'racks that never juggle: ${waysSeen[0]}');
  check(waysSeen.keys.toList().length == 6,
      'counts of ways seen: ${waysSeen.keys.toList()}');
  for (final n in waysSeen.keys) {
    check(n == 0 || n == 1 || n % Rules.beats == 0,
        'a count of ways that is $n');
  }

  // The third voice lays nothing out and counts by a closed form. It is
  // held against a sweep with no cap on the heights, which is where it
  // is true: a pattern of five beats keeping b balls has no throw above
  // five times b.
  for (var balls = 0; balls <= 2; balls++) {
    final top = balls * Rules.beats;
    var counted = 0;
    void walk(List<int> so) {
      if (so.length == Rules.beats) {
        if (Rules.total(so) == balls * Rules.beats && Rules.juggles(so)) {
          counted++;
        }
        return;
      }
      for (var h = 0; h <= top; h++) {
        walk([...so, h]);
      }
    }

    walk(const []);
    check(counted == Rules.byFormula(Rules.beats, balls),
        'the closed form differs at $balls balls: $counted against '
        '${Rules.byFormula(Rules.beats, balls)}');
  }
  check(Rules.byFormula(5, 3) == 781, 'three balls on five beats');
  check(Rules.byFormula(5, 0) == 1, 'no balls at all');

  // The asks.
  for (final level in Levels.all) {
    final w = Rules.ways(level.rack);
    check(w.length == level.ways,
        '${level.name}: ${w.length} against ${level.ways}');
    check(level.layings == Rules.orderings(level.rack).length,
        '${level.name}: the layings');
    check(!level.meets(const [-1, -1, -1, -1, -1]),
        '${level.name} is landed on an empty ring');
    if (level.winnable) {
      check(level.fewest == Rules.beats * 2,
          '${level.name}: ${level.fewest} against ${Rules.beats * 2}');
      check(level.evens, '${level.name} does not even out and yet juggles');
      check(level.balls == 3, '${level.name} keeps ${level.balls} balls');
      // Every winning laying and every turning of it juggles too.
      for (final win in w) {
        check(Rules.juggles(win), '${level.name} accepted a drop');
        check(Rules.juggles(Rules.turn(win)), '${level.name} turned badly');
      }
    } else {
      check(level.fewest == null && w.isEmpty, '${level.name} was landed');
      check(!level.evens, '${level.name} is hopeless for some other reason');
      check(level.total == 16, '${level.name} adds to ${level.total}');
    }
  }

  // Every rack of five single-figure throws adding to sixteen is the
  // same story, which is what makes the fifth ask a rule and not a case.
  var sixteens = 0, sixteensDead = 0;
  for (final rack in racks) {
    if (Rules.total(rack) != 16) continue;
    sixteens++;
    if (Rules.ways(rack).isEmpty) sixteensDead++;
  }
  check(sixteens == 74, 'racks adding to sixteen: $sixteens');
  check(sixteensDead == sixteens, 'of those, dead: $sixteensDead');

  // The pointer lays every ask it can, in the taps it promises.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 24) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = aim.$1 == null ? play.tap(aim.$2) : play.take(aim.$1!);
      steps++;
    }
    check(play.isDone, '${level.name} was never juggled');
    check(play.taps == level.fewest,
        '${level.name} in ${play.taps} against ${level.fewest}');
  }

  // The hopeless ask: four throws go down and the fifth never does.
  final dead = Levels.all.last;
  check(Play.of(dead).next == null, 'the hopeless ask kept a pointer');
  final walls = <String>{};
  void fill(Play play) {
    var moved = false;
    for (final h in play.rack.toSet()) {
      for (var b = 0; b < Rules.beats; b++) {
        if (!play.canLay(b, h)) continue;
        moved = true;
        fill(play.take(h).tap(b));
      }
    }
    if (moved) return;
    var laid = 0;
    for (final t in play.laid) {
      if (t >= 0) laid++;
    }
    check(laid == Rules.beats - 1, 'the wall came at $laid throws');
    walls.add(play.mark);
  }

  fill(Play.of(dead));
  check(walls.length == 10, 'ways of reaching the wall: ${walls.length}');

  var stuck = Play.of(dead);
  for (final step in [(3, 0), (3, 1), (3, 2), (4, 3)]) {
    final was = stuck;
    stuck = stuck.take(step.$1).tap(step.$2);
    check(stuck.mark != was.mark, 'a throw that would not go down at $step');
  }
  var laidNow = 0;
  for (final t in stuck.laid) {
    if (t >= 0) laidNow++;
  }
  check(laidNow == 4, 'throws down after the wall: $laidNow');
  // The last throw is refused from every free beat.
  final last = stuck.rack.single;
  for (var b = 0; b < Rules.beats; b++) {
    if (stuck.laid[b] >= 0) continue;
    check(!stuck.canLay(b, last), 'the last throw went down on beat $b');
  }
  // Picking the last throw up and putting it down again wears the ask
  // out, since it never lands anywhere.
  while (!stuck.gaveUp && stuck.taps < 60) {
    stuck = stuck.take(last);
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');
  check(!Play.of(dead).gaveUp, 'it admitted it at once');

  if (failed) {
    stderr.writeln('the ring is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every rack of ${Rules.beats} throws from nothing to nine taken, '
        '${commas(racks.length)} of them, and every different way of laying '
        'each on the beats, ${commas(layings)} layings in all: '
        '${commas(juggled)} juggle, meaning no two balls come down together')
    ..write('; each laying was read two ways, once by taking the landing '
        'beats and asking whether they are all different, and once by '
        'watching the pattern run and counting the balls still in the air '
        'after each beat, which knows nothing of landings: the two agreed '
        '${commas(layings)} times out of ${commas(layings)}')
    ..write('; on every laying that juggles the balls in the air held steady '
        'beat by beat and came to the throws added up over the beats, the '
        'plain average, every time')
    ..write('; the rack settles the matter before a throw is laid, since a '
        'rack juggles some way exactly when its total goes round the beats '
        'evenly: ${commas(evenRacks)} racks of the ${commas(racks.length)} do '
        'both and ${commas(waysSeen[0]!)} do neither, with no rack doing one '
        'and not the other')
    ..write('; the ways a rack can be laid come to 0, 1, 5, 10, 15 or 20 and '
        'nothing else, since turning a laying round the ring gives another, '
        'and the count of 1 belongs to the racks whose five throws are all '
        'the same')
    ..write('; a third voice lays nothing out at all and counts the patterns '
        'of five beats keeping b balls as b plus one raised to the five, less '
        'b raised to the five, and it agrees with a sweep that puts no cap on '
        'the throws')
    ..write('; all $sixteens racks of five single-figure throws adding to 16 '
        'juggle no way whatever, and on the one the last ask ships, four '
        'throws will go down ${walls.length} different ways and the fifth is '
        'refused from every free beat every time');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of its ${level.layings} layings juggle, '
            '${level.fewest} taps for a clean run'
        : 'none of its ${level.layings}, and the throws added up said so '
            'first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
