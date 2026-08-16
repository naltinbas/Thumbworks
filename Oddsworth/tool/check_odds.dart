import 'dart:io';

import 'package:oddsworth/odd/levels.dart';
import 'package:oddsworth/odd/play.dart';
import 'package:oddsworth/odd/rules.dart';

/// Adds out every run of consecutive odd numbers on the dials, sets the
/// sum against the difference of squares, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_odds.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  check(Rules.settings == 1000, 'settings ${Rules.settings}');
  final sums = <int>{};
  for (var first = 1; first <= Rules.firstMost; first += 2) {
    for (var count = 1; count <= Rules.countMost; count++) {
      final byAdding = Rules.sumByAdding(first, count), bySquares = Rules.sumBySquares(first, count);
      check(byAdding == bySquares, 'run from $first, $count long: added $byAdding, squares $bySquares');
      check(byAdding % 4 != 2, 'run from $first, $count long adds to $byAdding, two past a multiple of four');
      check(count.isOdd ? byAdding.isOdd : byAdding % 4 == 0, 'run from $first, $count long: $byAdding against its count');
      if (first == 1) check(byAdding == count * count, 'run from 1, $count long, is not $count squared');
      final run = Rules.run(first, count);
      check(run.length == count && run.every((o) => o.isOdd) && run.first == first && (count == 1 || run[1] == first + 2), 'the run from $first, $count long');
      check(Rules.outer(first, count) == Rules.inner(first) + count && 2 * Rules.inner(first) + 1 == first, 'the squares of $first, $count');
      sums.add(byAdding);
    }
  }
  check(sums.length == 653, 'different sums ${sums.length}');
  final noRun = [for (var n = 1; n <= 100; n++) if (Rules.runsTo(n).isEmpty) n];
  check(noRun.join(',') == [for (var n = 2; n <= 100; n += 4) n].join(','), 'numbers to a hundred with no run: $noRun');
  check(Rules.runsTo(49).join(',') == '(49, 1),(1, 7)' && Rules.runsTo(21).join(',') == '(21, 1),(5, 3)' && Rules.runsTo(64).join(',') == '(31, 2),(13, 4),(1, 8)' && Rules.runsTo(100).join(',') == '(49, 2),(1, 10)' && Rules.runsTo(30).isEmpty, 'the named runs');
  check(Rules.runsTo(45).length == 3 && Rules.runsTo(48).length == 3 && Rules.runsTo(72).length == 3 && Rules.runsTo(80).length == 3 && Rules.runsTo(96).length == 4, 'the runs of 45, 48, 72, 80 and 96');
  var most = 0;
  final mostAt = <int>[];
  for (var n = 1; n <= 100; n++) {
    final w = Rules.runsTo(n).length;
    if (w > most) {
      most = w;
      mostAt.clear();
    }
    if (w == most) mostAt.add(n);
  }
  check(most == 4 && mostAt.join(',') == '96', 'most runs to a hundred: $most at $mostAt');
  check([for (var f = 1; f <= 9; f += 2) Rules.sumBySquares(f, 4)].join(',') == '16,24,32,40,48' && [for (var f = 1; f <= 9; f += 2) Rules.sumBySquares(f, 5)].join(',') == '25,35,45,55,65', 'runs of four and five');
  check(Rules.told(5, 3) == '5 + 7 + 9' && Rules.inner(5) == 2 && Rules.outer(5, 3) == 5 && Rules.inner(21) == 10 && Rules.outer(21, 1) == 11 && Rules.outer(49, 2) == 26 && Rules.inner(49) == 24, 'the named squares');
  check(Rules.runsTo(28).join(',') == '(13, 2)' && Rules.runsTo(32).join(',') == '(15, 2),(5, 4)', 'twenty-eight and thirty-two');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (var first = 1; first <= Rules.firstMost; first += 2) {
      for (var count = 1; count <= Rules.countMost; count++) {
        if (level.meets(first, count)) n++;
      }
    }
    check(n == level.ways, '${level.name}: ${level.ways} said, $n swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim.$1, aim.$2), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 40) {
        final (which, way) = play.next!;
        play = play.set(which, way);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == (1, 7) && Levels.at(1).aim == (5, 3) && Levels.at(2).aim == (1, 8) && Levels.at(3).aim == (1, 10), 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every run of consecutive odd numbers on the dials added out, the first odd number 1 to 99 and the count 1 to 20, ${_commas(Rules.settings)} runs, and each sum set against the outer square less the inner, the outer\'s side the inner\'s and the count together, the two agreeing on all ${_commas(Rules.settings)}; every run from 1 adds to its count squared, an odd count adds to an odd number and an even count to a multiple of four, and no run adds to a number two past a multiple of four, the twenty-five such numbers to a hundred, 2, 6, 10 and on to 98, being exactly the numbers to a hundred with no run; 49 is 1 to 13 or 49 alone, 21 is 5 + 7 + 9 or 21 alone, 64 is 31 + 33, 13 to 19 or 1 to 15, a hundred is 1 to 19 or 49 + 51, 45, 48, 72 and 80 have three runs each and 96 four, the most to a hundred, and thirty has none, though 28 is 13 + 15 and 32 is 15 + 17 or 5 to 11\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${_commas(Rules.settings)} runs land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${_commas(Rules.settings)}, and the pairs of odd numbers said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
