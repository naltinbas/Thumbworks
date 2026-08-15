import 'dart:io';

import 'package:stilemere/field/levels.dart';
import 'package:stilemere/field/rules.dart';

/// Walks every route of every field, holds Pascal's rule and the
/// binomial to the walk, and refuses the bake on any disagreement:
/// this is what `make walks` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Every level: the walk against the label, and the three counts
  // against one another.
  for (final level in Levels.all) {
    final f = level.field;
    final (landing, all) = f.sweep();
    if (landing != level.ways || all != level.walks) {
      stderr.writeln('${level.name}: walk finds $landing of $all, label says ${level.ways} of ${level.walks}');
      exit(1);
    }
    // All the routes, three ways: the walk, Pascal's rule with no ponds,
    // and the binomial.
    final open = Field(f.width, f.height);
    if (open.routesFromGate()[f.width][f.height] != all ||
        open.routesToMill()[0][0] != all ||
        Field.choose(f.width + f.height, f.width) != all) {
      stderr.writeln('${level.name}: THE ROUTES DISAGREE');
      exit(1);
    }
    // The landings: the walk against the multiplying rule where there
    // are no ponds, and against Pascal's rule round the ponds where
    // there is one stile at most.
    if (f.ponds.isEmpty && f.byStiles() != landing) {
      stderr.writeln('${level.name}: STILES SAY ${f.byStiles()}, WALK SAYS $landing');
      exit(1);
    }
    if (f.stiles.isEmpty && f.routesFromGate()[f.width][f.height] != landing) {
      stderr.writeln('${level.name}: PASCAL SAYS ${f.routesFromGate()[f.width][f.height]}, WALK SAYS $landing');
      exit(1);
    }
    if (f.stiles.length == 1) {
      final s = f.stiles.first;
      final through = f.routesFromGate()[s.$1][s.$2] * f.routesToMill()[s.$1][s.$2];
      if (through != landing) {
        stderr.writeln('${level.name}: PASCAL THROUGH THE STILE SAYS $through, WALK SAYS $landing');
        exit(1);
      }
    }
    // Every junction: Pascal's two rules agree with the walk's own count.
    final fromGate = f.routesFromGate();
    final toMill = f.routesToMill();
    for (var x = 0; x <= f.width; x++) {
      for (var y = 0; y <= f.height; y++) {
        var walked = 0;
        final open = Field(f.width, f.height, ponds: f.ponds);
        open.walks((w) {
          if (w.contains((x, y))) walked++;
        }, mindPonds: true);
        final product = fromGate[x][y] * toMill[x][y];
        if (walked != product) {
          stderr.writeln('${level.name}: JUNCTION ($x, $y) WALKED $walked, PASCAL $product');
          exit(1);
        }
      }
    }
  }

  // Pascal's rule and the binomial agree on every open field to eight
  // by eight, and the multiplying rule holds for every stile.
  var fields = 0, stilesChecked = 0;
  for (var w = 1; w <= 8; w++) {
    for (var h = 1; h <= 8; h++) {
      final f = Field(w, h);
      fields++;
      final routes = f.routesFromGate();
      if (routes[w][h] != Field.choose(w + h, w) || f.routesToMill()[0][0] != routes[w][h]) {
        stderr.writeln('$w BY $h: PASCAL ${routes[w][h]}, BINOMIAL ${Field.choose(w + h, w)}');
        exit(1);
      }
      for (var x = 0; x <= w; x++) {
        for (var y = 0; y <= h; y++) {
          if (routes[x][y] != Field.choose(x + y, x)) {
            stderr.writeln('$w BY $h AT ($x, $y): PASCAL ${routes[x][y]}, BINOMIAL ${Field.choose(x + y, x)}');
            exit(1);
          }
          // One stile at (x, y): the routes over it are the product.
          final over = Field(w, h, stiles: [(x, y)]).byStiles();
          if (over != Field.choose(x + y, x) * Field.choose(w - x + h - y, w - x)) {
            stderr.writeln('$w BY $h STILE ($x, $y): $over');
            exit(1);
          }
          stilesChecked++;
        }
      }
    }
  }
  // Two stiles neither of which lies right-and-up of the other are
  // never both passed: every such pair on the four-by-four, walked.
  var crossed = 0;
  const four = Field(4, 4);
  for (var ax = 0; ax <= 4; ax++) {
    for (var ay = 0; ay <= 4; ay++) {
      for (var bx = 0; bx <= 4; bx++) {
        for (var by = 0; by <= 4; by++) {
          if (ax < bx && ay > by) {
            final f = Field(4, 4, stiles: [(ax, ay), (bx, by)]);
            if (f.sweep().$1 != 0 || f.byStiles() != 0) {
              stderr.writeln('STILES ($ax, $ay) AND ($bx, $by) BOTH PASSED');
              exit(1);
            }
            crossed++;
          }
        }
      }
    }
  }
  if (four.sweep().$2 != 70 || crossed != 100) {
    stderr.writeln('THE FOUR-BY-FOUR MOVED: $crossed crossed pairs');
    exit(1);
  }

  stdout.writeln(
      'every route of every field walked, and the count read three ways '
      'that agree, by the walk, by Pascal\'s rule at every junction and by '
      'the binomial, on every open field to eight by eight, $fields fields, '
      'with the routes over a stile the product of the two legs at every '
      'one of ${_commas(stilesChecked)} stiles, the routes round a pond Pascal\'s rule '
      'with the pond struck out, and two stiles neither right-and-up of the '
      'other never both passed, $crossed such pairs walked on the four-by-'
      'four');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.walks} routes land it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.walks}, and right-or-up said so first');
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
