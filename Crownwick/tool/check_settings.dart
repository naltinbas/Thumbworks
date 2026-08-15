import 'dart:io';

import 'package:crownwick/kings/levels.dart';
import 'package:crownwick/kings/rules.dart';

/// Sweeps every setting of kings on the small boards and walks every
/// board, holds the blocks and the even squares to the walk on every
/// board from two to seven, and refuses the bake on any disagreement:
/// this is what `make settings` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Every level's label against the walk, the sweep where it is
  // bearable, the settings count, the blocks and the even squares.
  var swept = 0;
  for (final level in Levels.all) {
    final rules = level.rules;
    final walked = rules.walk(level.kings);
    if (walked != level.ways || rules.settings(level.kings) != level.settings) {
      stderr.writeln('${level.name}: walk finds $walked of ${rules.settings(level.kings)}, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
    if (rules.squares <= 25) {
      final (standing, all) = rules.sweep(level.kings);
      swept += all;
      if (standing != walked || all != level.settings) {
        stderr.writeln('${level.name}: THE SWEEP FINDS $standing OF $all, THE WALK $walked');
        exit(1);
      }
    }
    if ((level.kings <= rules.bound) != level.winnable) {
      stderr.writeln('${level.name}: bound ${rules.bound}, asked ${level.kings}, label ${level.winnable ? 'winnable' : 'hopeless'}');
      exit(1);
    }
    if (level.winnable) {
      final evens = rules.evens;
      if (evens.length < level.kings || rules.clashes(evens).isNotEmpty) {
        stderr.writeln('${level.name}: THE EVEN SQUARES SEAT ${evens.length} WITH ${rules.clashes(evens).length} CLASHES');
        exit(1);
      }
    }
  }

  // Every board from two to seven: the blocks cut the board with no
  // square left out or told twice, any two squares of a block touch,
  // the most kings that stand by the walk is the count of blocks, one
  // more never stands, and the even squares seat that many with no
  // clash.
  var blocksFound = 0;
  for (var n = 2; n <= 7; n++) {
    final rules = Rules(n);
    final seen = <int>{};
    for (final block in rules.blocks) {
      for (final a in block) {
        if (!seen.add(a)) {
          stderr.writeln('$n BY $n: SQUARE $a IN TWO BLOCKS');
          exit(1);
        }
        for (final b in block) {
          if (a != b && !rules.attacks(a).contains(b)) {
            stderr.writeln('$n BY $n: SQUARES $a AND $b IN ONE BLOCK DO NOT TOUCH');
            exit(1);
          }
        }
      }
    }
    if (seen.length != rules.squares) {
      stderr.writeln('$n BY $n: THE BLOCKS COVER ${seen.length} SQUARES');
      exit(1);
    }
    blocksFound += rules.blocks.length;
    final bound = rules.bound;
    if (rules.walk(bound) == 0 || rules.walk(bound + 1) != 0) {
      stderr.writeln('$n BY $n: bound $bound, walk(bound) ${rules.walk(bound)}, walk(bound + 1) ${rules.walk(bound + 1)}');
      exit(1);
    }
    final evens = rules.evens;
    if (evens.length != bound || rules.clashes(evens).isNotEmpty) {
      stderr.writeln('$n BY $n: THE EVEN SQUARES SEAT ${evens.length} AGAINST BOUND $bound');
      exit(1);
    }
    final half = (n + 1) ~/ 2;
    if (bound != half * half) {
      stderr.writeln('$n BY $n: BOUND $bound IS NOT HALF THE SIDE ROUNDED UP, SQUARED');
      exit(1);
    }
    if (n.isOdd && rules.walk(bound) != 1) {
      stderr.writeln('$n BY $n: ${rules.walk(bound)} SETTINGS SEAT THE MOST ON AN ODD SIDE');
      exit(1);
    }
  }

  stdout.writeln(
      'every setting of the kings swept whole on the three by three, the four by '
      'four and the five by five, ${_commas(swept)} settings held up one by one, '
      'and every board walked square by square with the attacking settings '
      'dropped, the sweep and the walk agreeing wherever both ran; on every '
      'board from two to seven the squares cut into blocks of two by two, '
      '$blocksFound blocks on the six boards, no square in two, any two squares '
      'of a block touching, and the most kings that stand is the count of the '
      'blocks, half the side rounded up and squared, one more never standing, '
      'while the even squares seat exactly that many, and on an odd side they '
      'are the only setting that does; the three by three seats four 1 way of '
      '126, the four by four four 79 ways of 1,820, the five by five nine 1 way '
      'of 2,042,975, the six by six nine 3,600 ways of 94,143,280, and five on '
      'the four by four never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${_commas(level.ways)} of the '
            '${_commas(level.settings)} settings land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${_commas(level.settings)}, and the blocks said so first');
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
