import 'dart:io';

import 'package:squarewell/square/levels.dart';
import 'package:squarewell/square/play.dart';
import 'package:squarewell/square/rules.dart';

/// Squares every base on every prime clock to a hundred, sets Euler's
/// test against the squares, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_squares.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  // The two voices on every prime clock to a hundred.
  var primes = 0, hours = 0;
  final minusOneClocks = <int>[], twoClocks = <int>[];
  for (var p = 3; p <= 100; p++) {
    if (!Rules.isPrime(p)) continue;
    primes++;
    final byBases = Rules.squaresByBases(p), byEuler = Rules.squaresByEuler(p);
    check(byBases.length == byEuler.length && byBases.containsAll(byEuler), 'squares on $p: bases $byBases, Euler $byEuler');
    check(byBases.length == (p - 1) ~/ 2, 'squares on $p: ${byBases.length}, not half of ${p - 1}');
    for (var h = 1; h < p; h++) {
      hours++;
      final e = Rules.powMod(h, (p - 1) ~/ 2, p);
      check(e == 1 || e == p - 1, 'Euler\'s power of $h on $p is $e');
      // A base and its opposite square to the same hour, and no other base
      // does.
      final roots = Rules.rootsOf(h, p);
      check(roots.isEmpty || (roots.length == 2 && roots[0] + roots[1] == p), 'roots of $h on $p: $roots');
      check(roots.isNotEmpty == byBases.contains(h), 'roots and squares disagree at $h on $p');
    }
    if (byBases.contains(p - 1)) minusOneClocks.add(p);
    if (byBases.contains(2 % p)) twoClocks.add(p);
    check(byBases.contains(p - 1) == (p % 4 == 1), 'minus one on $p');
    check(byBases.contains(2 % p) == (p % 8 == 1 || p % 8 == 7), 'two on $p');
  }
  check(primes == 24, 'primes to a hundred: $primes');
  check(hours == 1034, 'hours squared: $hours');
  check(minusOneClocks.take(4).join(',') == '5,13,17,29' && twoClocks.take(4).join(',') == '7,17,23,31', 'the first clocks: $minusOneClocks, $twoClocks');
  check(minusOneClocks.length == 11 && twoClocks.length == 11, 'clocks with minus one a square: ${minusOneClocks.length}, with two: ${twoClocks.length}');

  // The dials.
  check(Rules.clocks.join(',') == '3,5,7,11,13,17,19,23' && Rules.settings == 90, 'the dials');
  check(Rules.told(Rules.squaresByBases(7)) == '1, 2 and 4' && Rules.told(Rules.squaresByBases(11)) == '1, 3, 4, 5 and 9', 'the squares on seven and eleven');
  check(Rules.rootsOf(2, 7).join(',') == '3,4' && Rules.rootsOf(4, 7).join(',') == '2,5' && Rules.rootsOf(1, 7).join(',') == '1,6', 'the roots on seven');
  check(Rules.rootsOf(2, 11).isEmpty && Rules.powMod(2, 5, 11) == 10 && Rules.powMod(2, 3, 7) == 1 && Rules.powMod(3, 3, 7) == 6, 'the named powers');
  check(Rules.rootsOf(4, 5).join(',') == '2,3' && Rules.rootsOf(12, 13).join(',') == '5,8' && Rules.rootsOf(16, 17).join(',') == '4,13', 'the roots of minus one');
  check(Rules.rootsOf(2, 17).join(',') == '6,11' && Rules.rootsOf(2, 23).join(',') == '5,18', 'the roots of two');
  check([for (var h = 1; h < 7; h++) if (!Rules.squaresByBases(7).contains(h)) h].join(',') == '3,5,6', 'the non-squares on seven');
  check([for (var h = 1; h < 11; h++) if (!Rules.squaresByBases(11).contains(h)) h].join(',') == '2,6,7,8,10', 'the non-squares on eleven');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (final p in Rules.clocks) {
      for (var b = 1; b < p; b++) {
        if (level.meets(p, b)) n++;
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
      while (!play.isDone && steps < 30) {
        final (which, way) = play.next!;
        play = play.set(which, way);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == (7, 3) && Levels.at(1).aim == (7, 3) && Levels.at(2).aim == (5, 2) && Levels.at(3).aim == (7, 3), 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every base on every prime clock to a hundred squared, $primes clocks and ${_commas(hours)} hours, and Euler\'s test set against the squares hour by hour, the two agreeing on every hour, the test\'s power coming to 1 or one short of the clock and never anything else, and the squares making exactly half the hours but 0 on every clock, each square reached by a base and its opposite and by no other; one short of the clock is a square on exactly the clocks one more than a multiple of four, ${minusOneClocks.length} of the $primes, 5, 13, 17 and 29 first, and two on exactly the clocks one more or one less than a multiple of eight, ${twoClocks.length} of the $primes, 7, 17, 23 and 31 first; on the dials, the eight prime clocks from three to twenty-three, ${Rules.settings} settings, seven has the squares 1, 2 and 4, with 3 and 4 squaring to 2, and eleven the squares 1, 3, 4, 5 and 9, with 2 nobody\'s square\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final what = level.locked ? 'bases' : 'settings';
    final tail = level.winnable
        ? '${level.ways} of ${level.locked ? 'its' : 'the'} ${level.settings} $what land${level.ways == 1 ? 's' : ''} it'
        : 'none of its ${level.settings} $what, and the five squares said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
