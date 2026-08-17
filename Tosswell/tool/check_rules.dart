import 'dart:io';

import 'package:tosswell/toss/levels.dart';
import 'package:tosswell/toss/play.dart';
import 'package:tosswell/toss/rules.dart';

/// Walks every rule for walking away over all 32 runs of the coin,
/// folds the standings backward as well, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_rules.dart
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

  final standings = Rules.standings();
  check(standings.length == 15, 'standings: ${standings.length}');
  check(Rules.runs == 32, 'runs: ${Rules.runs}');

  /// The second voice: the purse added over every run that passes
  /// through a standing, folded backward from the last row. It walks no
  /// runs; it averages the two tosses out of each standing.
  int folded(Set<String> stop, int toss, int purse) {
    if (toss == Rules.tosses || stop.contains(Rules.mark((toss, purse)))) {
      return purse * (1 << (Rules.tosses - toss));
    }
    return folded(stop, toss + 1, purse + 1) + folded(stop, toss + 1, purse - 1);
  }

  var markings = 0;
  final best = <String, (int, Set<String>)>{};
  final ways = <String, int>{for (final level in Levels.all) level.name: 0};
  final cheapest = <String, int>{};
  var mostAhead = 0;
  for (var mask = 0; mask < 1 << standings.length; mask++) {
    markings++;
    final stop = <String>{
      for (var i = 0; i < standings.length; i++)
        if (mask >> i & 1 == 1) Rules.mark(standings[i]),
    };
    final ends = Rules.ends(stop);
    // The first voice, walked, against the second, folded.
    check(Rules.added(ends) == folded(stop, 0, 0),
        'a rule walked ${Rules.added(ends)} and folded ${folded(stop, 0, 0)}');
    check(Rules.added(ends) == 0,
        'a rule averaged ${Rules.added(ends)} over the ${Rules.runs} runs');
    // And every standing is worth just what it holds, folded.
    for (final at in standings) {
      check(folded(stop, at.$1, at.$2) == at.$2 * (1 << (Rules.tosses - at.$1)),
          'the standing $at folds to ${folded(stop, at.$1, at.$2)}');
    }
    final key = ends.join(',');
    final marks = stop.length;
    if (!best.containsKey(key) || marks < best[key]!.$1) {
      best[key] = (marks, stop);
    }
    if (Rules.aheadIn(ends) > mostAhead) mostAhead = Rules.aheadIn(ends);
  }
  check(markings == 32768, 'markings swept: $markings');
  check(best.length == 802, 'rules that differ: ${best.length}');
  check(mostAhead == 22, 'the most a rule is ahead: $mostAhead');

  final byMarks = <int, int>{};
  for (final rule in best.values) {
    byMarks[rule.$1] = (byMarks[rule.$1] ?? 0) + 1;
    for (final level in Levels.all) {
      if (!level.meets(rule.$2)) continue;
      ways[level.name] = ways[level.name]! + 1;
      final held = cheapest[level.name];
      if (held == null || rule.$1 < held) cheapest[level.name] = rule.$1;
    }
  }
  check(byMarks[0] == 1 && byMarks[7] == 5, 'the marks spread: $byMarks');

  // The asks.
  for (final level in Levels.all) {
    check(ways[level.name] == level.ways,
        '${level.name}: ${ways[level.name]} against ${level.ways}');
    if (level.winnable) {
      check(level.meets(level.aimMarks), '${level.name}: the aim misses');
      check(level.fewest == cheapest[level.name],
          '${level.name}: the aim takes ${level.fewest}, cheapest '
          '${cheapest[level.name]}');
    } else {
      check(level.aim == null && ways[level.name] == 0,
          '${level.name} was landed');
    }
    check(!level.meets(const <String>{}),
        '${level.name} is landed before a mark is made');
  }

  // The pointer lands every ask it can, in the fewest marks.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    check(play.toGo!.$1 == level.fewest,
        '${level.name}: ${play.toGo!.$1} marks against ${level.fewest}');
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final at = play.next;
      check(at != null, '${level.name} lost its pointer');
      if (at == null) break;
      play = play.tap(at);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  // The hopeless ask, on every rule there is.
  for (final rule in best.values) {
    final ends = Rules.ends(rule.$2);
    check(!(Rules.worstIn(ends) >= 0 && Rules.bestIn(ends) > 0),
        'a rule that never walks away behind and sometimes ahead');
  }
  // Marks made deep in the lattice, where nothing above has cut them
  // off, so each one really is a new rule.
  var stuck = Play.of(Levels.all.last);
  for (final at in [(4, 4), (4, 2), (4, 0), (4, -2)]) {
    stuck = stuck.tap(at);
  }
  check(stuck.moves == 4, 'the hopeless walk made ${stuck.moves} marks');
  check(stuck.gaveUp, 'the hopeless ask did not admit it');

  if (failed) {
    stderr.writeln('the wager is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every rule for walking away taken, all '
        '${commas(markings)} ways the ${standings.length} standings can be '
        'marked, which come to ${commas(best.length)} rules that differ in '
        'what they do, and each one worked twice: once by walking all '
        '${Rules.runs} runs of the coin and adding up what they walk away '
        'with, and once by folding the standings backward from the last row, '
        'averaging the two tosses out of each one, which walks no runs at '
        'all')
    ..write('; the two agree on every marking, and every one of them averages '
        'nothing over the ${Rules.runs} runs, so no rule for leaving a fair '
        'game changes what it is worth')
    ..write('; more than that, every standing folds to exactly what it holds, '
        'on every marking there is, which is the theorem itself')
    ..write('; what a rule can change is the shape: the most any of them is '
        'ahead is $mostAhead runs of the ${Rules.runs}, eleven in sixteen, '
        'and no rule is ever ahead on more')
    ..write('; the rules take ')
    ..write([
      for (final marks in byMarks.keys.toList()..sort())
        '${byMarks[marks]} at $marks'
    ].join(', '))
    ..write(' marks, the one with none being the rule that rides every run to '
        'the last toss')
    ..write('; and not one of the ${commas(best.length)} walks away level or '
        'better on every run while walking away ahead on some, which is what '
        'averaging nothing forbids');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(best.length)} rules '
            '${level.ways == 1 ? 'lands' : 'land'} it, the cheapest in '
            '${level.fewest} ${level.fewest == 1 ? 'mark' : 'marks'}'
        : 'none of the ${commas(best.length)}, and the averaging says why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
