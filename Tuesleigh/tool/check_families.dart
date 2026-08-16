import 'dart:io';

import 'package:tuesleigh/family/frac.dart';
import 'package:tuesleigh/family/levels.dart';
import 'package:tuesleigh/family/play.dart';
import 'package:tuesleigh/family/rules.dart';

/// Counts every family out for every tag count on the dial, sets the
/// count against the form, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_families.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  check(Rules.settings == 30, 'settings ${Rules.settings}');
  final half = Frac.of(1, 2);
  for (var k = 1; k <= Rules.most; k++) {
    final byCounting = Rules.chanceByCounting(k), byForm = Rules.chanceByForm(k);
    check(byCounting == byForm, '$k tags: counting $byCounting, form $byForm');
    check(byForm.compareTo(half) < 0, '$k tags: a half or more');
    check(half - byForm == Frac.of(1, 2 * (4 * k - 1)), '$k tags: not a half less one part in twice ${4 * k - 1}');
    check(Rules.chanceToldWhich(k) == half, '$k tags: told which, ${Rules.chanceToldWhich(k)}');
    check(2 * Rules.bothBoys(k) + 1 == Rules.told(k), '$k tags: told and both boys');
    if (k > 1) check(byForm.compareTo(Rules.chanceByForm(k - 1)) > 0, '$k tags: the chance did not rise');
  }
  check(Rules.chanceByForm(1) == Frac.of(1, 3) && Rules.chanceByForm(2) == Frac.of(3, 7) && Rules.chanceByForm(3) == Frac.of(5, 11) && Rules.chanceByForm(5) == Frac.of(9, 19) && Rules.chanceByForm(7) == Frac.of(13, 27) && Rules.chanceByForm(13) == Frac.of(25, 51) && Rules.chanceByForm(30) == Frac.of(59, 119), 'the named chances');
  check(Rules.told(7) == 27 && Rules.bothBoys(7) == 13 && 4 * 7 * 7 == 196 && Rules.told(5) == 19 && Rules.bothBoys(5) == 9, 'the named counts');
  check(Rules.chanceByForm(365) == Frac.of(729, 1459) && half - Rules.chanceByForm(365) == Frac.of(1, 2918), 'a birthday');
  var pastFortyNine = 0;
  for (var k = 1; k <= Rules.most; k++) {
    if (Rules.chanceByForm(k).compareTo(Frac.of(49, 100)) >= 0) pastFortyNine++;
  }
  check(pastFortyNine == 18 && Rules.chanceByForm(12).compareTo(Frac.of(49, 100)) < 0, 'past forty-nine hundredths: $pastFortyNine');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (var k = 1; k <= Rules.most; k++) {
      if (level.meets(k)) n++;
    }
    check(n == level.ways, '${level.name}: ${level.ways} said, $n swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 20) {
        play = play.wind(play.next!);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == 1 && Levels.at(1).aim == 5 && Levels.at(2).aim == 7 && Levels.at(3).aim == 13, 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every family of two children counted out for every tag count from one to ${Rules.most}, each child a boy or a girl under one of k tags and 4k squared families alike, and among those with a boy of the first tag the share with two boys set against the form 2k - 1 in 4k - 1, the two agreeing on all ${Rules.settings}; the chance is a third at one tag, 3/7 at two, 5/11 at three, 9/19 at five, 13/27 at seven, 25/51 at thirteen and 59/119 at thirty, rising with every tag and always a half less one part in twice 4k - 1, never a half; told which child is the tagged boy the chance is a half at every tag count; and 365 tags, a birthday, would give 729/1,459, one part in 2,918 short\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${Rules.settings} tag counts land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${Rules.settings}, and the one family short said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
