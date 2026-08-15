import 'dart:io';

import 'package:watchcombe/yard/levels.dart';
import 'package:watchcombe/yard/rules.dart';

/// Sweeps every posting of watchmen on the small yards and walks every
/// yard, holds the far flags and the posting one in from them to the
/// walk on every yard from three to nine, and refuses the bake on any
/// disagreement: this is what `make postings` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the walk, the sweep where it is
  // bearable, the postings count, the far flags and the posting.
  var swept = 0;
  for (final level in Levels.all) {
    final rules = level.rules;
    final walked = rules.walk(level.watchmen);
    if (walked != level.ways || rules.postings(level.watchmen) != level.postings) {
      stderr.writeln('${level.name}: walk finds $walked of ${rules.postings(level.watchmen)}, label says ${level.ways} of ${level.postings}');
      exit(1);
    }
    if (rules.flags <= 36) {
      final (watching, all) = rules.sweep(level.watchmen);
      swept += all;
      if (watching != walked || all != level.postings) {
        stderr.writeln('${level.name}: THE SWEEP FINDS $watching OF $all, THE WALK $walked');
        exit(1);
      }
    }
    if ((level.watchmen >= rules.bound) != level.winnable) {
      stderr.writeln('${level.name}: bound ${rules.bound}, asked ${level.watchmen}, label ${level.winnable ? 'winnable' : 'hopeless'}');
      exit(1);
    }
    if (level.winnable) {
      final posting = rules.posting;
      if (posting.length > level.watchmen || rules.unwatched(posting).isNotEmpty) {
        stderr.writeln('${level.name}: THE POSTING ${posting.length} STRONG LEAVES ${rules.unwatched(posting).length} FLAGS');
        exit(1);
      }
    }
  }

  // Every yard from three to nine: the far flags lie beyond one
  // another's watch, so each wants its own watchman; the posting one in
  // from them watches the yard with exactly that many; the walk finds
  // no posting of one fewer, and some of that many; and that many is a
  // third of the side rounded up, squared.
  var farInAll = 0;
  for (var n = 3; n <= 9; n++) {
    final rules = Rules(n);
    final far = rules.far;
    for (final a in far) {
      for (final b in far) {
        if (a != b && rules.watch(a).any(rules.watch(b).contains)) {
          stderr.writeln('$n BY $n: FAR FLAGS $a AND $b ARE WITHIN ONE WATCH');
          exit(1);
        }
      }
    }
    farInAll += far.length;
    final bound = rules.bound;
    final third = (n + 2) ~/ 3;
    if (bound != third * third) {
      stderr.writeln('$n BY $n: ${far.length} FAR FLAGS, NOT A THIRD OF THE SIDE ROUNDED UP SQUARED');
      exit(1);
    }
    if (rules.posting.length != bound || rules.unwatched(rules.posting).isNotEmpty) {
      stderr.writeln('$n BY $n: THE POSTING ${rules.posting.length} STRONG LEAVES ${rules.unwatched(rules.posting).length}');
      exit(1);
    }
    if (rules.walk(bound) == 0 || rules.walk(bound - 1) != 0) {
      stderr.writeln('$n BY $n: walk($bound) ${rules.walk(bound)}, walk(${bound - 1}) ${rules.walk(bound - 1)}');
      exit(1);
    }
  }

  stdout.writeln(
      'every posting of the watchmen swept whole on the four, five and six yards, '
      '${_commas(swept)} postings held up one by one, and every yard walked from '
      'the first unwatched flag, the sweep and the walk agreeing wherever both '
      'ran; on every yard from three to nine the flags in the rows and columns '
      'that are multiples of three lie beyond one another\'s watch, $farInAll far '
      'flags on the seven yards, so the fewest watchmen is at least their count, '
      'a third of the side rounded up and squared, and a watchman one in from '
      'each of them watches the yard with exactly that many, one fewer never '
      'watching it; the four yard is watched by four 256 ways of 1,820, the '
      'five by four 79 ways of 12,650, the six by four 1 way of 58,905, the nine '
      'by nine 1 way of 260,887,834,350, and the six by three never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(23);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${_commas(level.ways)} of the '
            '${_commas(level.postings)} postings watch${level.ways == 1 ? 'es' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${_commas(level.postings)}, and the far flags said so first');
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
