import 'dart:io';

import 'package:knuckleby/bones/benches.dart';
import 'package:knuckleby/bones/rules.dart';

/// Recuts every pair of every bench, builds them again from the
/// factor-trade, and refuses the bake on any disagreement: this is
/// what `make benches` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // The sweep against the factor-trade, on the two square benches.
  for (final faces in const [4, 6]) {
    final swept = Rules.matching(faces, faces);
    final built = Rules.byFactors(faces);
    if (swept.length != built.length) {
      stderr.writeln('SWEEP AND FACTORS DISAGREE on $faces sides: '
          '${swept.length} vs ${built.length}');
      exit(1);
    }
    for (var at = 0; at < swept.length; at++) {
      if ('${swept[at]}' != '${built[at]}') {
        stderr.writeln('PAIR $at DIFFERS on $faces sides');
        exit(1);
      }
    }
    // Every matching die keeps exactly one ace.
    for (final (one, two) in swept) {
      if (one.where((pip) => pip == 1).length != 1 ||
          two.where((pip) => pip == 1).length != 1) {
        stderr.writeln('A MATCHING DIE WITHOUT ITS ONE ACE');
        exit(1);
      }
    }
  }

  // The even bench: every even-pipped pair counted, none matching.
  final evens = Rules.everyDie(6, 2, 8)
      .where((die) => die.every((pip) => pip.isEven))
      .toList();
  var evenPairs = 0;
  var evenMatches = 0;
  final wanted = Rules.table(Rules.standard(6), Rules.standard(6));
  for (var at = 0; at < evens.length; at++) {
    for (var other = at; other < evens.length; other++) {
      evenPairs++;
      if (Rules.sameTable(
          Rules.table(evens[at], evens[other]), wanted)) {
        evenMatches++;
      }
    }
  }
  if (evenPairs != 3570 || evenMatches != 0) {
    stderr.writeln('THE EVEN BENCH MISCOUNTED: '
        '$evenPairs pairs, $evenMatches matching');
    exit(1);
  }

  stdout.writeln(
      'the sweep of every pair of dice against the factor-trade '
      'that never rolls: they build the same pairs to the last '
      'pip, every matching die keeps exactly one ace, and no '
      'even-pipped pair of the 3,570 ever lands an odd throw');
  stdout.writeln('');

  for (var number = 0; number < Benches.count; number++) {
    final bench = Benches.at(number);
    final swept = Rules.matching(bench.facesOne, bench.facesTwo,
        low: bench.lowPip);
    final counted = bench.evensOnly
        ? swept
            .where((pair) =>
                pair.$1.every((pip) => pip.isEven) &&
                pair.$2.every((pip) => pip.isEven))
            .length
        : bench.lockedOne
            ? swept
                .where((pair) =>
                    '${pair.$1}' == '${Rules.standard(bench.facesOne)}' ||
                    '${pair.$2}' == '${Rules.standard(bench.facesOne)}')
                .length
            : swept.length;

    if (counted != bench.ways) {
      stderr.writeln('${bench.name}: label says ${bench.ways}, '
          'sweep says $counted');
      exit(1);
    }

    final name = bench.name.padRight(22);
    final sides = bench.facesOne == bench.facesTwo
        ? 'two ${bench.facesOne}-siders'
        : 'a ${bench.facesOne}-sider and a ${bench.facesTwo}-sider';
    stdout.writeln(bench.winnable
        ? ' ${number + 1} $name $sides  ${bench.task}: '
            '${bench.ways} pair${bench.ways == 1 ? ' falls' : 's fall'} '
            'alike in all'
        : ' ${number + 1} $name $sides  ${bench.task}: no pair of '
            'the 3,570 does');
  }
}
