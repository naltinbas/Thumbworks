import 'dart:io';

import 'package:whistlecote/whistle/level.dart';
import 'package:whistlecote/whistle/levels.dart';
import 'package:whistlecote/whistle/rules.dart';

/// Sweeps every marking of every set of calls, holds the shepherd's way
/// and the product to the sweep, on the sets that ship and on every set
/// of up to six calls of up to four notes, and refuses the bake on any
/// disagreement: this is what `make whistles` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, the product, the shares and
  // the shepherd.
  final rules = Level.rules;
  for (final level in Levels.all) {
    final (landing, all) = rules.sweep(level.lengths);
    if (landing != level.ways || all != level.markings) {
      stderr.writeln('${level.name}: sweep finds $landing of $all, label says ${level.ways} of ${level.markings}');
      exit(1);
    }
    if (rules.product(level.lengths) != landing) {
      stderr.writeln('${level.name}: PRODUCT ${rules.product(level.lengths)} IS NOT THE SWEEP\'S $landing');
      exit(1);
    }
    if (rules.fits(level.lengths) != level.winnable) {
      stderr.writeln('${level.name}: shares ${rules.share(level.lengths)} of ${rules.whole}, label ${level.winnable ? 'winnable' : 'hopeless'}');
      exit(1);
    }
    final shepherd = rules.byShepherd(level.lengths);
    if ((shepherd == null) == level.winnable) {
      stderr.writeln('${level.name}: the shepherd ${shepherd == null ? 'finds nothing' : 'lands $shepherd'}');
      exit(1);
    }
    if (shepherd != null && !rules.lands(shepherd, level.lengths)) {
      stderr.writeln('${level.name}: THE SHEPHERD\'S MARKING $shepherd FAILS');
      exit(1);
    }
    for (final (_, l) in level.calls) {
      if (l < 1 || l > rules.depth) {
        stderr.writeln('${level.name}: BAD LENGTH $l');
        exit(1);
      }
    }
  }

  // Every set of up to six calls of up to four notes: the sweep finds a
  // marking exactly when the shares come to no more than the whole;
  // when it does, the shepherd's way lands and the product is the count;
  // when it does not, the shepherd finds nothing and the product is
  // nought.
  final wide = const Rules(4);
  var sets = 0, markings = 0, fitting = 0;
  for (var m1 = 0; m1 <= 6; m1++) {
    for (var m2 = 0; m1 + m2 <= 6; m2++) {
      for (var m3 = 0; m1 + m2 + m3 <= 6; m3++) {
        for (var m4 = 0; m1 + m2 + m3 + m4 <= 6; m4++) {
          if (m1 + m2 + m3 + m4 == 0) continue;
          final lengths = [
            ...List.filled(m1, 1),
            ...List.filled(m2, 2),
            ...List.filled(m3, 3),
            ...List.filled(m4, 4),
          ];
          sets++;
          final (landing, all) = wide.sweep(lengths);
          markings += all;
          final fits = wide.fits(lengths);
          final shepherd = wide.byShepherd(lengths);
          final product = wide.product(lengths);
          if ((landing > 0) != fits || (shepherd != null) != fits || product != landing) {
            stderr.writeln('SET $lengths: sweep $landing of $all, fits $fits, shepherd $shepherd, product $product');
            exit(1);
          }
          if (fits) {
            fitting++;
            if (!wide.lands(shepherd!, lengths)) {
              stderr.writeln('SET $lengths: THE SHEPHERD\'S MARKING $shepherd FAILS');
              exit(1);
            }
          }
        }
      }
    }
  }

  stdout.writeln(
      'every marking of every set of calls swept, and every set of up to six '
      'calls of up to four notes taken whole, $sets sets and ${_commas(markings)} '
      'markings: the sweep finds a marking where no whistle starts another '
      'exactly when the shares come to no more than the whole, $fitting sets of '
      'the $sets, which is Kraft\'s inequality; where it does, the shepherd\'s way '
      'lands, shortest calls first and each on the leftmost whistle no given one '
      'begins, and the markings landing number the product of the free choices '
      'at each length; the three calls whistle 2 ways of 12, the four calls 4 of '
      '224, the long calls 36 of 168, the five calls 60 of 280, and the crowded '
      'calls none of 448');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(17);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.markings} markings land it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.markings}, and Kraft\'s inequality said so first');
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
