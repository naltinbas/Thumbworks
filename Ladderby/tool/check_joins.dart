import 'dart:io';

import 'package:ladderby/join/frac.dart';
import 'package:ladderby/join/levels.dart';
import 'package:ladderby/join/play.dart';
import 'package:ladderby/join/rules.dart';

/// Crosses the joins of every hexagon on the rails two ways, checks the
/// three crossings for a line, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_joins.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  final triples = Rules.triples;
  check(triples.length == 336 && Rules.hexagons == 112896, 'triples ${triples.length}, hexagons ${Rules.hexagons}');
  var crossing = 0, level = 0, middle = 0, whole = 0, steep = 0, shifted = 0;
  final figures = <String>{}, levelFigures = <String>{}, middleFigures = <String>{}, wholeFigures = <String>{}, steepFigures = <String>{};
  for (final bottom in triples) {
    for (final top in triples) {
      final c = Rules.crossings(bottom, top), c2 = Rules.crossingsByForm(bottom, top);
      check((c == null) == (c2 == null), 'crossing or not: $bottom $top');
      if (c == null) continue;
      crossing++;
      final (x, y, z) = c;
      check(c2!.$1 == x && c2.$2 == y && c2.$3 == z, 'crossings of $bottom $top: general ${Rules.tell(x)} ${Rules.tell(y)} ${Rules.tell(z)}, form ${Rules.tell(c2.$1)} ${Rules.tell(c2.$2)} ${Rules.tell(c2.$3)}');
      check(Rules.inLine(x, y, z), 'bent: $bottom $top at ${Rules.tell(x)} ${Rules.tell(y)} ${Rules.tell(z)}');
      check(x != y && y != z && x != z, 'two crossings in one place: $bottom $top');
      // Each crossing lies on both of its joins.
      bool onJoin(Point p, int i, int j) {
        // Through (i, 0) and (j, h): (p.x - i) h == p.y (j - i).
        return (p.$1 - Frac.of(i)) * Frac.of(Rules.height) == p.$2 * Frac.of(j - i);
      }
      check(onJoin(x, bottom[0], top[1]) && onJoin(x, bottom[1], top[0]) && onJoin(y, bottom[0], top[2]) && onJoin(y, bottom[2], top[0]) && onJoin(z, bottom[1], top[2]) && onJoin(z, bottom[2], top[1]), 'a crossing off its joins: $bottom $top');
      final key = ([for (var i = 0; i < 3; i++) '${bottom[i]}-${top[i]}']..sort()).join(',');
      figures.add(key);
      final isLevel = x.$2 == y.$2 && y.$2 == z.$2;
      final isMiddle = isLevel && x.$2 == Frac.of(3);
      final isWhole = [x, y, z].every((p) => p.$1.isWhole && p.$2.isWhole);
      final isSteep = x.$1 == y.$1 && y.$1 == z.$1;
      if (isLevel) {
        level++;
        levelFigures.add(key);
      }
      if (isMiddle) {
        middle++;
        middleFigures.add(key);
      }
      if (isWhole) {
        whole++;
        wholeFigures.add(key);
      }
      if (isSteep) {
        steep++;
        steepFigures.add(key);
      }
      // A shift of the bottom triple along the top rail meets halfway up.
      final s = top[0] - bottom[0];
      if (top[1] - bottom[1] == s && top[2] - bottom[2] == s) {
        shifted++;
        check(isMiddle, 'a shifted hexagon off the middle rung: $bottom $top');
      }
    }
  }
  check(crossing == 85008 && figures.length == 14168 && crossing == 6 * figures.length, 'crossing $crossing, figures ${figures.length}');
  check(level == 2712 && levelFigures.length == 452 && middle == 1176 && middleFigures.length == 196 && whole == 5448 && wholeFigures.length == 908 && steep == 96 && steepFigures.length == 16, 'level $level/${levelFigures.length}, middle $middle/${middleFigures.length}, whole $whole/${wholeFigures.length}, steep $steep/${steepFigures.length}');
  check(shifted > 0, 'shifted hexagons $shifted');
  final one = Rules.crossings([0, 1, 2], [0, 1, 2])!;
  check(Rules.tell(one.$1) == '(1/2, 3)' && Rules.tell(one.$2) == '(1, 3)' && Rules.tell(one.$3) == '(3/2, 3)', 'the first hexagon');
  final rising = Rules.crossings([0, 2, 5], [1, 4, 6])!;
  check(Rules.tell(rising.$1) == '(8/5, 12/5)' && Rules.tell(rising.$2) == '(3, 3)' && Rules.tell(rising.$3) == '(22/5, 18/5)', 'the rising hexagon');
  final wholeOne = Rules.crossings([0, 1, 2], [1, 2, 0])!;
  check(Rules.tell(wholeOne.$1) == '(1, 3)' && Rules.tell(wholeOne.$2) == '(0, 12)' && Rules.tell(wholeOne.$3) == '(2, -6)', 'the whole hexagon');
  final steepOne = Rules.crossings([0, 2, 3], [0, 6, 3])!, steepTwo = Rules.crossings([0, 2, 6], [3, 2, 6])!;
  check(Rules.tell(steepOne.$1) == '(3/2, 3/2)' && Rules.tell(steepOne.$2) == '(3/2, 3)' && Rules.tell(steepOne.$3) == '(3/2, -3)' && Rules.tell(steepTwo.$1) == '(4, 12)' && Rules.tell(steepTwo.$2) == '(4, 4)' && Rules.tell(steepTwo.$3) == '(4, 3)', 'the steep hexagons');
  check(Rules.crossings([0, 1, 2], [2, 1, 0]) == null && Rules.crossings([0, 3, 6], [6, 3, 0]) == null, 'the parallel hexagons');

  // The asks.
  for (final level in Levels.all) {
    final found = <String>{};
    for (final bottom in triples) {
      for (final top in triples) {
        if (level.meets(bottom, top)) found.add(([for (var i = 0; i < 3; i++) '${bottom[i]}-${top[i]}']..sort()).join(','));
      }
    }
    check(found.length == level.ways, '${level.name}: ${level.ways} said, ${found.length} swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim.$1, aim.$2), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 12) {
        final (peg, _) = play.next!;
        play = play.tap(peg);
        steps++;
      }
      check(play.isDone && play.moves == 6, '${level.name}: the pointer never lands, or takes ${play.moves} taps');
    }
  }
  check(Levels.at(0).aim!.$1.join(',') == '0,1,2' && Levels.at(0).aim!.$2.join(',') == '0,1,2', 'the level line\'s aim');
  check(Levels.at(1).aim!.$1.join(',') == '0,1,2' && Levels.at(1).aim!.$2.join(',') == '0,1,2', 'the middle rung\'s aim');
  check(Levels.at(2).aim!.$1.join(',') == '0,1,2' && Levels.at(2).aim!.$2.join(',') == '1,2,0', 'the whole points\' aim');
  check(Levels.at(3).aim!.$1.join(',') == '0,2,3' && Levels.at(3).aim!.$2.join(',') == '0,6,3', 'the steep line\'s aim');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every ordering of three pegs on each of the two rails taken, ${commas(Rules.hexagons)} orderings, and the six cross-joins of each crossed by the general meeting of two lines and again by the closed form for parallel rails, the two agreeing wherever the joins cross, ${commas(crossing)} orderings, ${commas(figures.length)} hexagons counted once each, every crossing on both its joins, and the three crossings three different points in a line on every one; the crossings stand at one height on ${levelFigures.length} hexagons, halfway between the rails on ${middleFigures.length} of those, every hexagon whose top three are its bottom three shifted along among them, on pegs throughout on ${wholeFigures.length}, and one above another on ${steepFigures.length}; bottom 0, 1, 2 with top 0, 1, 2 crosses at (1/2, 3), (1, 3) and (3/2, 3), and with top 1, 2, 0 at (1, 3), (0, 12) and (2, -6)\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(figures.length)} hexagons land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(figures.length)}, and Pappus said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
