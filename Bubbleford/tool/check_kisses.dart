import 'dart:io';

import 'package:bubbleford/kiss/levels.dart';
import 'package:bubbleford/kiss/play.dart';
import 'package:bubbleford/kiss/rules.dart';

/// Works the fourth bends of every setting two ways, counts what
/// Descartes promises, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_kisses.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  check(Rules.count == 8000 && Rules.triples.length == 8000, 'the settings ${Rules.count}');
  var whole = 0, wraps = 0, flat = 0, gap = 0, unit = 0, wholeWrap = 0, wholeGap = 0, twins = 0;
  for (final k in Rules.triples) {
    final s = Rules.sum(k), q = Rules.pairs(k);
    // The algebra behind the formula: s^2 = a^2 + b^2 + c^2 + 2q.
    check(s * s == Rules.squares(k) + 2 * q, 'the squares on ${Rules.tell(k)}');
    final f = Rules.fourths(k);
    final trial = Rules.fourthsByTrial(k);
    if (f == null) {
      check(trial.isEmpty, 'the trial finds a whole fourth the formula misses on ${Rules.tell(k)}: $trial');
    } else {
      check(trial.length == 2 && trial.contains(f.$1) && trial.contains(f.$2), 'the trial and the formula differ on ${Rules.tell(k)}: $trial and $f');
      check(Rules.descartes(k[0], k[1], k[2], f.$1) && Rules.descartes(k[0], k[1], k[2], f.$2), 'a whole fourth off the relation on ${Rules.tell(k)}');
      check(f.$1 != f.$2, 'twin fourths on ${Rules.tell(k)}');
      whole++;
      if (f.$2 == -1) unit++;
    }
    if (q == 0) twins++;
    final sg = Rules.outerSign(k);
    check(sg == (f == null ? (s * s - 4 * q).sign : (f.$2).sign), 'the outer sign on ${Rules.tell(k)}');
    if (sg < 0) wraps++;
    if (sg == 0) flat++;
    if (sg > 0) gap++;
    if (f != null && sg < 0) wholeWrap++;
    if (f != null && sg > 0) wholeGap++;
  }
  check(whole == 207 && wraps == 7001 && flat == 33 && gap == 966 && unit == 27 && wholeWrap == 156 && wholeGap == 18 && twins == 0, 'whole $whole, wraps $wraps, flat $flat, gap $gap, unit $unit, whole wrap $wholeWrap, whole gap $wholeGap, twins $twins');
  check(Rules.fourths([2, 2, 3]) == (15, -1) && Rules.fourths([2, 3, 6]) == (23, -1) && Rules.fourths([1, 1, 4]) == (12, 0) && Rules.fourths([1, 1, 12]) == (24, 4) && Rules.fourths([1, 4, 12]) == (33, 1), 'the named settings');
  check(Rules.fourths([1, 1, 1]) == null && Rules.tellFourth([1, 1, 1], inner: true) == '3 + 2 root 3' && Rules.tellFourth([1, 1, 1], inner: false) == '3 - 2 root 3' && Rules.tellFourth([4, 4, 4], inner: false) == '12 - 8 root 3', 'the equal bends');
  for (var k = 1; k <= 5; k++) {
    check(Rules.outerSign([k, k, 4 * k]) == 0, 'k, k, 4k not flat for $k');
  }
  check(Rules.descartes(-1, 2, 2, 3) && Rules.descartes(-1, 2, 3, 6) && !Rules.descartes(1, 2, 3, 4), 'the relation');
  check(Rules.root(49) == 7 && Rules.root(50) == null && Rules.root(0) == 0, 'the roots');

  // The asks.
  for (final level in Levels.all) {
    final ways = Rules.triples.where(level.meets).length;
    check(ways == level.ways, '${level.name}: ${level.ways} said, $ways swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 60) {
        final (place, by) = play.next!;
        play = play.step(place, by);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim!.join(',') == '2,2,3' && Levels.at(1).aim!.join(',') == '1,1,4' && Levels.at(3).aim!.join(',') == '1,1,12', 'the aims');
  final dead = Play.of(Levels.at(4)).step(2, 1).step(2, 1).step(2, 1).step(1, 1).step(1, 1).step(1, 1).step(2, 1).step(2, 1).step(2, 1).step(2, 1).step(2, 1);
  check(dead.seen.length == 2 && !dead.gaveUp && dead.moves == 11, 'the dead route: seen ${dead.seen}, moves ${dead.moves}');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every setting of the three dials taken, bends 1 to 20, ${commas(Rules.count)} settings, the two fourth bends worked by the formula, the three added give or take twice the root of the pairwise sum, and every whole bend from -60 to 180 tried against Descartes\' relation itself, the two agreeing on all ${commas(Rules.count)}, the sum of the three squared being their squares added and twice the pairwise sum on every one: both fourths are whole on $whole settings, the pairwise sum a square, and never of one bend; the outer bubble wraps round the three on ${commas(wraps)} settings, flattens to a line on $flat, k, k and 4k among them for every k, and sits in the far gap on $gap; a unit bubble rings the three on $unit, 2, 2 and 3 with 15 in the gap and 2, 3 and 6 with 23; both fourths whole and the outer wrapping on $wholeWrap, both whole and the outer in the far gap on $wholeGap, 1, 1 and 12 with 24 and 4 among them; and equal bends give a fourth of three times the bend give or take twice the bend times root three, never whole\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(Rules.count)} settings land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(Rules.count)}, and the root said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
