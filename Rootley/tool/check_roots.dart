import 'dart:io';

import 'package:rootley/root/levels.dart';
import 'package:rootley/root/play.dart';
import 'package:rootley/root/rules.dart';

/// Walks every base of every clock and sets the walk against a second
/// reckoning that never walks. Refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_roots.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  // The two voices on every base of every clock to a hundred.
  var walks = 0;
  for (var c = 3; c <= 100; c++) {
    for (var b = 1; b < c; b++) {
      walks++;
      final byWalk = Rules.orderByWalk(b, c), byLambda = Rules.orderByLambda(b, c);
      check(byWalk == byLambda, 'order of $b on $c: walk $byWalk, lambda $byLambda');
      check((byWalk == null) == (Rules.gcd(b, c) != 1), 'home of $b on $c against the shared factor');
      final w = Rules.walk(b, c);
      check(w.toSet().length == w.length && w.first == 1, 'walk of $b on $c repeats or starts wrong');
    }
    check(Rules.hasFullByGauss(c) == Rules.hasFullByWalk(c), 'full base on $c: Gauss ${Rules.hasFullByGauss(c)}, sweep ${Rules.hasFullByWalk(c)}');
    check(Rules.lambda(c) % 1 == 0 && [for (var b = 1; b < c; b++) b].where((b) => Rules.gcd(b, c) == 1).every((b) => Rules.powMod(b, Rules.lambda(c), c) == 1), 'lambda of $c brings every base home');
  }
  check(walks == 4949, 'walks to a hundred: $walks');
  final withFull = [for (var c = 3; c <= 100; c++) if (Rules.hasFullByWalk(c)) c].length;
  final primes = [for (var c = 3; c <= 100; c++) if (Rules.factors(c).length == 1 && Rules.factors(c).first.$2 == 1) c];
  for (final p in primes) {
    final full = [for (var b = 1; b < p; b++) if (Rules.isFull(b, p)) b].length;
    check(full == Rules.phi(p - 1), 'full bases of $p: $full, phi(${p - 1}) ${Rules.phi(p - 1)}');
  }

  // The dials.
  check(Rules.settings == 275, 'settings ${Rules.settings}');
  var full = 0, never = 0;
  final clocksWithFull = <int>[], clocksWithout = <int>[];
  var longest = 0;
  final longestAt = <(int, int)>[];
  for (var c = Rules.least; c <= Rules.most; c++) {
    var f = 0;
    for (var b = 1; b < c; b++) {
      if (Rules.isFull(b, c)) f++;
      if (!Rules.comesHome(b, c)) never++;
      final w = Rules.walk(b, c).length;
      if (w > longest) {
        longest = w;
        longestAt.clear();
      }
      if (w == longest) longestAt.add((c, b));
    }
    full += f;
    (f > 0 ? clocksWithFull : clocksWithout).add(c);
  }
  check(full == 51, 'full bases on the dials: $full');
  check(never == 97, 'walks never home on the dials: $never');
  check(clocksWithFull.length == 15 && clocksWithout.join(',') == '8,12,15,16,20,21,24', 'clocks with a full base $clocksWithFull, without $clocksWithout');
  check(longest == 22 && longestAt.first == (23, 5) && longestAt.length == 10, 'longest walk $longest at $longestAt');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (var c = Rules.least; c <= Rules.most; c++) {
      for (var b = 1; b < c; b++) {
        if (level.meets(c, b)) n++;
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

  // Named facts.
  List<int> backwards(List<int> w) => [1, ...w.reversed.take(w.length - 1)];
  check(Rules.walk(3, 7).join(',') == '1,3,2,6,4,5' && Rules.walk(5, 7).join(',') == backwards(Rules.walk(3, 7)).join(','), 'seven: 3 and 5 walk each other backwards');
  check(Rules.walk(2, 9).join(',') == '1,2,4,8,7,5' && Rules.walk(5, 9).join(',') == backwards(Rules.walk(2, 9)).join(','), 'nine: 2 and 5 walk each other backwards');
  check(Rules.walk(2, 7).length == 3 && Rules.walk(4, 7).length == 3 && Rules.walk(6, 7).length == 2, 'seven: the short walks');
  check(Rules.walk(4, 9).length == 3 && Rules.walk(7, 9).length == 3 && Rules.walk(8, 9).length == 2 && Rules.fallsTo(3, 9) == 0 && Rules.fallsTo(6, 9) == 0, 'nine: the short walks and the falls');
  final fourth = <int, List<int>>{};
  for (var c = Rules.least; c <= Rules.most; c++) {
    for (var b = 1; b < c; b++) {
      if (Rules.orderByWalk(b, c) == 4) (fourth[c] ??= []).add(b);
    }
  }
  check(fourth.keys.join(',') == '5,10,13,15,16,17,20' && fourth.values.map((v) => v.length).join(',') == '2,2,2,4,4,2,4', 'fourth homes by clock: $fourth');
  for (final entry in fourth.entries) {
    for (final b in entry.value) {
      final second = Rules.walk(b, entry.key)[2];
      check(second != 1 && second * second % entry.key == 1, 'second step of $b on ${entry.key}: $second');
      final want = const {5: 4, 10: 9, 13: 12, 17: 16, 15: 4, 16: 9, 20: 9}[entry.key];
      check(second == want, 'second step of $b on ${entry.key}: $second, not $want');
    }
  }
  check(Rules.walk(2, 5).join(',') == '1,2,4,3', 'the walk of 2 on five');
  final round = <int, int>{};
  for (var c = 10; c <= Rules.most; c++) {
    for (var b = 1; b < c; b++) {
      if (Rules.orderByWalk(b, c) == c - 1) round[c] = (round[c] ?? 0) + 1;
    }
  }
  check(round.keys.join(',') == '11,13,17,19,23' && round.values.join(',') == '4,4,8,6,10', 'full rounds by clock: $round');
  check(round.keys.every((c) => Rules.factors(c).length == 1 && Rules.factors(c).first.$2 == 1), 'full rounds on prime clocks only');
  check(Rules.walk(2, 11).join(',') == '1,2,4,8,5,10,9,7,3,6', 'the walk of 2 on eleven');
  check(Rules.walk(2, 12).join(',') == '1,2,4,8' && Rules.fallsTo(2, 12) == 4, 'the walk of 2 on twelve');
  for (final odd in [1, 3, 5, 7]) {
    check(odd * odd % 8 == 1, 'odd square $odd on eight');
  }
  var oddTouched = 0;
  for (var b = 1; b < 8; b++) {
    final touched = Rules.walk(b, 8).where((h) => h.isOdd).length;
    if (touched > oddTouched) oddTouched = touched;
    check(b.isOdd ? Rules.comesHome(b, 8) && Rules.walk(b, 8).length == (b == 1 ? 1 : 2) : Rules.fallsTo(b, 8) == 0, 'the walk of $b on eight');
  }
  check(oddTouched == 2, 'odd hours touched on eight: $oddTouched');
  check(clocksWithout.first == 8, 'the smallest clock with no full base');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every base of every clock from three to a hundred hours walked, ${walks.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} walks, and the steps home of each agree with the reckoning by Carmichael\'s lambda and squaring; the clocks with a full base are exactly the ones Gauss\'s rule names, $withFull of the 98, and every prime clock has phi of one less of them; on the dials, three to twenty-four hours, ${Rules.settings} settings, $full full bases, $never walks that never come home, and ${clocksWithFull.length} of the 22 clocks with a full base, ${Rules.told(clocksWithout)} without; 3 and 5 walk the seven-hour clock each the other\'s way backwards, 2 and 5 the nine-hour, ${fourth.values.fold(0, (a, v) => a + v.length)} settings come home on the fourth step and not before, ${round.values.fold(0, (a, v) => a + v)} on prime clocks of ten hours or more touch every hour but 0, and on the eight-hour clock every odd square is 1, so no base touches more than two of its four odd hours\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final what = level.locked ? 'bases' : 'settings';
    final tail = level.winnable
        ? '${level.ways} of ${level.locked ? 'its' : 'the'} ${level.settings} $what land${level.ways == 1 ? 's' : ''} it'
        : 'none of its ${level.settings} $what, and the odd squares said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
