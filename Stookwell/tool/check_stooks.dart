import 'dart:io';

import 'package:stookwell/stook/levels.dart';
import 'package:stookwell/stook/rules.dart';

/// Walks every partition of every harvest, holds Euler's identity
/// and Glaisher's turn to the walk, and refuses the bake on any
/// disagreement: this is what `make stooks` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the walk.
  for (final level in Levels.all) {
    var all = 0, ways = 0;
    Rules.partitions(level.sheaves, (parts) {
      all++;
      if (level.meets(parts)) ways++;
    });
    if (all != level.partitions || ways != level.ways) {
      stderr.writeln('${level.name}: walk finds $ways of $all, label says ${level.ways} of ${level.partitions}');
      exit(1);
    }
  }

  // Euler's identity: the walk's two counts agree for every harvest to
  // thirty, and the two products agree to sixty.
  final distinct = Rules.distinctByProduct(60);
  final odd = Rules.oddByProduct(60);
  var walked = 0;
  for (var n = 1; n <= 30; n++) {
    final (all, d, o) = Rules.census(n);
    if (d != o || d != distinct[n] || o != odd[n]) {
      stderr.writeln('$n SHEAVES: walk $d apart and $o odd, products ${distinct[n]} and ${odd[n]}');
      exit(1);
    }
    walked += all;
  }
  for (var n = 0; n <= 60; n++) {
    if (distinct[n] != odd[n]) {
      stderr.writeln('$n SHEAVES: THE PRODUCTS PART, ${distinct[n]} AND ${odd[n]}');
      exit(1);
    }
  }
  if (distinct[60] != 10880 || distinct[7] != 5 || distinct[10] != 10 || distinct[12] != 15) {
    stderr.writeln('THE PRODUCTS MOVED: ${distinct[7]} ${distinct[10]} ${distinct[12]} ${distinct[60]}');
    exit(1);
  }

  // Glaisher's turn, both ways, on every partition to twenty-five: odd
  // to apart and back is the partition itself, and so is apart to odd
  // and back.
  var turned = 0;
  for (var n = 1; n <= 25; n++) {
    Rules.partitions(n, (parts) {
      final sum = parts.fold(0, (a, b) => a + b);
      if (Rules.allOdd(parts)) {
        final m = Rules.merged(parts);
        if (!Rules.allDistinct(m) || m.fold(0, (a, b) => a + b) != sum || '${Rules.split(m)}' != '$parts') {
          stderr.writeln('GLAISHER FAILS ON $parts: $m, back ${Rules.split(m)}');
          exit(1);
        }
        turned++;
      }
      if (Rules.allDistinct(parts)) {
        final s = Rules.split(parts);
        if (!Rules.allOdd(s) || s.fold(0, (a, b) => a + b) != sum || '${Rules.merged(s)}' != '$parts') {
          stderr.writeln('GLAISHER FAILS ON $parts: $s, back ${Rules.merged(s)}');
          exit(1);
        }
        turned++;
      }
    });
  }
  if ('${Rules.merged([3, 3, 1])}' != '[6, 1]' || '${Rules.merged([1, 1, 1, 1, 1, 1, 1])}' != '[4, 2, 1]' ||
      '${Rules.split([4, 3])}' != '[3, 1, 1, 1, 1]') {
    stderr.writeln('THE NAMED TURNS MOVED');
    exit(1);
  }

  // Four stooks apart need ten sheaves at the least, and k stooks
  // k(k + 1)/2: every harvest short of that stands in no such stooks,
  // and the harvest that just makes it stands one way, 1, 2, ..., k.
  for (var k = 1; k <= 7; k++) {
    final fewest = Rules.fewestFor(k);
    for (var n = 1; n < fewest; n++) {
      if (Rules.distinctWithParts(n, k) != 0) {
        stderr.writeln('$n SHEAVES STAND IN $k STOOKS APART');
        exit(1);
      }
    }
    if (Rules.distinctWithParts(fewest, k) != 1) {
      stderr.writeln('$fewest SHEAVES STAND IN $k STOOKS APART ${Rules.distinctWithParts(fewest, k)} WAYS');
      exit(1);
    }
  }
  if (Rules.fewestFor(4) != 10 || Rules.distinctWithParts(9, 4) != 0 || Rules.census(9).$2 != 8) {
    stderr.writeln('THE NINE MOVED');
    exit(1);
  }

  stdout.writeln(
      'every partition of every harvest to thirty sheaves walked, '
      '${_commas(walked)} of them, and the stooks all apart counted level with '
      'the stooks all odd at every harvest, as Euler says, the two '
      'products (1 + x^k) over every k and 1/(1 - x^k) over odd k agreeing '
      'with the walk and with each other to sixty sheaves, 10,880 ways '
      'each at sixty; Glaisher\'s turn taken both ways on every one of '
      '${_commas(turned)} partitions to twenty-five and always coming '
      'back to itself; and k stooks apart never standing in fewer than '
      'k(k + 1)/2 sheaves, one way at exactly that, for k to seven');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(22);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.partitions} partitions land it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.partitions}, and 1 + 2 + 3 + 4 said so first');
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
