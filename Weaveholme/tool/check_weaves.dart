import 'dart:io';

import 'package:weaveholme/plaid/levels.dart';
import 'package:weaveholme/plaid/rules.dart';

/// Sweeps every filling of the two and the four, walks the eight row by
/// row, sweeps every triple of rows of six, holds Sylvester's plaids to
/// the rule, and refuses the bake on any disagreement: this is what
/// `make weaves` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep or the walk.
  for (final level in Levels.all) {
    final rules = level.rules;
    if (level.size <= 4) {
      final (landing, all) = rules.sweep();
      if (landing != level.ways || all != level.fillings) {
        stderr.writeln('${level.name}: sweep finds $landing of $all, label says ${level.ways} of ${level.fillings}');
        exit(1);
      }
      final (walked, _) = rules.walk(const []);
      if (walked != landing) {
        stderr.writeln('${level.name}: THE WALK FINDS $walked, THE SWEEP $landing');
        exit(1);
      }
    } else if (level.size == 8) {
      final (walked, first) = rules.walk(level.given);
      final free = level.size * (level.size - level.given.length);
      if (walked != level.ways || (1 << free) != level.fillings || first == null || !rules.lands(first)) {
        stderr.writeln('${level.name}: walk finds $walked of ${1 << free}, label says ${level.ways} of ${level.fillings}');
        exit(1);
      }
      for (var i = 0; i < level.given.length; i++) {
        if (level.given[i] != Rules.sylvester(8)[i]) {
          stderr.writeln('${level.name}: GIVEN ROW $i IS NOT SYLVESTER\'S');
          exit(1);
        }
      }
    } else {
      final (triples, all) = rules.triples();
      if (triples != 0 || level.winnable || (1 << (level.size * level.size)) != level.fillings) {
        stderr.writeln('${level.name}: $triples TRIPLES OF $all AGREE PAIRWISE IN HALF');
        exit(1);
      }
    }
  }

  // Sylvester's plaids of two, four and eight land, and their rows are
  // pairwise even; and no three rows of six are pairwise even, so no
  // six by six plaid can be, while for four and eight there are 768
  // ways to finish four free rows over Sylvester's first four either
  // time.
  for (final n in [2, 4, 8]) {
    final rules = Rules(n);
    if (!rules.lands(Rules.sylvester(n))) {
      stderr.writeln('SYLVESTER\'S $n DOES NOT LAND');
      exit(1);
    }
  }
  final (pairsOfSix, allPairs) = (() {
    var p = 0;
    for (var a = 0; a < 64; a++) {
      for (var b = 0; b < 64; b++) {
        if (const Rules(6).even(a, b)) p++;
      }
    }
    return (p, 64 * 64);
  })();
  if (pairsOfSix == 0) {
    stderr.writeln('NO PAIR OF SIX AGREES IN THREE');
    exit(1);
  }
  final (walkedFour, _) = const Rules(8).walk(Rules.sylvester(8).sublist(0, 4));
  final (sweptFour, _) = const Rules(4).sweep();
  if (walkedFour != 768 || sweptFour != 768) {
    stderr.writeln('THE FOUR: $sweptFour, THE EIGHT OVER FOUR ROWS: $walkedFour');
    exit(1);
  }

  stdout.writeln(
      'every filling of the two by two and the four by four swept whole, 16 and '
      '65,536, and 8 and 768 land, every two rows agreeing in exactly half; the '
      'eight by eight walked row by row over Sylvester\'s rows, 8 fillings of the '
      'last two rows landing of 65,536 and 768 of the last four of 4,294,967,296; '
      'every triple of rows of six swept, 262,144 triples, and none agrees '
      'pairwise in three though ${_commas(pairsOfSix)} pairs of ${_commas(allPairs)} do, since '
      'against a first row of all light two rows agree in an even count of '
      'squares; Sylvester\'s two, four and eight are held to land');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(21);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${_commas(level.ways)} of the '
            '${_commas(level.fillings)} fillings land it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${_commas(level.fillings)}, and the even count said so first');
  }
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
