import 'dart:io';

import 'package:footbury/foot/frac.dart';
import 'package:footbury/foot/levels.dart';
import 'package:footbury/foot/play.dart';
import 'package:footbury/foot/rules.dart';

/// Drops the feet of every point on every rim triangle, measures their
/// triangle two ways, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_feet.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  check(Rules.rim.length == 12 && Rules.rim.every(Rules.onRim) && Rules.field.length == 121 && Rules.triangles.length == 220, 'the rim, the field and the triangles');
  check(Rules.field.where(Rules.onRim).length == 12, 'rim pegs in the field');
  var configs = 0, onRim = 0, lineOnRim = 0, lineOffRim = 0, viaMiddle = 0, level = 0, along = 0, quarter = 0, fifth = 0;
  final shares = <Frac>{};
  Frac? least, most;
  for (final t in Rules.triangles) {
    final whole = Rules.twiceAreaOf(t);
    check(whole != Frac.zero, 'a flat triangle $t');
    for (final p in Rules.field) {
      if (t.contains(p)) continue;
      configs++;
      final feet = Rules.feet(t, p);
      // Every foot lies on its side-line and the drop is square to it.
      for (var i = 0; i < 3; i++) {
        final a = t[(i + 1) % 3], b = t[(i + 2) % 3];
        final f = feet[i];
        final onLine = (Frac.of(b.$1 - a.$1)) * (f.$2 - Frac.of(a.$2)) - (Frac.of(b.$2 - a.$2)) * (f.$1 - Frac.of(a.$1)) == Frac.zero;
        final square = (f.$1 - Frac.of(p.$1)) * Frac.of(b.$1 - a.$1) + (f.$2 - Frac.of(p.$2)) * Frac.of(b.$2 - a.$2) == Frac.zero;
        check(onLine && square, 'a foot astray: $t, $p, foot ${Rules.tellPoint(f)}');
      }
      final byFeet = Rules.ratioByFeet(t, p), byEuler = Rules.ratioByEuler(p);
      check(byFeet == byEuler, 'the two measures differ on $t, $p: $byFeet and $byEuler');
      shares.add(byFeet);
      if (least == null || byFeet.compareTo(least) < 0) least = byFeet;
      if (most == null || byFeet.compareTo(most) > 0) most = byFeet;
      final line = Rules.simsonLine(t, p);
      check((line != null) == (byFeet == Frac.zero) || (line == null && byFeet == Frac.zero && feet.toSet().length == 1), 'the line and the measure differ on $t, $p');
      if (Rules.onRim(p)) {
        onRim++;
        if (line != null) {
          lineOnRim++;
          if (Rules.through(line, (Frac.zero, Frac.zero))) viaMiddle++;
          if (Rules.level(line)) level++;
          if (Rules.alongSide(line, t)) along++;
        }
      } else {
        if (line != null) lineOffRim++;
        if (byFeet == Frac.of(1, 4)) quarter++;
        if (byFeet == Frac.of(1, 5)) fifth++;
      }
    }
  }
  check(configs == 25960 && onRim == 1980 && lineOnRim == 1980 && lineOffRim == 0, 'settings $configs, on the rim $onRim, lines on the rim $lineOnRim, off $lineOffRim');
  check(viaMiddle == 156 && level == 114 && along == 540 && quarter == 220 && fifth == 1760, 'via the middle $viaMiddle, level $level, along a side $along, quarter $quarter, fifth $fifth');
  check(shares.length == 20 && most == Frac.of(1, 4) && least == Frac.of(-1, 4), 'shares ${shares.length}, from $least to $most');
  final t = [(5, 0), (-4, 3), (-3, -4)];
  check(Rules.feet(t, (0, 5)).map(Rules.tellPoint).join(' ') == '(-21/5, 22/5) (3, -1) (-1, 2)' && Rules.simsonLine(t, (0, 5)) != null && Rules.ratioByFeet(t, (0, 0)) == Frac.of(1, 4) && Rules.ratioByFeet(t, (1, 2)) == Frac.of(1, 5), 'the named triangle');
  check(Rules.ratioByEuler((5, 5)) == Frac.of(-1, 4) && Rules.ratioByEuler((3, 4)) == Frac.zero, 'the shares at a corner and on the rim');

  // The asks.
  for (final lv in Levels.all) {
    var ways = 0;
    for (final tr in Rules.triangles) {
      for (final p in Rules.field) {
        if (lv.meets(tr, p)) ways++;
      }
    }
    check(ways == lv.ways, '${lv.name}: ${lv.ways} said, $ways swept');
    final aim = lv.aim;
    check((aim == null) == !lv.winnable, '${lv.name}: aim $aim');
    if (aim != null) check(lv.meets(aim.$1, aim.$2), '${lv.name}: the aim misses');
    final open = Play.of(lv);
    check(!open.isOver, '${lv.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 12) {
        final (peg, _) = play.next!;
        play = play.tap(peg);
        steps++;
      }
      check(play.isDone && play.moves == 4, '${lv.name}: the pointer never lands, or takes ${play.moves} taps');
    }
  }
  check(Levels.at(2).aim.toString() == '([(5, 0), (4, 3), (-5, 0)], (0, -5))' && Levels.at(3).aim.toString() == '([(5, 0), (4, 3), (3, 4)], (0, 5))', 'the aims');
  final dead = Play.of(Levels.at(4)).tap((5, 0)).tap((-4, 3)).tap((-3, -4)).tap((0, 0)).tap((0, 0)).tap((1, 2)).tap((1, 2)).tap((2, 2));
  check(dead.tried == 3 && dead.gaveUp, 'the line off the rim does not admit it after three points');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every triangle of three rim pegs taken, 220, with every point of the field but its corners, 118 each, ${commas(configs)} settings, and the three feet dropped exactly, each on its side-line and square to it, their triangle measured against the whole by the feet themselves and again by Euler\'s rule, the square of the radius less the square of the point\'s distance from the middle over four times the square of the radius, the two agreeing on all ${commas(configs)}: the feet lie in a line on the ${commas(onRim)} settings with the point on the rim and on none of the ${commas(configs - onRim)} others; the feet\'s line runs through the middle on $viaMiddle rim settings, lies level on $level and along a side of the triangle on $along; the feet make a quarter of the whole for the middle point on all 220 triangles and a fifth for the eight points root five out, ${commas(fifth)} settings, and ${shares.length} shares come in all, from a quarter at the middle to minus a quarter at the field\'s corners\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final lv = Levels.at(i);
    final tail = lv.winnable
        ? '${commas(lv.ways)} of the ${commas(configs)} settings land${lv.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(configs)}, and Euler\'s rule said so first';
    stdout.writeln(' ${i + 1} ${lv.name.padRight(width)} ${lv.task}: $tail');
  }
}
