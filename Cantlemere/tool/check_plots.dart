import 'dart:io';

import 'package:cantlemere/plot/levels.dart';
import 'package:cantlemere/plot/play.dart';
import 'package:cantlemere/plot/rules.dart';

/// Walks every way of cutting the field into plots with corners on the
/// pegs, counts each cut two ways, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_plots.dart
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

  check(Rules.pegs == 16, 'pegs: ${Rules.pegs}');
  check(Rules.field == 18, 'half acres in the field: ${Rules.field}');
  check(Rules.plots.length == 516, 'plots: ${Rules.plots.length}');
  check(Rules.lines.length == 62, 'lines through two pegs: ${Rules.lines.length}');
  check(Rules.cells == 624, 'cells the lines cut: ${Rules.cells}');

  // The colouring, and the two things Monsky's argument asks of it.
  final census = <int, int>{};
  for (var p = 0; p < Rules.pegs; p++) {
    census[Rules.colour(p)] = (census[Rules.colour(p)] ?? 0) + 1;
  }
  check(census[0] == 4 && census[1] == 8 && census[2] == 4,
      'the colours come out $census');
  check(Rules.rimSteps() == 3, 'steps round the rim: ${Rules.rimSteps()}');
  check(Rules.rimSteps().isOdd, 'the rim steps are not odd');

  var motley = 0, evenMotley = 0;
  for (final plot in Rules.plots) {
    if (!Rules.motley(plot)) continue;
    motley++;
    if (Rules.halves(plot).isEven) evenMotley++;
  }
  check(motley == 128, 'motley plots: $motley');
  check(evenMotley == 0, 'motley plots of an even size: $evenMotley');

  // No line through two pegs carries all three colours, which is what
  // keeps a motley plot's three sides honest.
  var threeColoured = 0;
  for (final (a, b, c) in Rules.lines) {
    final on = <int>{};
    for (var p = 0; p < Rules.pegs; p++) {
      final (x, y) = Rules.peg(p);
      if (a * x + b * y == c) on.add(Rules.colour(p));
    }
    if (on.length == 3) threeColoured++;
  }
  check(threeColoured == 0, 'lines carrying all three colours: $threeColoured');

  // The sweep. Every cut of the field, counted by piece and by how many
  // of its plots are motley.
  final motleyOf = [for (final p in Rules.plots) Rules.motley(p)];
  final sizeOf = [for (final p in Rules.plots) Rules.halves(p)];
  final byCount = <int, int>{};
  final spread = <int, int>{};
  var cuts = 0, evenSpread = 0;
  Rules.walkCuts((laid) {
    cuts++;
    byCount[laid.length] = (byCount[laid.length] ?? 0) + 1;
    var m = 0, total = 0;
    for (var i = 0; i < laid.length; i++) {
      if (motleyOf[laid[i]]) m++;
      total += sizeOf[laid[i]];
    }
    if (total != Rules.field) {
      failed = true;
      stderr.writeln('DISAGREEMENT: a cut came to $total half acres');
    }
    spread[m] = (spread[m] ?? 0) + 1;
    if (m.isEven) evenSpread++;
  });

  check(cuts == 26822326, 'cuts of the field: $cuts');
  check(evenSpread == 0, 'cuts with an even number of motley plots: '
      '$evenSpread');
  check(byCount[2] == 2, 'two-plot cuts: ${byCount[2]}');
  check(byCount[3] == 32, 'three-plot cuts: ${byCount[3]}');
  check(byCount[4] == 272, 'four-plot cuts: ${byCount[4]}');
  check(byCount[5] == 1688, 'five-plot cuts: ${byCount[5]}');
  check(byCount[6] == 8836, 'six-plot cuts: ${byCount[6]}');
  check(byCount[18] == 46456, 'eighteen-plot cuts: ${byCount[18]}');
  check(byCount.keys.length == 17, 'piece counts seen: ${byCount.keys.length}');
  check(spread.keys.every((k) => k.isOdd), 'an even motley count appeared');

  // The other voice on every small cut: no two plots overlapping and the
  // sizes coming to the field. It knows nothing about cells.
  var held = 0;
  Rules.walkCuts((laid) {
    if (Rules.cuts([for (final p in laid) Rules.plots[p]])) held++;
  }, most: 6);
  check(held == 2 + 32 + 272 + 1688 + 8836,
      'the two voices agreed on $held cuts of six or fewer');

  // Every three-plot cut is 3, 6 and 9 half acres with one motley plot,
  // which is the finger proof of the last ask, both halves of it.
  final threes = Rules.cutsOf(3);
  check(threes.length == 32, 'three-plot cuts by the cell walk: '
      '${threes.length}');
  for (final cut in threes) {
    final sizes = [for (final p in cut) sizeOf[p]]..sort();
    check(sizes[0] == 3 && sizes[1] == 6 && sizes[2] == 9,
        'a three-plot cut came out $sizes');
    var m = 0;
    for (final p in cut) {
      if (motleyOf[p]) m++;
    }
    check(m == 1, 'a three-plot cut had $m motley plots');
  }

  // The asks.
  for (final level in Levels.all) {
    final wins = Rules.cutsOf(level.pieces, even: level.even);
    check(wins.length == level.ways,
        '${level.name}: ${wins.length} against ${level.ways}');
    check(!level.meets(const []), '${level.name} is landed on an empty field');
    if (level.winnable) {
      check(level.fewest == level.pieces * 3,
          '${level.name}: ${level.fewest} against ${level.pieces * 3}');
      for (final cut in wins) {
        check(level.meets(cut), '${level.name} does not accept its own cut');
      }
    } else {
      check(level.fewest == null && wins.isEmpty, '${level.name} was landed');
      check(level.shares, '${level.name} does not even divide the field');
    }
  }

  // Six equal plots can be had and three cannot, which is the pair the
  // game is built on.
  check(Rules.cutsOf(6, even: true).length == 68, 'even sixes');
  check(Rules.cutsOf(3, even: true).isEmpty, 'even threes');
  check(Rules.cutsOf(2, even: true).length == 2, 'even twos');
  check(Rules.cutsOf(9, even: true).isEmpty, 'even nines');

  // The pointer lays every ask it can, in the taps it promises.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 40) {
      final peg = play.next;
      check(peg != null, '${level.name} lost its pointer');
      if (peg == null) break;
      play = play.tap(peg);
      steps++;
    }
    check(play.isDone, '${level.name} was never cut');
    check(play.taps == level.fewest,
        '${level.name} in ${play.taps} against ${level.fewest}');
  }

  // The hopeless ask, worn down by six cuts, and the picture it hands
  // back.
  final dead = Levels.all.last;
  check(Play.of(dead).next == null, 'the hopeless ask kept a pointer');
  var stuck = Play.of(dead);
  final corners = [
    [0, 1, 4], [1, 2, 5], [2, 3, 6], [4, 5, 8], [5, 6, 9], [8, 9, 12],
  ];
  for (final trio in corners) {
    final was = stuck;
    for (final peg in trio) {
      stuck = stuck.tap(peg);
    }
    check(stuck.laid.length == was.laid.length + 1,
        'a plot that would not lie down at $trio');
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');
  check(!Play.of(dead).gaveUp, 'it admitted it at once');
  final shown = stuck.asThree;
  check(shown.laid.length == 3, 'the picture it hands back is not three plots');
  check(shown.motley.length == 1, 'the picture has ${shown.motley.length} '
      'motley plots');
  check(shown.sizes.contains(9), 'the picture has no plot of half the field');

  if (failed) {
    stderr.writeln('the field is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every way of cutting the field into plots with their corners on '
        'the pegs walked, all ${commas(cuts)} of them, from the '
        '${commas(byCount[2]!)} cuts into two plots to the '
        '${commas(byCount[18]!)} into eighteen')
    ..write('; the walk lays plots over the ${commas(Rules.cells)} cells that '
        'the ${Rules.lines.length} lines through the pegs cut the field into, '
        'and it works those cells out for itself in exact fractions rather '
        'than being told them')
    ..write('; a second voice, which knows nothing of cells and asks only '
        'that no two plots overlap and that the half acres come to '
        '${Rules.field}, agrees with it on every one of the ${commas(held)} '
        'cuts into six plots or fewer')
    ..write('; each of the ${Rules.pegs} pegs takes a colour from its own two '
        'numbers, ${census[0]} red, ${census[1]} blue and ${census[2]} green, '
        'and no line through two pegs carries all three; of the '
        '${commas(Rules.plots.length)} plots the pegs allow, $motley wear all '
        'three colours and every last one of those is an odd number of half '
        'acres')
    ..write('; the rim steps between red and blue ${Rules.rimSteps()} times, '
        'an odd number, and not one of the ${commas(cuts)} cuts has an even '
        'number of motley plots')
    ..write('; every one of the ${threes.length} cuts into three plots comes '
        'out 3, 6 and 9 half acres with exactly one motley plot, so three '
        'plots of 6 are not to be had, though six of 3 are, '
        '${Rules.cutsOf(6, even: true).length} ways, and two of 9 are, '
        '${Rules.cutsOf(2, even: true).length} ways');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} cuts do it, ${level.fewest} taps of a peg '
            'apiece'
        : 'none at all, and the field says why twice over';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
