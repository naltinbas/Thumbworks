import 'dart:io';

import 'package:sunderby/part/levels.dart';
import 'package:sunderby/part/play.dart';
import 'package:sunderby/part/rules.dart';

/// Lays out every partition of every number to thirty, folds and turns
/// them, holds the counts together, and refuses the bake on any
/// disagreement: this is what `make parts` runs, and the README quotes
/// its ledger verbatim.
void main() {
  // Every number to thirty: all-different against all-odd, by count and
  // by Glaisher's folding; and the turning swapping parts for largest.
  var total = 0;
  final counts = <String>[];
  for (var n = 1; n <= Rules.top; n++) {
    final all = Rules.partitions(n);
    total += all.length;
    if (all.map(Rules.told).toSet().length != all.length || all.any((p) => p.fold<int>(0, (a, b) => a + b) != n)) {
      stderr.writeln('$n: A BAD PARTITION');
      exit(1);
    }
    final different = all.where(Rules.allDifferent).toList(), odd = all.where(Rules.allOdd).toList();
    if (different.length != odd.length) {
      stderr.writeln('$n: ${different.length} ALL DIFFERENT, ${odd.length} ALL ODD');
      exit(1);
    }
    final folded = odd.map(Rules.fold).toList();
    if (folded.any((p) => !Rules.allDifferent(p) || p.fold<int>(0, (a, b) => a + b) != n) || folded.map(Rules.told).toSet().length != odd.length ||
        !folded.map(Rules.told).toSet().containsAll(different.map(Rules.told))) {
      stderr.writeln('$n: THE FOLDING DOES NOT LAND ONCE EACH');
      exit(1);
    }
    for (var k = 1; k <= n; k++) {
      if (all.where((p) => p.length == k).length != all.where((p) => p.first == k).length) {
        stderr.writeln('$n: $k PARTS AND LARGEST $k DIFFER');
        exit(1);
      }
    }
    for (final p in all) {
      final t = Rules.turned(p);
      if (t.fold<int>(0, (a, b) => a + b) != n || t.length != p.first || t.first != p.length || Rules.told(Rules.turned(t)) != Rules.told(p)) {
        stderr.writeln('$n: THE TURNING OF ${Rules.told(p)} IS OFF');
        exit(1);
      }
    }
    if (n <= 12 || n == 30) counts.add('$n:${all.length}:${different.length}');
  }
  if (counts.join(' ') != '1:1:1 2:2:1 3:3:2 4:5:2 5:7:3 6:11:4 7:15:5 8:22:6 9:30:8 10:42:10 11:56:12 12:77:15 30:5604:296' || total != 28628) {
    stderr.writeln('THE COUNTS ARE $counts, $total IN ALL');
    exit(1);
  }
  // Every level's label against the sweep, the aim landing it, and no
  // level over at the opening.
  for (final level in Levels.all) {
    final met = level.all.where(level.meets).length;
    if (met != level.ways) {
      stderr.writeln('${level.name}: sweep finds $met of ${level.all.length}, label says ${level.ways}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? level.winnable : !level.meets(aim)) {
      stderr.writeln('${level.name}: the aim $aim does not land it');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }
  // The named partitions.
  final eightDifferent = Rules.partitions(8).where(Rules.allDifferent).map(Rules.told).join(', ');
  final eightOdd = Rules.partitions(8).where(Rules.allOdd).map(Rules.told).join(', ');
  if (eightDifferent != '8, 7 + 1, 6 + 2, 5 + 3, 5 + 2 + 1, 4 + 3 + 1' || eightOdd != '7 + 1, 5 + 3, 5 + 1 + 1 + 1, 3 + 3 + 1 + 1, 3 + 1 + 1 + 1 + 1 + 1, 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1' ||
      Rules.told(Rules.fold([5, 1, 1, 1])) != '5 + 2 + 1' || Rules.told(Rules.fold([3, 3, 1, 1])) != '6 + 2' || Rules.told(Rules.fold([1, 1, 1, 1, 1, 1, 1, 1])) != '8' ||
      Rules.told(Rules.turned([4, 3, 1])) != '3 + 2 + 2 + 1' || Rules.told(Rules.turned([3, 3, 3])) != '3 + 3 + 3' ||
      Rules.partitions(9).where((p) => p.length == 3 && p.first == 3).map(Rules.told).join(', ') != '3 + 3 + 3' ||
      Rules.partitions(8).where((p) => Rules.allDifferent(p) && Rules.allEven(p)).map(Rules.told).join(', ') != '8, 6 + 2' ||
      Rules.partitions(10).where((p) => Rules.allDifferent(p) && Rules.allEven(p)).map(Rules.told).join(', ') != '10, 8 + 2, 6 + 4' ||
      Rules.partitions(9).where(Rules.allEven).isNotEmpty) {
    stderr.writeln('THE NAMED PARTITIONS ARE OFF');
    exit(1);
  }
  // Odd numbers never sunder into even parts, to thirty.
  for (var n = 1; n <= Rules.top; n += 2) {
    if (Rules.partitions(n).any(Rules.allEven)) {
      stderr.writeln('$n SUNDERS INTO EVEN PARTS');
      exit(1);
    }
  }

  stdout.writeln(
      'every partition of every number to thirty laid out, 28,628 in all and 5,604 '
      'for thirty alone, and on every number the all-different partitions and the '
      'all-odd ones come to the same count, 1, 1, 2, 2, 3, 4, 5, 6, 8, 10, 12, 15 '
      'from one to twelve and 296 for thirty; every all-odd partition folds by '
      'Glaisher\'s merging of equal parts into an all-different one, and the '
      'foldings land on the all-different partitions once each, on every number; '
      'every partition turned swaps its count of parts for its largest part and '
      'turns back to itself, so k parts and largest part k come in equal numbers '
      'for every k; and no odd number to thirty sunders into even parts, while '
      'eight does so into different ones two ways and ten three');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(13);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of its ${level.all.length} partitions ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of its ${level.all.length}, and the even sum said so first');
  }
}
