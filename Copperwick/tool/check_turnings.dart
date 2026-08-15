import 'dart:io';

import 'package:copperwick/coins/levels.dart';
import 'package:copperwick/coins/rules.dart';

/// Sweeps every placement of the turned triangle over every triangle,
/// holds the rows' bound and the third to the sweep on every triangle
/// up to twelve rows, sweeps every sequence of moves on the small
/// tables, and refuses the bake on any disagreement: this is what `make
/// turnings` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, the rows and the third.
  for (final level in Levels.all) {
    final rules = level.rules;
    final within = rules.within(level.moves);
    if (within.length != level.ways || rules.placements.length != level.placements) {
      stderr.writeln('${level.name}: sweep finds ${within.length} of ${rules.placements.length}, label says ${level.ways} of ${level.placements}');
      exit(1);
    }
    if ((rules.fewest <= level.moves) != level.winnable) {
      stderr.writeln('${level.name}: fewest ${rules.fewest}, moves ${level.moves}, label ${level.winnable ? 'winnable' : 'hopeless'}');
      exit(1);
    }
    if (level.winnable) {
      final aim = rules.aim;
      final target = rules.turned(aim);
      if (!rules.isTurned(target.toSet()) || rules.shared(rules.upright.toSet(), aim) != rules.coins - level.moves) {
        stderr.writeln('${level.name}: THE AIM $aim IS NOT WITHIN ${level.moves} MOVES');
        exit(1);
      }
      if (!target.every(rules.table.contains)) {
        stderr.writeln('${level.name}: THE AIM $aim IS OFF THE TABLE');
        exit(1);
      }
    }
  }

  // Every triangle up to twelve rows: the sweep's best placement takes
  // in exactly what the rows allow, and the fewest moves is a third of
  // the pennies rounded down.
  var placementsSwept = 0;
  for (var n = 1; n <= 12; n++) {
    final rules = Rules(n);
    placementsSwept += rules.placements.length;
    if (rules.bestShare != rules.rowsBound || rules.fewest != rules.third) {
      stderr.writeln('$n ROWS: sweep takes in ${rules.bestShare}, rows allow ${rules.rowsBound}, fewest ${rules.fewest}, third ${rules.third}');
      exit(1);
    }
    if (rules.within(rules.fewest).isEmpty || rules.within(rules.fewest - 1).isNotEmpty) {
      stderr.writeln('$n ROWS: within ${rules.fewest} ${rules.within(rules.fewest)}, within ${rules.fewest - 1} ${rules.within(rules.fewest - 1)}');
      exit(1);
    }
  }

  // Every sequence of moves on the table for the small triangles: the
  // three in one move, the six in two and the ten in three land on a
  // turned triangle as often as the placements say, the moved pennies
  // and their spots in every order, and one move fewer never lands.
  final counted = <String>[];
  for (final (n, k) in [(2, 1), (3, 2), (4, 3)]) {
    final rules = Rules(n);
    final (landing, all) = rules.sequences(k);
    var orders = 1;
    for (var i = 2; i <= k; i++) {
      orders *= i * i;
    }
    if (landing != rules.within(k).length * orders) {
      stderr.writeln('$n ROWS IN $k: $landing sequences land, placements ${rules.within(k).length} times $orders');
      exit(1);
    }
    final (short, _) = rules.sequences(k - 1);
    if (short != 0) {
      stderr.writeln('$n ROWS IN ${k - 1}: $short SEQUENCES LAND');
      exit(1);
    }
    counted.add('${_commas(landing)} of ${_commas(all)}');
  }

  stdout.writeln(
      'every placement of the turned triangle over the pennies swept for every '
      'triangle up to twelve rows, ${_commas(placementsSwept)} placements: the most '
      'any takes in as they lie is exactly what the rows allow, the shorter of '
      'each turned row and the coin row under it, so the fewest moves is a third '
      'of the pennies rounded down, on all twelve; every sequence of moves on '
      'the table swept for the three, the six and the ten, ${counted[0]} '
      'sequences of one move landing, ${counted[1]} of two and ${counted[2]} of '
      'three, the moved pennies and their spots in every order, and one move '
      'fewer landing none; the three turn in one move by 3 placements of 6, the '
      'six in two by 3 of 15, the ten in three by 1 of 28, the fifteen in five '
      'by 3 of 45, and the ten in two by none of 28');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(14);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.placements} placements ${level.ways == 1 ? 'is' : 'are'} within reach'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.placements}, and the rows said so first');
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
