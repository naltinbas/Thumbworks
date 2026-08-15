import 'dart:io';

import 'package:farrierstead/knights/levels.dart';
import 'package:farrierstead/knights/rules.dart';

/// Sweeps every setting of knights on the small boards and walks every
/// board, holds the pairing and the one colour to the walk on every
/// board from three to seven, and refuses the bake on any disagreement:
/// this is what `make settings` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Every level's label against the walk, the sweep where it is
  // bearable, the settings count, the pairing and the one colour.
  var swept = 0;
  for (final level in Levels.all) {
    final rules = level.rules;
    final walked = rules.walk(level.knights);
    if (walked != level.ways || rules.settings(level.knights) != level.settings) {
      stderr.writeln('${level.name}: walk finds $walked of ${rules.settings(level.knights)}, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
    if (rules.squares <= 25) {
      final (standing, all) = rules.sweep(level.knights);
      swept += all;
      if (standing != walked || all != level.settings) {
        stderr.writeln('${level.name}: THE SWEEP FINDS $standing OF $all, THE WALK $walked');
        exit(1);
      }
    }
    if ((level.knights <= rules.bound) != level.winnable) {
      stderr.writeln('${level.name}: bound ${rules.bound}, asked ${level.knights}, label ${level.winnable ? 'winnable' : 'hopeless'}');
      exit(1);
    }
    if (level.winnable) {
      final colour = rules.oneColour;
      if (colour.length < level.knights || rules.clashes(colour).isNotEmpty) {
        stderr.writeln('${level.name}: ONE COLOUR SEATS ${colour.length} WITH ${rules.clashes(colour).length} CLASHES');
        exit(1);
      }
    }
  }

  // Every board from three to seven: the pairing is knight's moves,
  // disjoint; the most knights that stand by the walk is the squares
  // less the pairs; one more never stands; and one colour seats that
  // many with no clash.
  var pairsFound = 0;
  for (var n = 3; n <= 7; n++) {
    final rules = Rules(n);
    final pairing = rules.pairing;
    final seen = <int>{};
    for (final (a, b) in pairing) {
      if (!rules.attacks(a).contains(b) || !seen.add(a) || !seen.add(b)) {
        stderr.writeln('$n BY $n: PAIR ($a, $b) IS NO KNIGHT\'S MOVE OR REUSES A SQUARE');
        exit(1);
      }
    }
    pairsFound += pairing.length;
    final bound = rules.bound;
    if (rules.walk(bound) == 0 || rules.walk(bound + 1) != 0) {
      stderr.writeln('$n BY $n: bound $bound, walk(bound) ${rules.walk(bound)}, walk(bound + 1) ${rules.walk(bound + 1)}');
      exit(1);
    }
    final colour = rules.oneColour;
    if (colour.length != bound || rules.clashes(colour).isNotEmpty) {
      stderr.writeln('$n BY $n: ONE COLOUR SEATS ${colour.length} AGAINST BOUND $bound');
      exit(1);
    }
    if (bound != (n * n + 1) ~/ 2) {
      stderr.writeln('$n BY $n: BOUND $bound IS NOT HALF THE BOARD ROUNDED UP');
      exit(1);
    }
  }
  // The two by two seats all four, no knight reaching another.
  if (const Rules(2).walk(4) != 1 || const Rules(2).pairing.isNotEmpty) {
    stderr.writeln('THE TWO BY TWO: ${const Rules(2).walk(4)} SETTINGS OF FOUR');
    exit(1);
  }

  stdout.writeln(
      'every setting of the knights swept whole on the three by three, the four '
      'by four and the five by five, ${_commas(swept)} settings held up one by one, '
      'and every board walked square by square with the attacking settings '
      'dropped, the sweep and the walk agreeing wherever both ran; on every '
      'board from three to seven the squares pair off as knight\'s moves, '
      '$pairsFound pairs found on the five boards, and the most knights that '
      'stand is the squares less the pairs, half the board rounded up, one more '
      'never standing, while the squares of one colour seat exactly that many, '
      'since a knight always changes colour; the two by two seats all four; the '
      'three by three seats five 2 ways of 126, the four by four eight 6 ways of '
      '12,870, the five by five thirteen 1 way of 5,200,300, the six by six '
      'eighteen 2 ways of 9,075,135,300, and nine on the four by four never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${_commas(level.settings)} settings land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${_commas(level.settings)}, and the pairing said so first');
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
