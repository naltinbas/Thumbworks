import 'dart:io';

import 'package:throwsden/fair/level.dart';
import 'package:throwsden/fair/levels.dart';
import 'package:throwsden/fair/rules.dart';

/// Walks every ordering of every yard, holds Redei's slotting and
/// Camion's ring to every yard of up to six wrestlers, and refuses
/// the bake on any disagreement: this is what `make bouts` runs, and
/// the README quotes its ledger verbatim.
void main() {
  // Every level's yard: sound, and its label what the walk finds.
  for (final level in Levels.all) {
    final yard = Yard(level.wrestlers, level.bouts);
    if (!yard.sound) {
      stderr.writeln('${level.name}: THE YARD IS NOT SOUND');
      exit(1);
    }
    var orderings = 0, ways = 0;
    yard.orderings((line) {
      orderings++;
      if (level.ring ? yard.ringHolds(line) : yard.chainHolds(line)) ways++;
    });
    if (orderings != level.orderings || ways != level.ways) {
      stderr.writeln('${level.name}: walk finds $ways of $orderings, label says ${level.ways} of ${level.orderings}');
      exit(1);
    }
    // Redei's slotting lands a chain on every yard, and Camion's rule
    // says when a ring closes.
    final slotted = yard.insertion();
    if (slotted.toSet().length != level.wrestlers || !yard.chainHolds(slotted)) {
      stderr.writeln('${level.name}: THE SLOTTING FAILED: $slotted');
      exit(1);
    }
    if ((yard.count().$2 > 0) != yard.strong) {
      stderr.writeln('${level.name}: CAMION DISAGREES');
      exit(1);
    }
  }

  // Every yard of three, four, five and six wrestlers: the walk's count
  // of lines is odd, Redei's slotting lands one, and a ring closes
  // exactly when every wrestler reaches every other.
  final yardsBySize = <int, int>{};
  final evens = <int, int>{};
  final counts = <int, Set<int>>{};
  for (final size in [3, 4, 5, 6]) {
    var yards = 0, even = 0;
    final seen = <int>{};
    for (var bits = 0; bits < (1 << Yard.pairs(size)); bits++) {
      final yard = Yard.fromBits(size, bits);
      yards++;
      final (chains, rings) = yard.count();
      if (chains.isEven) even++;
      seen.add(chains);
      final slotted = yard.insertion();
      if (slotted.toSet().length != size || !yard.chainHolds(slotted)) {
        stderr.writeln('$size WRESTLERS, YARD $bits: THE SLOTTING FAILED');
        exit(1);
      }
      if ((rings > 0) != yard.strong) {
        stderr.writeln('$size WRESTLERS, YARD $bits: CAMION DISAGREES');
        exit(1);
      }
      if (yard.champion != null && rings > 0) {
        stderr.writeln('$size WRESTLERS, YARD $bits: A CHAMPION RINGED');
        exit(1);
      }
    }
    yardsBySize[size] = yards;
    evens[size] = even;
    counts[size] = seen;
  }
  if (evens.values.any((e) => e != 0)) {
    stderr.writeln('AN EVEN COUNT OF LINES: $evens');
    exit(1);
  }
  if ('${yardsBySize.values.toList()}' != '[8, 64, 1024, 32768]') {
    stderr.writeln('THE YARDS MOVED: $yardsBySize');
    exit(1);
  }
  final fives = counts[5]!.toList()..sort();
  if ('$fives' != '[1, 3, 5, 9, 11, 13, 15]') {
    stderr.writeln('THE COUNTS OF FIVE MOVED: $fives');
    exit(1);
  }
  final sixes = counts[6]!.toList()..sort();
  if (sixes.first != 1 || sixes.last != 45) {
    stderr.writeln('THE COUNTS OF SIX MOVED: $sixes');
    exit(1);
  }

  // The named facts of the levels.
  final four = Yard(4, Levels.at(0).bouts);
  var bramLast = 0;
  four.orderings((line) {
    if (four.chainHolds(line) && line.last == 1) bramLast++;
  });
  if (bramLast != 3 || four.scores.toString() != '[2, 0, 2, 2]') {
    stderr.writeln('THE FOUR MOVED: $bramLast last, ${four.scores}');
    exit(1);
  }
  final five = Yard(5, Levels.at(1).bouts);
  var eliFirst = 0;
  five.orderings((line) {
    if (five.chainHolds(line) && line.first == 4) eliFirst++;
  });
  if (eliFirst != 5 || five.champion != 4 || '${five.insertion()}' != '[4, 3, 2, 1, 0]') {
    stderr.writeln('THE FIVE MOVED: $eliFirst first, champion ${five.champion}, ${five.insertion()}');
    exit(1);
  }
  final ring = Yard(5, Levels.at(2).bouts);
  if (ring.count() != (13, 10) || !ring.strong) {
    stderr.writeln('THE RING MOVED: ${ring.count()}');
    exit(1);
  }
  final six = Yard(6, Levels.at(3).bouts);
  if (six.count().$1 != 23) {
    stderr.writeln('THE SIX MOVED: ${six.count()}');
    exit(1);
  }
  final champion = Yard(5, Levels.at(4).bouts);
  if (champion.champion != 4 || champion.strong || champion.count().$2 != 0 || '${Levels.at(4).bouts}' != '${Levels.at(1).bouts}') {
    stderr.writeln('THE CHAMPION\'S RING MOVED');
    exit(1);
  }
  if (Level.names.length < 6) {
    stderr.writeln('NOT ENOUGH NAMES');
    exit(1);
  }

  stdout.writeln(
      'every ordering of every yard walked, and every yard of three, four, '
      'five and six wrestlers taken whole, 8 and 64 and 1,024 and 32,768 of '
      'them: Redei\'s slotting lines up every one with no search, the '
      'count of lines is odd in every one, 1, 3, 5, 9, 11, 13 or 15 for '
      'five wrestlers and never 7, and a ring closes exactly when every '
      'wrestler reaches every other, as Camion says, and never in a yard '
      'with a champion; the four line up three ways with Bram last, the '
      'five line up five ways with Eli first, the ring closes two ways '
      'round and the six line up twenty-three');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(19);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.orderings} orderings land it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.orderings}, and the champion said so first');
  }
}
