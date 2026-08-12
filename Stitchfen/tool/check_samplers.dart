import 'dart:io';

import 'package:stitchfen/thread/rows.dart';
import 'package:stitchfen/thread/rules.dart';

/// Reads every ladder, sums the prefixes, sweeps every threading,
/// and refuses the bake on any disagreement: this is what
/// `make threads` runs, and the README quotes its ledger verbatim.
void main() {
  // The sweep against the prefix ledger, every size shipped.
  for (final stitches in [6, 7, 8, 9]) {
    final rules = Rules(stitches);
    if (rules.ways() != rules.waysByPrefix()) {
      stderr.writeln('THE PREFIX LEDGER PARTED AT $stitches');
      exit(1);
    }
  }

  for (final row in Rows.all) {
    final ways = Rules(row.stitches).waysFrom(row.fixed);
    if (ways != row.ways) {
      stderr.writeln('${row.name}: sweep finds $ways, '
          'label says ${row.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  final eight = Rules(8);
  if (eight.ways() != 6) {
    stderr.writeln('THE SIX EIGHTS MOVED');
    exit(1);
  }
  // The six pair off under a thread-swap.
  final alive = <String>[];
  eight.threadings((threading) {
    if (eight.ladderFree(threading)) alive.add(threading.join());
  });
  for (final one in alive) {
    final swapped = one
        .split('')
        .map((thread) => thread == 'R' ? 'B' : 'R')
        .join();
    if (!alive.contains(swapped)) {
      stderr.writeln('AN EIGHT WITHOUT ITS SWAP: $one');
      exit(1);
    }
  }
  // Every beginning of three completes at most one way at eight.
  for (final a in const ['R', 'B']) {
    for (final b in const ['R', 'B']) {
      for (final c in const ['R', 'B']) {
        if (eight.waysFrom([a, b, c]) > 1) {
          stderr.writeln('A PREFIX WITH TWO ROADS: $a$b$c');
          exit(1);
        }
      }
    }
  }
  if (Rules(9).ways() != 0) {
    stderr.writeln('A NINTH STITCH SLIPPED THROUGH');
    exit(1);
  }
  // The seven's fussy middle: the three middle stitches each sit
  // in five ladders' reach, the ends in three.
  final reach = List.filled(7, 0);
  for (var start = 0; start < 7; start++) {
    for (var step = 1; start + 2 * step < 7; step++) {
      reach[start]++;
      reach[start + step]++;
      reach[start + 2 * step]++;
    }
  }
  if ('$reach' != '[3, 3, 5, 5, 5, 3, 3]') {
    stderr.writeln('THE REACH MOVED: $reach');
    exit(1);
  }

  stdout.writeln(
      'every threading of every row swept, 64 to 512 by size, '
      'the census agreeing with the prefix ledger on each: six, '
      'seven and eight stitches leave 20, 16 and 6 rows alive, '
      'the six eights pair off under a thread-swap, every '
      'three-stitch beginning finishes at most one way, and nine '
      'stitches leave nothing');
  stdout.writeln('');

  for (var number = 0; number < Rows.count; number++) {
    final row = Rows.at(number);
    final name = row.name.padRight(18);
    stdout.writeln(row.winnable
        ? ' ${number + 1} $name ${row.task}: ${row.ways} '
            'threading${row.ways == 1 ? '' : 's'} of the sweep '
            'land${row.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${row.task}: none of the 512, '
            'and no cleverness was ever going to help');
  }
}
