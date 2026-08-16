import 'dart:io';

import 'package:beamsley/shadow/frac.dart';
import 'package:beamsley/shadow/levels.dart';
import 'package:beamsley/shadow/play.dart';
import 'package:beamsley/shadow/rules.dart';

/// Crosses every triangle with every cast of its shadow two ways, holds
/// the three meetings to a line, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_shadows.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  check(Rules.pegs.length == 24 && Rules.casts.join(',') == '-2,-1,2,3', 'the field and the casts');
  var onOneRay = 0;
  for (final a in Rules.pegs) {
    for (final b in Rules.pegs) {
      if (b == a) continue;
      for (final c in Rules.pegs) {
        if (c == a || c == b) continue;
        if (!Rules.flat([a, b, c]) && Rules.sharesRay([a, b, c])) onOneRay++;
      }
    }
  }
  check(onOneRay == 3408, 'triangles with two pegs on one ray: $onOneRay');
  check(!Rules.pegs.contains((0, 0)), 'the lantern stands among the pegs');

  var triangles = 0, settings = 0, inLine = 0, agree = 0;
  var allFar = 0, twoFar = 0, oneFar = 0, noneFar = 0, allCastsEqual = 0;
  var whole = 0, level = 0, upright = 0, lantern = 0, together = 0;
  for (final a in Rules.pegs) {
    for (final b in Rules.pegs) {
      if (b == a) continue;
      for (final c in Rules.pegs) {
        if (c == a || c == b) continue;
        final t = [a, b, c];
        if (!Rules.valid(t)) continue;
        triangles++;
        for (final ta in Rules.casts) {
          for (final tb in Rules.casts) {
            for (final tc in Rules.casts) {
              settings++;
              final casts = [ta, tb, tc];
              final m = Rules.meetings(t, casts);
              if (Rules.inLine(m)) inLine++;
              // Every meeting lies on both of the sides that made it.
              var sound = true;
              for (var s = 0; s < 3; s++) {
                final u = (s + 1) % 3;
                final side = Rules.cross(Rules.homo(t[s]), Rules.homo(t[u]));
                final shade = Rules.cross(Rules.homo(Rules.shadow(t[s], casts[s])), Rules.homo(Rules.shadow(t[u], casts[u])));
                final p = m[s];
                if (side.$1 * p.$1 + side.$2 * p.$2 + side.$3 * p.$3 != 0) sound = false;
                if (shade.$1 * p.$1 + shade.$2 * p.$2 + shade.$3 * p.$3 != 0) sound = false;
                if (Rules.isNowhere(p)) sound = false;
              }
              check(sound, 'a meeting off its sides: $t $casts');
              // The second voice: the same meetings by plain fractions.
              var same = true;
              for (var s = 0; s < 3; s++) {
                final byHand = Rules.meetingByHand(t, casts, s);
                final p = m[s];
                if (byHand == null) {
                  if (!Rules.atInfinity(p)) same = false;
                } else if (Rules.atInfinity(p)) {
                  same = false;
                } else {
                  if (Frac.of(p.$1, p.$3) != byHand.$1 || Frac.of(p.$2, p.$3) != byHand.$2) same = false;
                }
              }
              if (same) agree++;
              final far = m.where(Rules.atInfinity).length;
              if (far == 3) allFar++;
              if (far == 2) twoFar++;
              if (far == 1) oneFar++;
              if (far == 0) noneFar++;
              final equal = ta == tb && tb == tc;
              if (equal) allCastsEqual++;
              check(equal == (far == 3), 'the casts and the far meetings differ: $t $casts');
              check(far != 2, 'two meetings far off and one at hand: $t $casts');
              final axis = Rules.axis(m);
              if (axis == null) together++;
              if (axis != null) {
                if (m.every((h) => h.$3 != 0 && h.$1 % h.$3 == 0 && h.$2 % h.$3 == 0)) whole++;
                if (axis.$1 == 0 && axis.$2 != 0) level++;
                if (axis.$2 == 0 && axis.$1 != 0) upright++;
                if (axis.$3 == 0 && !(axis.$1 == 0 && axis.$2 == 0)) lantern++;
                // Every meeting lies on the axis.
                for (final p in m) {
                  check(axis.$1 * p.$1 + axis.$2 * p.$2 + axis.$3 * p.$3 == 0, 'a meeting off the axis: $t $casts');
                }
              }
            }
          }
        }
      }
    }
  }
  check(triangles == 7992 && settings == 511488 && settings == triangles * 64, 'triangles $triangles, settings $settings');
  check(inLine == settings && agree == settings, 'in a line $inLine, the two voices agreeing $agree, of $settings');
  check(allFar == 31968 && allFar == triangles * 4 && allCastsEqual == allFar, 'all far $allFar, casts equal $allCastsEqual');
  check(twoFar == 0 && oneFar == 287712 && noneFar == 191808, 'two far $twoFar, one far $oneFar, none far $noneFar');
  check(whole == 1248 && level == 43872 && upright == 43872 && lantern == 7200 && together == 0, 'whole $whole, level $level, upright $upright, lantern $lantern, together $together');

  // The named settings.
  final named = [(1, 0), (0, 1), (-1, -1)];
  final m1 = Rules.meetings(named, [2, 3, -1]);
  check(m1.map(Rules.tellPoint).join(' ') == '(4, -3) (1/2, 2) (5/3, 1/3)', 'the named triangle: ${m1.map(Rules.tellPoint)}');
  check(Rules.inLine(m1) && Rules.tellLine(Rules.axis(m1)!) == 'the line -10 x - 7 y = -19', 'its axis: ${Rules.tellLine(Rules.axis(m1)!)}');
  final m2 = Rules.meetings(named, [2, 2, 2]);
  check(m2.every(Rules.atInfinity) && Rules.tellLine(Rules.axis(m2)!) == 'the line at infinity', 'the blown-up triangle');
  check(Rules.flat([(1, 0), (2, 0), (-1, 0)]) && !Rules.flat(named), 'the flat triangles');
  check(Rules.sharesRay([(-2, -2), (-1, -2), (-1, -1)]) && !Rules.valid([(-2, -2), (-1, -2), (-1, -1)]) && Rules.valid(named), 'the triangles on one ray');
  check(Rules.shadow((1, 0), 3) == (3, 0) && Rules.shadow((-1, 2), -2) == (2, -4), 'the shadows');

  // The asks.
  for (final lv in Levels.all) {
    var ways = 0;
    for (final a in Rules.pegs) {
      for (final b in Rules.pegs) {
        if (b == a) continue;
        for (final c in Rules.pegs) {
          if (c == a || c == b) continue;
          final t = [a, b, c];
          if (!Rules.valid(t)) continue;
          for (final ta in Rules.casts) {
            for (final tb in Rules.casts) {
              for (final tc in Rules.casts) {
                if (lv.meets(t, [ta, tb, tc])) ways++;
              }
            }
          }
        }
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
      while (!play.isDone && steps < 40) {
        final n = play.next!;
        play = n.$1 == 'peg' ? play.tap(play.wanted!) : n.$1 == 'lift' ? play.tap(play.pegs.last) : play.step(n.$2, play.castWay(n.$2));
        steps++;
      }
      check(play.isDone, '${lv.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim!.$2.join(',') == '-1,3,2' && Levels.at(2).aim!.$2.join(',') == '-2,-2,-2', 'the aims');
  final dead = Play.of(Levels.at(4)).tap((1, 0)).tap((0, 1)).tap((-1, -1)).step(0, 1).step(1, 1);
  check(dead.tried == 3 && dead.gaveUp, 'the crooked axis does not admit it after three settings');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every triangle of three pegs of the field about the lantern taken, ${commas(triangles)} of them, with every cast of the three shadows, four apiece, ${commas(settings)} settings, and the three meetings of matching sides found twice, once as homogeneous whole numbers by crossing the side-lines and once by solving the two lines as plain fractions, the two agreeing on all ${commas(settings)}: every meeting lies on both the sides that made it, the three lie on one line on every setting, and every meeting lies on that line; the three never fall together; the casts are equal on ${commas(allCastsEqual)} settings and those are exactly the ${commas(allFar)} where all three meetings run off to infinity and the axis is the line at infinity, exactly two equal leaves one meeting far off, ${commas(oneFar)} settings, none equal leaves none, ${commas(noneFar)}, and two meetings far off with one at hand never happens; the three meetings all fall on peg places on ${commas(whole)} settings, the axis lies level on ${commas(level)} and upright on as many, and runs through the lantern on ${commas(lantern)}; the pegs (1, 0), (0, 1) and (-1, -1) cast 2, 3 and -1 meet at (4, -3), (1/2, 2) and (5/3, 1/3)\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final lv = Levels.at(i);
    final tail = lv.winnable
        ? '${commas(lv.ways)} of the ${commas(settings)} settings land${lv.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(settings)}, and Desargues said so first';
    stdout.writeln(' ${i + 1} ${lv.name.padRight(width)} ${lv.task}: $tail');
  }
}
