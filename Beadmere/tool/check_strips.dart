import 'dart:io';

import 'package:beadmere/strip/levels.dart';
import 'package:beadmere/strip/play.dart';
import 'package:beadmere/strip/rules.dart';

/// Reads every strip of beads, finds its repeats two ways, holds every
/// pair of repeats to Fine and Wilf, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_strips.dart
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

  var strips = 0, pairs = 0, atBound = 0, sharp = 0;
  final sharpest = <String, String>{};
  for (var beads = Rules.shortest; beads <= Rules.longest; beads++) {
    for (final strip in Rules.strips(beads)) {
      strips++;
      // The two ways of reading a repeat agree on every strip.
      for (var p = 1; p <= beads; p++) {
        check(Rules.repeats(strip, p) == Rules.repeatsByBorder(strip, p),
            'the repeat of $p on ${Rules.tellStrip(strip)}');
      }
      final periods = Rules.periodsOf(strip);
      check(periods.contains(beads), 'a strip without its own length');
      for (final p in periods) {
        for (final q in periods) {
          if (q <= p) continue;
          pairs++;
          final forced = Rules.gcdOf(p, q);
          if (beads >= Rules.bound(p, q)) {
            atBound++;
            check(Rules.repeats(strip, forced),
                'Fine and Wilf failed on ${Rules.tellStrip(strip)} with $p '
                'and $q');
          } else if (!Rules.repeats(strip, forced)) {
            sharp++;
            // The sharpest strips: one bead short of the bound.
            if (beads == Rules.bound(p, q) - 1) {
              sharpest['$p,$q'] = Rules.tellStrip(strip);
            }
          }
        }
      }
    }
  }
  // Two to the thirteen less four: every strip from two beads to twelve.
  check(strips == 8188, 'strips swept: $strips');

  // The bound itself, and what it comes to for the asks.
  check(Rules.bound(3, 5) == 7 && Rules.bound(4, 6) == 8 &&
      Rules.bound(5, 8) == 12 && Rules.bound(2, 3) == 4, 'the bound');
  check(Rules.gcdOf(4, 6) == 2 && Rules.gcdOf(5, 8) == 1, 'the divisor');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (final strip in Rules.strips(level.beads)) {
      if (level.meets(strip)) n++;
    }
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    if (level.winnable) {
      check(level.meets(level.aim), '${level.name}: the aim misses');
      check(level.beads < level.bound,
          '${level.name} asks for the impossible below the bound');
      var cheapest = level.beads + 1;
      for (final strip in Rules.strips(level.beads)) {
        if (!level.meets(strip)) continue;
        final darks = strip.where((bead) => bead == Rules.dark).length;
        if (darks < cheapest) cheapest = darks;
      }
      check(level.fewest == cheapest,
          '${level.name}: ${level.fewest} taps against $cheapest');
    } else {
      check(level.aim.isEmpty && n == 0, '${level.name} was landed');
      check(level.beads >= level.bound,
          '${level.name} is below the bound after all');
    }
  }

  // The pointer lands every ask it can, in the fewest taps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final bead = play.next;
      check(bead != null, '${level.name} lost its pointer');
      if (bead == null) break;
      play = play.turn(bead);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  if (failed) {
    stderr.writeln('the strip is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every strip of beads from ${Rules.shortest} to ${Rules.longest} '
        'taken, ${commas(strips)} strips, and every repeat read twice, once '
        'by matching each bead with the one p along and once by matching the '
        'strip\'s head against its tail, which never looks at a single bead '
        'pair: the two agree on every strip and every repeat')
    ..write('; ${commas(pairs)} pairs of repeats came up in all, and on the '
        '${commas(atBound)} of them where the strip runs to p plus q less '
        'their greatest common divisor, the divisor is a repeat too, every '
        'time, which is Fine and Wilf; on the ${commas(sharp)} pairs where '
        'the strip is shorter, it need not be')
    ..write('; one bead short of the bound the strips that dodge it are '
        'these: ')
    ..write((sharpest.keys.toList()..sort((a, b) {
      final left = a.split(',').map(int.parse).toList();
      final right = b.split(',').map(int.parse).toList();
      return left[0] != right[0]
          ? left[0].compareTo(right[0])
          : left[1].compareTo(right[1]);
    }))
        .take(6)
        .map((key) => '${key.replaceAll(',', ' and ')} give ${sharpest[key]}')
        .join(', '));
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(level.strips)} strips land it, the '
            'cheapest in ${level.fewest} '
            '${level.fewest == 1 ? 'tap' : 'taps'}'
        : 'none of the ${commas(level.strips)}, since ${level.beads} beads is '
            'the bound itself';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
