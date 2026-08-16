import 'dart:io';

import 'package:ninebury/nine/levels.dart';
import 'package:ninebury/nine/play.dart';
import 'package:ninebury/nine/rules.dart';

/// Roots every number of three digits both ways, adds and multiplies
/// every pair, sweeps the squares and the cubes, and refuses the bake
/// on any disagreement.
///
/// Run with: dart run tool/check_nines.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  // The two voices on every number.
  final byRoot = <int, int>{};
  var longest = 0;
  final longestAt = <int>[];
  for (var n = 0; n <= Rules.most; n++) {
    final byDigits = Rules.rootByDigits(n), byNines = Rules.rootByNines(n);
    check(byDigits == byNines, 'root of $n: digits $byDigits, nines $byNines');
    final chain = Rules.chain(n);
    check(chain.first == n && chain.last <= 9 && chain.every((c) => c >= 0), 'chain of $n: $chain');
    for (var i = 0; i + 1 < chain.length; i++) {
      check(chain[i + 1] == Rules.digitSum(chain[i]), 'chain of $n breaks at $i');
      check(chain[i] > 9, 'chain of $n goes on past a digit');
    }
    final (nines, over) = Rules.cast(n);
    check(nines * 9 + over == n && over < 9, 'cast of $n');
    check(byNines == (n == 0 ? 0 : over == 0 ? 9 : over), 'root of $n against the cast');
    byRoot[byDigits] = (byRoot[byDigits] ?? 0) + 1;
    if (chain.length > longest) {
      longest = chain.length;
      longestAt.clear();
    }
    if (chain.length == longest) longestAt.add(n);
  }
  check(byRoot[0] == 1 && [for (var r = 1; r <= 9; r++) byRoot[r]].every((c) => c == 111), 'numbers by root: $byRoot');
  check(longest == 4 && longestAt.length == 45 && longestAt.first == 199 && Rules.chain(199).join(',') == '199,19,10,1', 'longest chain $longest at $longestAt');

  // Every pair: the root of a sum and of a product.
  var pairs = 0;
  for (var a = 0; a <= Rules.most; a++) {
    final ra = Rules.rootByDigits(a);
    for (var b = 0; b <= Rules.most; b++) {
      final rb = Rules.rootByDigits(b);
      pairs++;
      if (Rules.rootByNines(a + b) != Rules.rootByNines(ra + rb)) check(false, 'root of $a + $b');
      if (Rules.rootByNines(a * b) != Rules.rootByNines(ra * rb)) check(false, 'root of $a times $b');
    }
  }
  check(pairs == 1000000, 'pairs $pairs');

  // The squares and the cubes.
  final squares = [for (var k = 0; k * k <= Rules.most; k++) k * k];
  final cubes = [for (var k = 0; k * k * k <= Rules.most; k++) k * k * k];
  check(squares.length == 32 && cubes.length == 10, 'squares ${squares.length}, cubes ${cubes.length}');
  final squareRoots = squares.map(Rules.rootByDigits).toSet(), cubeRoots = cubes.map(Rules.rootByDigits).toSet();
  check((squareRoots.toList()..sort()).join(',') == '0,1,4,7,9', 'square roots $squareRoots');
  check((cubeRoots.toList()..sort()).join(',') == '0,1,8,9', 'cube roots $cubeRoots');
  for (var n = 0; n <= Rules.most; n++) {
    check(Rules.isSquare(n) == squares.contains(n), 'isSquare $n');
    check(Rules.isCube(n) == cubes.contains(n), 'isCube $n');
  }
  check(squares.where((s) => Rules.rootByDigits(s) == 7).join(',') == '16,25,169,196,484,529,961', 'squares of root 7');
  check(cubes.where((c) => Rules.rootByDigits(c) == 8).join(',') == '8,125,512', 'cubes of root 8');
  check([for (var r = 1; r <= 9; r++) Rules.rootByDigits(r * r)].join(',') == '1,4,9,7,7,9,4,1,9', 'the roots squared');
  check([for (var r = 1; r <= 9; r++) Rules.rootByDigits(r * r * r)].join(',') == '1,8,9,1,8,9,1,8,9', 'the roots cubed');
  check(cubes.skip(1).map(Rules.rootByDigits).join(',') == '1,8,9,1,8,9,1,8,9', 'the cubes\' roots');
  check(Rules.rootByDigits(4) == 4 && Rules.rootByDigits(5) == 5 && Rules.rootByDigits(13) == 4 && Rules.rootByDigits(31) == 4 && Rules.rootByDigits(23) == 5, 'the roots of the square-seven roots');

  // The nine, and the slip.
  var nine = 0, sum9 = 0, sum18 = 0, sum27 = 0, slip = 0;
  for (var n = 0; n <= Rules.most; n++) {
    if (Rules.allDifferent(n) && Rules.rootByDigits(n) == 9) {
      nine++;
      final s = Rules.digitSum(n);
      if (s == 9) sum9++;
      if (s == 18) sum18++;
      if (s == 27) sum27++;
    }
    if (Rules.rootByDigits(n) == 9 && n != Rules.product) slip++;
  }
  check(nine == 84 && sum9 == 42 && sum18 == 42 && sum27 == 0, 'the nine: $nine, $sum9 $sum18 $sum27');
  check(Rules.product == 846 && Rules.rootByDigits(846) == 9 && Rules.rootByDigits(47) == 2 && Rules.rootByDigits(18) == 9 && Rules.rootByDigits(2 * 9) == 9, 'the product');
  check(slip == 110 && Rules.rootByDigits(864) == 9 && Rules.rootByDigits(837) == 9 && Rules.rootByDigits(855) == 9, 'the slips: $slip');
  check(Rules.told(738) == '7 + 3 + 8 = 18, 1 + 8 = 9' && Rules.cast(738) == (82, 0) && Rules.cast(451) == (50, 1) && Rules.rootByDigits(451) == 1, 'the told');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (var k = 0; k <= Rules.most; k++) {
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
      while (!play.isDone && steps < 30) {
        final (which, way) = play.next!;
        play = play.set(which, way);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == 18 && Levels.at(1).aim == 16 && Levels.at(2).aim == 8 && Levels.at(3).aim == 9, 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every number of three digits, 0 to 999, had its digits added down to one and its remainder by nine taken, and the two agree on all ${commas(Rules.most + 1)}; the root of a sum is the root of the roots added and the root of a product the root of the roots multiplied on all ${commas(pairs)} pairs; the roots share the numbers out 111 each from 1 to 9, and nought to 0 alone; the 32 squares to 961 root 0, 1, 4, 7 or 9 and never 2, 3, 5, 6 or 8, seven of them 7, and the ten cubes to 729 root 0, 1, 8 or 9, three of them 8; $nine numbers of three different digits are multiples of nine, and $slip numbers besides 846 pass the nines\' check on 47 times 18, 864 among them; the longest chain of sums runs four numbers, 199 to 19 to 10 to 1, on ${longestAt.length} of the thousand\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(Rules.most + 1)} numbers land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(Rules.most + 1)}, and the nine roots squared said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
