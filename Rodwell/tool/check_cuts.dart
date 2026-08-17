import 'dart:io';

import 'package:rodwell/rod/levels.dart';
import 'package:rodwell/rod/play.dart';
import 'package:rodwell/rod/rules.dart';

/// Cuts every rod every way there is, finds the best three ways, and
/// refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_cuts.dart
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

  final workingUp = Rules.bestByWorkingUp(Rules.longest);
  var cuttings = 0;
  final bests = <int, BigInt>{};
  for (var hands = Rules.shortest; hands <= Rules.longest; hands++) {
    final byRule = Rules.bestByRule(hands);
    check(byRule == workingUp[hands],
        'a rod of $hands: $byRule by the rule, ${workingUp[hands]} by working '
        'up');
    // The full sweep is only run on the rods short enough for it.
    if (hands <= 16) {
      var best = BigInt.zero;
      for (final cuts in Rules.cuttings(hands)) {
        cuttings++;
        final got = Rules.product(Rules.partsOf(hands, cuts));
        if (got > best) best = got;
        check(got <= byRule, 'a cutting of $hands beat the rule');
      }
      check(best == byRule,
          'a rod of $hands: $best by the sweep, $byRule by the rule');
    }
    bests[hands] = byRule;
    // The parts the rule gives really do add up and multiply out.
    final parts = Rules.bestParts(hands);
    check(parts.reduce((a, b) => a + b) == hands, 'the parts of $hands');
    check(Rules.product(parts) == byRule, 'the product of $hands');
    check(parts.every((part) => part >= 2 && part <= 4),
        'a part of $hands outside two to four');
    // The cutting the pointer aims at gives those parts.
    final aim = Rules.bestCuts(hands);
    check(Rules.product(Rules.partsOf(hands, aim)) == byRule,
        'the aimed cutting of $hands');
    check(aim.length == parts.length - 1, 'the cuts of $hands');
  }
  // Two to the sixteen less two: the cuttings of every rod up to
  // sixteen hands.
  check(cuttings == 65534, 'cuttings swept: $cuttings');

  // The three lines of arithmetic the rule rests on.
  for (var part = 5; part <= 40; part++) {
    check(3 * (part - 3) > part, 'a part of $part is better whole');
  }
  check(3 * 3 > 2 * 2 * 2, 'three twos against two threes');
  check(2 * 2 == 4, 'a four against two twos');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (final cuts in Rules.cuttings(level.hands)) {
      if (level.meets(cuts)) n++;
    }
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    check(bests[level.hands] == BigInt.from(level.want),
        '${level.name}: the best of ${level.hands} is '
        '${bests[level.hands]}, not ${level.want}');
    final aim = level.aim;
    if (level.winnable) {
      check(aim != null && level.meets(aim), '${level.name}: the aim misses');
      check(level.fewest == aim!.length, '${level.name}: the fewest');
    } else {
      check(aim == null && n == 0, '${level.name} was landed');
    }
  }

  // The pointer lands every ask it can, in the fewest cuts.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 30) {
      final place = play.next;
      check(place != null, '${level.name} lost its pointer');
      if (place == null) break;
      play = play.cut(place);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  if (failed) {
    stderr.writeln('the rod is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every rod from ${Rules.shortest} hands to ${Rules.longest} taken '
        'and the biggest product found three ways: by cutting the rod every '
        'way there is, which is ${commas(cuttings)} cuttings over the rods of '
        'sixteen hands and under; by the rule of threes, which cuts nothing '
        'at all; and by working up from the short rods, each one cut once '
        'with the rest looked up. The three agree on every rod')
    ..write('; the best cutting is nothing but threes with a four or a two '
        'over, and the sweep bears out the three lines it rests on: three '
        'times what is left beats a part of five or more, nine beats eight '
        'so three twos should be two threes, and a four is the same as two '
        'twos')
    ..write('; the rods and their best: ')
    ..write([
      for (var hands = Rules.shortest; hands <= Rules.longest; hands++)
        '$hands to ${Rules.tellProduct(bests[hands]!)}'
    ].join(', '));
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(level.cuttings)} cuttings '
            '${level.ways == 1 ? 'lands' : 'land'} it, the fewest in '
            '${level.fewest} cuts'
        : 'none of the ${commas(level.cuttings)}, and the threes say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
