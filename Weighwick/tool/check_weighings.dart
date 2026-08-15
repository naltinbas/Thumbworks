import 'dart:io';

import 'package:weighwick/scale/levels.dart';
import 'package:weighwick/scale/rules.dart';

/// Sweeps every placing of the weights against every load, holds
/// counting in threes to the sweep, and refuses the bake on any
/// disagreement: this is what `make weighings` runs, and the README
/// quotes its ledger verbatim.
void main() {
  if (Rules.placings.length != 81 || Rules.most != 40) {
    stderr.writeln('${Rules.placings.length} PLACINGS, MOST ${Rules.most}');
    exit(1);
  }
  // Every level's label against the sweep, and against counting in
  // threes where every weight is allowed.
  for (final level in Levels.all) {
    final ways = Rules.balancing(level.load, barred: level.barred);
    var placings = 0;
    for (final p in Rules.placings) {
      if (!level.barred.any((b) => p[Rules.weights.indexOf(b)] != Side.off)) placings++;
    }
    if (ways.length != level.ways || placings != level.placings) {
      stderr.writeln('${level.name}: sweep finds ${ways.length} of $placings, label says ${level.ways} of ${level.placings}');
      exit(1);
    }
    if (level.barred.isEmpty) {
      final t = Rules.balancedTernary(level.load);
      if (t == null || '$t' != '${ways.first}') {
        stderr.writeln('${level.name}: counting in threes gives $t, the sweep ${ways.first}');
        exit(1);
      }
    }
  }

  // Every load from 1 to 40 balances exactly one way, and it is the way
  // counting in threes gives; 41 never; and the 81 placings weigh 81
  // different amounts, -40 to 40.
  for (var load = 1; load <= 40; load++) {
    final ways = Rules.balancing(load);
    final t = Rules.balancedTernary(load);
    if (ways.length != 1 || t == null || '$t' != '${ways.first}') {
      stderr.writeln('LOAD $load: ${ways.length} WAYS, THREES $t');
      exit(1);
    }
  }
  if (Rules.balancing(41).isNotEmpty || Rules.balancedTernary(41) != null) {
    stderr.writeln('FORTY-ONE BALANCES');
    exit(1);
  }
  final nets = {for (final p in Rules.placings) Rules.net(p)};
  if (nets.length != 81 || nets.reduce((a, b) => a < b ? a : b) != -40 || nets.reduce((a, b) => a > b ? a : b) != 40) {
    stderr.writeln('THE NETS: ${nets.length} DISTINCT');
    exit(1);
  }
  // Without the 1, every placing weighs a multiple of three, 27 amounts.
  final withoutOne = {for (final p in Rules.placings) if (p[0] == Side.off) Rules.net(p)};
  if (withoutOne.length != 27 || withoutOne.any((n) => n % 3 != 0)) {
    stderr.writeln('WITHOUT THE ONE: $withoutOne');
    exit(1);
  }
  // Ten with the 1 allowed is 9 and 1 across.
  final ten = Rules.balancing(10);
  if (ten.length != 1 || '${ten.first}' != '[Side.against, Side.off, Side.against, Side.off]') {
    stderr.writeln('TEN: $ten');
    exit(1);
  }

  stdout.writeln(
      'every placing of the weights 1, 3, 9 and 27 swept, 81 of them, off '
      'the scale, across from the load or beside it, and the 81 weigh 81 '
      'different amounts against the load, -40 to 40, one apiece: every '
      'load from 1 to 40 balances exactly one way, and that way is what '
      'counting in threes with the digits 1, 0 and -1 writes down for it, '
      'load by load, while forty-one balances no way; and with the 1 kept '
      'off, the 27 placings of the other three all weigh multiples of '
      'three, so ten never balances without it, though with it ten is 9 '
      'and 1 across');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(23);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} placing of the '
            '${level.placings} balances it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.placings}, and the multiples of three said so first');
  }
}
