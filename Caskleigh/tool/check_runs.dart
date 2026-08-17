import 'dart:io';

import 'package:caskleigh/cask/frac.dart';
import 'package:caskleigh/cask/levels.dart';
import 'package:caskleigh/cask/play.dart';
import 'package:caskleigh/cask/rules.dart';

/// Pours every run of casks the cellar allows, adds it two ways, counts
/// the twos, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_runs.dart
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

  var runs = 0, whole = 0, evenBottom = 0, oneDeepest = 0;
  final ways = <String, int>{for (final level in Levels.all) level.name: 0};
  final cheapest = <String, int>{};
  for (final (first, last) in Rules.runs()) {
    runs++;
    final byCask = Rules.total(first, last);
    final byCommon = Rules.totalByCommon(first, last);
    check(byCask == byCommon,
        'the run ${Rules.tellRun(first, last)}: $byCask cask by cask, '
        '$byCommon over a common bottom');
    if (byCask.isWhole) whole++;
    if (byCask.d.isEven) evenBottom++;
    // Exactly one cask of the run has the most twos in it.
    final deepest = Rules.deepest(first, last);
    if (deepest.length == 1) oneDeepest++;
    check(deepest.length == 1,
        'the run ${Rules.tellRun(first, last)} has ${deepest.length} deepest '
        'casks');
    // And that is what makes the bottom even.
    check(byCask.d.isEven,
        'the run ${Rules.tellRun(first, last)} came out over an odd bottom');
    // The argument is made before anything cancels: over the smallest
    // common bottom the top comes out odd and the bottom even.
    final bottom = Rules.commonBottom(first, last);
    final top = Rules.commonTop(first, last);
    check(Frac(top, bottom) == byCask,
        'the run ${Rules.tellRun(first, last)}: $top over $bottom against $byCask');
    check(bottom.isEven && top.isOdd,
        'the run ${Rules.tellRun(first, last)}: $top over $bottom');
    for (var k = first; k <= last; k++) {
      final goes = bottom ~/ BigInt.from(k);
      check(bottom % BigInt.from(k) == BigInt.zero,
          'cask $k does not divide the common bottom of '
          '${Rules.tellRun(first, last)}');
      check(goes.isOdd == (k == deepest.first),
          'cask $k goes into the common bottom of '
          '${Rules.tellRun(first, last)} $goes times');
    }
    for (final level in Levels.all) {
      if (!level.meets(first, last)) continue;
      ways[level.name] = ways[level.name]! + 1;
      final taps = Rules.taps(first, last);
      final held = cheapest[level.name];
      if (held == null || taps < held) cheapest[level.name] = taps;
    }
  }
  check(runs == Rules.howManyRuns && runs == 1770, 'runs poured: $runs');
  check(whole == 0, 'runs coming to a whole barrel: $whole');
  check(evenBottom == runs && oneDeepest == runs, 'the twos');

  // The single-cask runs are whole only at the first cask, which is why
  // the game asks for runs of two casks or more.
  check(Frac.of(1, 1).isWhole && !Frac.of(1, 2).isWhole, 'a single cask');

  // The asks.
  for (final level in Levels.all) {
    check(ways[level.name] == level.ways,
        '${level.name}: ${ways[level.name]} against ${level.ways}');
    if (level.winnable) {
      final aim = level.aim!;
      check(level.meets(aim.$1, aim.$2), '${level.name}: the aim misses');
      check(Rules.taps(aim.$1, aim.$2) == cheapest[level.name],
          '${level.name}: the aim takes ${Rules.taps(aim.$1, aim.$2)}, '
          'cheapest ${cheapest[level.name]}');
    } else {
      check(level.aim == null && ways[level.name] == 0,
          '${level.name} was landed');
    }
  }

  // The pointer lands every ask it can, in the fewest taps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 40) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = aim.$1 == 'first' ? play.stepFirst(aim.$2) : play.stepLast(aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  if (failed) {
    stderr.writeln('the cellar is not sound; no bake');
    exit(1);
  }

  final shortest = <int, (int, int)>{};
  for (final mark in [1, 2, 3]) {
    for (final (first, last) in Rules.runs()) {
      if (Rules.total(first, last) <= Frac.of(mark)) continue;
      final held = shortest[mark];
      if (held == null || last - first < held.$2 - held.$1) {
        shortest[mark] = (first, last);
      }
    }
  }

  // How far a run has to reach to pass each mark, from the first cask
  // and from the second.
  int reach(int from, int mark) {
    var last = from + 1;
    while (Rules.total(from, last) <= Frac.of(mark)) {
      last++;
    }
    return last;
  }

  final fromFirst = [for (final mark in [1, 2, 3, 4]) reach(1, mark)];
  final fromSecond = [for (final mark in [1, 2]) reach(2, mark)];
  check(fromFirst.join(',') == '2,4,11,31', 'the reach from the first: $fromFirst');
  check(fromSecond.join(',') == '4,11', 'the reach from the second: $fromSecond');

  final ledger = StringBuffer()
    ..write('every run of casks the cellar allows taken, from a first cask to '
        'a last with at least two of them, ${commas(runs)} runs over the '
        '${Rules.most} casks, and each added twice, once cask by cask in '
        'exact fractions and once over the smallest common bottom in whole '
        'numbers alone: the two agree on every run')
    ..write('; over the smallest common bottom, before anything cancels, '
        'the deepest cask goes in an odd number of times and every other '
        'cask an even number, so the top comes out odd and the bottom even '
        'on all ${commas(runs)} runs: the first six casks go over 60, coming '
        'to 147, which is the 49/20 the board reduces it to')
    ..write('; not one of the ${commas(runs)} comes to a whole barrel, and '
        'the reason is on the board: every run has exactly one cask with more '
        'twos in its number than any other, ${commas(oneDeepest)} runs out of '
        '${commas(runs)}, and every total lands over an even bottom, '
        '${commas(evenBottom)} out of ${commas(runs)}')
    ..write('; the shortest runs past the marks are ')
    ..write([
      for (final mark in [1, 2, 3])
        '${Rules.tellRun(shortest[mark]!.$1, shortest[mark]!.$2)} for $mark, '
            'coming to ${Rules.total(shortest[mark]!.$1, shortest[mark]!.$2)}'
    ].join(', '))
    ..write('; a run from the first cask has to reach the '
        '${Rules.ordinal(fromFirst[0])} to pass a barrel, the '
        '${Rules.ordinal(fromFirst[1])} to pass two, the '
        '${Rules.ordinal(fromFirst[2])} to pass three and the '
        '${Rules.ordinal(fromFirst[3])} to pass four, and one starting at the '
        'second cask has to reach the ${Rules.ordinal(fromSecond[0])} and the '
        '${Rules.ordinal(fromSecond[1])}')
    ..write('; and one run alone comes out in halves exactly, the first two '
        'casks at 3/2');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(runs)} runs '
            '${level.ways == 1 ? 'lands' : 'land'} it, the cheapest in '
            '${level.fewest} ${level.fewest == 1 ? 'tap' : 'taps'}'
        : 'none of the ${commas(runs)}, and the twos say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
