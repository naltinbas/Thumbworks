import 'dart:io';

import 'package:muxholme/miu/levels.dart';
import 'package:muxholme/miu/rules.dart';

/// Sweeps every derivation of so many steps for every string on the
/// sham, walks every string reachable on the sheet, holds the count of I
/// to its law, and refuses the bake on any disagreement: this is what
/// `make derivings` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep and the walk.
  for (final level in Levels.all) {
    final (landing, all) = Rules.sweep(level.target, level.steps);
    if (landing != level.ways || all != level.derivations) {
      stderr.writeln('${level.name}: sweep finds $landing of $all, label says ${level.ways} of ${level.derivations}');
      exit(1);
    }
    final fewest = Rules.fewest(level.target);
    if ((fewest != null && fewest <= level.steps) != level.winnable) {
      stderr.writeln('${level.name}: fewest $fewest, allowed ${level.steps}, label ${level.winnable ? 'winnable' : 'hopeless'}');
      exit(1);
    }
    if (level.winnable) {
      final path = Rules.derivation(level.target)!;
      var s = Rules.start;
      for (final m in path) {
        s = Rules.apply(s, m)!;
      }
      if (s != level.target || path.length != fewest) {
        stderr.writeln('${level.name}: THE DERIVATION FOUND ENDS AT $s IN ${path.length}');
        exit(1);
      }
    }
  }

  // Every string reachable on the sheet: the count of I is never a
  // multiple of three, MU is not among them, and every string of the
  // right shape up to eight letters is among them, so the law tells
  // the derivable strings apart from the rest, up to eight letters.
  final walked = Rules.walk();
  if (!walked.keys.every(Rules.keepsFaith) || walked.containsKey('MU')) {
    stderr.writeln('THE WALK REACHES A STRING WHOSE I COUNT IS A MULTIPLE OF THREE, OR MU');
    exit(1);
  }
  var shaped = 0, reachedShort = 0;
  void gen(String s) {
    if (s.length > 8) return;
    if (Rules.shaped(s)) {
      shaped++;
      if (!walked.containsKey(s)) {
        stderr.writeln('$s HAS THE SHAPE BUT IS NOT REACHED');
        exit(1);
      }
    }
    if (s.length < 8) {
      gen('${s}I');
      gen('${s}U');
    }
  }
  gen('M');
  reachedShort = walked.keys.where((k) => k.length <= 8).length;
  if (reachedShort != shaped) {
    stderr.writeln('$reachedShort STRINGS OF UP TO EIGHT LETTERS REACHED, $shaped SHAPED');
    exit(1);
  }
  // The rules and the count of I: rule one and four keep it, rule two
  // doubles it, rule three takes three, checked on every reachable string.
  for (final s in walked.keys) {
    for (final m in Rules.moves(s)) {
      final t = Rules.apply(s, m)!;
      final before = Rules.iCount(s), after = Rules.iCount(t);
      final expected = switch (m.$1) { 1 => before, 2 => 2 * before, 3 => before - 3, _ => before };
      if (after != expected) {
        stderr.writeln('$s BY RULE ${m.$1}: I COUNT $before TO $after');
        exit(1);
      }
    }
  }
  final (landingEight, allEight) = Rules.sweep('MU', 8);
  if (landingEight != 0) {
    stderr.writeln('MU IN EIGHT: $landingEight');
    exit(1);
  }

  stdout.writeln(
      'every string reachable from MI on a sheet of ${Rules.longest} letters walked, '
      '${_commas(walked.length)} strings, and the count of I never a multiple of '
      'three among them, MU nowhere; every string of the shape, an M and then I '
      'and U with a count of I not a multiple of three, is reached up to eight '
      'letters, $shaped strings, and nothing else is; rule one and rule four keep '
      'the count of I, rule two doubles it and rule three takes three, on every '
      'move of every string walked; every derivation of six steps swept, 299, and '
      'of eight, ${_commas(allEight)}, and none ends at MU; MIU comes in one step '
      '1 way of 2, MIIU in two 1 of 3, MUI in three 1 of 6, MUIIU in five 2 of '
      '57, and MU never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(6);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.derivations} derivations land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.derivations}, and the count of I said so first');
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
