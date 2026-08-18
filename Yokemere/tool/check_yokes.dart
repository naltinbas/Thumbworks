import 'dart:io';

import 'package:yokemere/yoke/levels.dart';
import 'package:yokemere/yoke/play.dart';
import 'package:yokemere/yoke/rules.dart';

/// Tries every yoking of the two rows, reads the hardest and softest
/// pulls off them, gets the same two by sorting instead, and refuses the
/// bake on any disagreement.
///
/// Run with: dart run tool/check_yokes.dart
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

  final all = Rules.yokings();
  check(all.length == 120, 'yokings of five: ${all.length}');
  check(all.map((y) => y.join()).toSet().length == all.length,
      'the walk wrote a yoking twice');

  // The first voice: try them all and read the pulls off.
  final spread = <int, int>{};
  var hardest = 0, softest = 1 << 30;
  for (final y in all) {
    final p = Rules.pull(y);
    spread[p] = (spread[p] ?? 0) + 1;
    if (p > hardest) hardest = p;
    if (p < softest) softest = p;
  }
  // The second voice yokes nobody: sort the rows and multiply.
  check(hardest == Rules.hardest(),
      'the hardest pull: $hardest against ${Rules.hardest()}');
  check(softest == Rules.softest(),
      'the softest pull: $softest against ${Rules.softest()}');
  check(hardest == 55, 'the hardest pull came to $hardest');
  check(softest == 35, 'the softest pull came to $softest');

  // The swap that carries the proof: a crossed pair swapped never
  // softens the team, and an uncrossed pair swapped never hardens it.
  var crossedTried = 0, uncrossedTried = 0;
  for (final y in all) {
    for (var i = 0; i < Rules.oxen; i++) {
      for (var j = i + 1; j < Rules.oxen; j++) {
        final gain = Rules.swapGain(y, i, j);
        final after = Rules.pull(Rules.swap(y, i, j));
        check(after - Rules.pull(y) == gain,
            'the gain from swapping $i and $j on $y was worked out wrong');
        if (Rules.crossed(y, i, j)) {
          crossedTried++;
          check(gain >= 0, 'swapping a crossed pair softened the team');
        } else {
          uncrossedTried++;
          check(gain <= 0, 'swapping an uncrossed pair hardened the team');
        }
      }
    }
  }
  check(crossedTried + uncrossedTried == all.length * 10,
      'pairs looked at: ${crossedTried + uncrossedTried}');

  // Only one yoking has no crossed pair anywhere, and it is the one that
  // pulls hardest.
  final tidy = [
    for (final y in all)
      if (!Play.yoked(Levels.at(0), y).anyCrossed) y,
  ];
  check(tidy.length == 1, 'yokings with nothing crossed: ${tidy.length}');
  check(Rules.pull(tidy.single) == hardest,
      'the uncrossed yoking pulls ${Rules.pull(tidy.single)}');

  // Working the crossings out one at a time walks up to that yoking and
  // never walks back, from every one of the 120.
  for (final y in all) {
    var here = [...y];
    var steps = 0;
    while (steps < 20) {
      var moved = false;
      for (var i = 0; i < Rules.oxen && !moved; i++) {
        for (var j = i + 1; j < Rules.oxen && !moved; j++) {
          if (!Rules.crossed(here, i, j)) continue;
          final was = Rules.pull(here);
          here = Rules.swap(here, i, j);
          check(Rules.pull(here) >= was, 'a crossing swap softened the team');
          moved = true;
        }
      }
      if (!moved) break;
      steps++;
    }
    check(Rules.pull(here) == hardest,
        'working the crossings out of $y stopped at ${Rules.pull(here)}');
  }

  // The theorem again on rows the game does not ship, so the agreement
  // is not one lucky pair of rows.
  var sets = 0, badHard = 0, badSoft = 0;
  final choices = <List<int>>[];
  void pick(int from, List<int> so) {
    if (so.length == Rules.oxen) {
      choices.add([...so]);
      return;
    }
    for (var v = from; v <= 9; v++) {
      pick(v + 1, [...so, v]);
    }
  }

  pick(1, const []);
  check(choices.length == 126, 'rows of five from nine: ${choices.length}');
  for (final a in choices) {
    for (final b in choices) {
      sets++;
      var best = 0, worst = 1 << 30;
      for (final y in all) {
        var total = 0;
        for (var i = 0; i < Rules.oxen; i++) {
          total += a[i] * b[y[i]];
        }
        if (total > best) best = total;
        if (total < worst) worst = total;
      }
      var together = 0, opposite = 0;
      for (var i = 0; i < Rules.oxen; i++) {
        together += a[i] * b[i];
        opposite += a[i] * b[Rules.oxen - 1 - i];
      }
      if (best != together) badHard++;
      if (worst != opposite) badSoft++;
    }
  }
  check(sets == 15876, 'pairs of rows swept: $sets');
  check(badHard == 0, 'rows where sorting together was not hardest: $badHard');
  check(badSoft == 0, 'rows where sorting opposite was not softest: $badSoft');

  // The asks.
  for (final level in Levels.all) {
    final ok = [for (final y in all) if (level.meets(y)) y];
    check(ok.length == level.ways,
        '${level.name}: ${ok.length} against ${level.ways}');
    check(!level.meets(Rules.opening),
        '${level.name} is landed before a swap');
    if (level.winnable) {
      var cheapest = Rules.oxen;
      for (final y in ok) {
        final n = Rules.between(Rules.opening, y);
        if (n < cheapest) cheapest = n;
      }
      check(level.fewest == cheapest,
          '${level.name}: ${level.fewest} against $cheapest');
      check(level.pull <= hardest,
          '${level.name} asks past the hardest pull and is called winnable');
    } else {
      check(level.fewest == null && ok.isEmpty, '${level.name} was landed');
      check(level.pull > hardest,
          '${level.name} is hopeless for some other reason than the pull');
    }
  }
  check(Rules.pull(Rules.opening) == softest,
      'the opening pulls ${Rules.pull(Rules.opening)}');

  // The pointer lands every ask it can, in the swaps it promises.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 12) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.tap(aim.$1).tap(aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} was never yoked');
    check(play.swaps == level.fewest,
        '${level.name} in ${play.swaps} against ${level.fewest}');
  }

  // The hopeless ask, worn down by six teams.
  final dead = Levels.all.last;
  check(Play.of(dead).next == null, 'the hopeless ask kept a pointer');
  var stuck = Play.of(dead);
  for (final pair in [(0, 1), (1, 2), (2, 3), (3, 4), (0, 4), (0, 2)]) {
    final was = stuck;
    stuck = stuck.tap(pair.$1).tap(pair.$2);
    check(stuck.mark != was.mark, 'a swap that changed nothing at $pair');
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');
  check(!Play.of(dead).gaveUp, 'it admitted it at once');

  if (failed) {
    stderr.writeln('the yard is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every yoking of the two rows tried, all ${all.length} of them, '
        'each near ox against the off ox yoked to it and the products '
        'added: the pulls run from $softest to $hardest')
    ..write('; a second voice yokes nobody and gets the same two ends by '
        'sorting the rows and multiplying place by place, together for the '
        'hardest and opposite ways for the softest, and it agrees')
    ..write('; the swap that carries the proof was tried on every pair of '
        'every yoking, ${commas(crossedTried + uncrossedTried)} of them: the '
        'change in the pull came to the near gap multiplied by the off gap '
        'every time, never a loss when the pair was crossed and never a gain '
        'when it was not')
    ..write('; exactly one yoking of the ${all.length} has no crossed pair '
        'anywhere and it is the one that pulls $hardest, and working the '
        'crossings out one at a time walks every one of the ${all.length} up '
        'to it without ever walking back')
    ..write('; the same was asked of ${commas(sets)} other pairs of rows, '
        'every five beasts of nine against every five of nine, '
        '${commas(sets * all.length)} yokings in all, and sorting together '
        'was hardest on every one and sorting opposite softest on every one')
    ..write('; the team starts turned back to front, which pulls $softest, '
        'and the asks want '
        '${Levels.all.map((l) => l.pull).join(', ')}');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${all.length} yokings do it, the nearest '
            '${level.fewest} ${level.fewest == 1 ? 'swap' : 'swaps'} away'
        : 'none of the ${all.length}, and the crossings said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
