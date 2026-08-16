import 'dart:io';

import 'package:sliverton/sliver/frac.dart';
import 'package:sliverton/sliver/level.dart';
import 'package:sliverton/sliver/levels.dart';
import 'package:sliverton/sliver/play.dart';
import 'package:sliverton/sliver/rules.dart';

/// Cuts every setting of the marks two ways, measures the sliver by its
/// corners and by Routh's rule, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_slivers.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  check(Rules.side == 12 && Rules.least == 1 && Rules.most == 11, 'the field and the marks');
  check(Rules.twiceField == Frac.of(144), 'the field\'s area: ${Rules.twiceField}');
  check(Rules.onBC(8) == (Frac.of(4), Frac.of(8)) && Rules.onCA(8) == (Frac.zero, Frac.of(4)) && Rules.onAB(8) == (Frac.of(8), Frac.zero), 'the marks: ${Rules.onBC(8)}');

  var settings = 0, agree = 0, meet = 0, gone = 0, seventh = 0, seventieth = 0, twoTenth = 0, widest = 0, thin = 0, fat = 0, sly = 0;
  final shares = <Frac>{};
  Frac? most, least;
  for (var d = Rules.least; d <= Rules.most; d++) {
    for (var e = Rules.least; e <= Rules.most; e++) {
      for (var f = Rules.least; f <= Rules.most; f++) {
        settings++;
        final m = [d, e, f];
        final byCorners = Rules.shareByCorners(m), byRouth = Rules.shareByRouth(m);
        if (byCorners == byRouth) agree++;
        check(byCorners == byRouth, 'the two measures differ at $m: $byCorners and $byRouth');
        check(byRouth.compareTo(Frac.zero) >= 0 && byRouth.compareTo(Frac.one) < 0, 'a share out of bounds at $m: $byRouth');
        // The sliver's corners really lie on the cuts they came from.
        final s = Rules.sliver(m);
        check(s != null, 'no sliver at $m');
        final cuts = [
          [Rules.spotOf(Rules.a), Rules.onBC(d)],
          [Rules.spotOf(Rules.b), Rules.onCA(e)],
          [Rules.spotOf(Rules.c), Rules.onAB(f)],
        ];
        for (var i = 0; i < 3; i++) {
          final corner = s![i];
          for (final cut in [cuts[i], cuts[(i + 1) % 3]]) {
            check(Rules.twiceArea(cut[0], cut[1], corner) == Frac.zero, 'a corner off its cut at $m');
          }
        }
        final meets = Rules.cutsMeet(m);
        final vanished = Rules.slivergone(m);
        check(meets == vanished, 'the meeting and the vanishing differ at $m');
        check(meets == (byRouth == Frac.zero), 'the meeting and the share differ at $m');
        if (meets) meet++;
        if (vanished) gone++;
        if (vanished && !meets) sly++;
        if (byRouth == Frac.of(1, 7)) seventh++;
        if (byRouth == Frac.of(1, 70)) seventieth++;
        if (byRouth == Frac.of(1, 210)) twoTenth++;
        if (byRouth == Level.widest) widest++;
        if (byRouth != Frac.zero && byRouth.compareTo(Frac.of(1, 100)) < 0) thin++;
        if (byRouth.compareTo(Frac.of(1, 2)) >= 0) fat++;
        shares.add(byRouth);
        if (most == null || byRouth.compareTo(most) > 0) most = byRouth;
        if (byRouth != Frac.zero && (least == null || byRouth.compareTo(least) < 0)) least = byRouth;
      }
    }
  }
  check(settings == 1331 && agree == 1331, 'settings $settings, agreeing $agree');
  check(meet == 31 && gone == 31 && sly == 0, 'meeting $meet, gone $gone, sly $sly');
  check(seventh == 2 && seventieth == 12 && twoTenth == 12 && widest == 2, 'seventh $seventh, seventieth $seventieth, two-hundred-and-tenth $twoTenth, widest $widest');
  check(thin == 282 && fat == 40 && shares.length == 219, 'thin $thin, fat $fat, shares ${shares.length}');
  check(most == Level.widest && least == Frac.of(1, 74338), 'the widest $most, the thinnest $least');
  check(Rules.shareByRouth([8, 8, 8]) == Frac.of(1, 7) && Rules.shareByRouth([4, 4, 4]) == Frac.of(1, 7), 'the seventh');
  check(Rules.shareByRouth([6, 6, 6]) == Frac.zero && Rules.cutsMeet([6, 6, 6]), 'the middle marks');
  check(Rules.sliver([6, 6, 6])!.every((p) => p == (Frac.of(4), Frac.of(4))), 'the middle meeting: ${Rules.sliver([6, 6, 6])}');
  check(Rules.sliver([8, 8, 8])!.map(Rules.tellSpot).join(' ') == '(12/7, 24/7) (48/7, 12/7) (24/7, 48/7)', 'the seventh\'s corners');
  check(Rules.shareByRouth([1, 1, 1]) == Level.widest && Rules.shareByRouth([11, 11, 11]) == Level.widest, 'the widest settings');
  check(Rules.shareByRouth([4, 7, 7]) == Frac.of(1, 74338), 'the thinnest sliver');

  // The asks.
  for (final lv in Levels.all) {
    var ways = 0;
    for (var d = Rules.least; d <= Rules.most; d++) {
      for (var e = Rules.least; e <= Rules.most; e++) {
        for (var f = Rules.least; f <= Rules.most; f++) {
          if (lv.meets([d, e, f])) ways++;
        }
      }
    }
    check(ways == lv.ways, '${lv.name}: ${lv.ways} said, $ways swept');
    final aim = lv.aim;
    check((aim == null) == !lv.winnable, '${lv.name}: aim $aim');
    if (aim != null) check(lv.meets(aim), '${lv.name}: the aim misses');
    final open = Play.of(lv);
    check(!open.isOver, '${lv.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 40) {
        final (which, by) = play.next!;
        play = play.step(which, by);
        steps++;
      }
      check(play.isDone, '${lv.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim!.join(',') == '4,4,4' && Levels.at(1).aim!.join(',') == '1,6,11' && Levels.at(2).aim!.join(',') == '1,8,8' && Levels.at(3).aim!.join(',') == '1,1,1', 'the aims');
  final dead = Play.of(Levels.at(4)).step(0, 3).step(1, 3).step(2, 3).step(0, -5).step(2, 5).step(0, 1).step(2, -1);
  check(dead.seen.length == 3 && dead.gaveUp, 'the sly vanishing does not admit it after three meetings');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every setting of the three marks taken, ${commas(settings)}, and the sliver measured twice, once by crossing the cuts in exact fractions and taking the area off its three corners and once by Routh\'s rule, the square of xyz less one over (xy + x + 1)(yz + y + 1)(zx + z + 1), the two agreeing on all ${commas(settings)}: every corner of every sliver lies on both the cuts that made it, and no sliver takes the whole field or less than none; the sliver comes to nothing on $gone settings and the three cuts meet on the same $meet, so the sly vanishing never happens; the sliver is a seventh on $seventh settings, the marks 8, 8 and 8 and the marks 4, 4 and 4, a seventieth on $seventieth and a two-hundred-and-tenth on $twoTenth; it is widest at 100 parts in 133 on $widest settings, every mark one twelfth along or every mark eleven, $fat settings leave half the field or more and $thin leave less than a hundredth, the thinnest a 74,338th from the marks 4, 7 and 7, and ${shares.length} different shares come up in all\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final lv = Levels.at(i);
    final tail = lv.winnable
        ? '${lv.ways} of the ${commas(settings)} settings land${lv.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(settings)}, and the corners said so first';
    stdout.writeln(' ${i + 1} ${lv.name.padRight(width)} ${lv.task}: $tail');
  }
}
