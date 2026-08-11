import 'dart:io';

import 'package:shadewell/plot/plots.dart';
import 'package:shadewell/plot/rules.dart';

/// Stacks every filling of every plot and runs the line-solver, and
/// refuses the bake on any disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Plots.count; number++) {
    final plot = Plots.at(number);
    final rules = Rules(plot.wide, plot.high);

    final all = rules.solutionsOf(plot.rowTallies, plot.colTallies);
    claim(all.length == plot.solutions,
        '${plot.name}: ${all.length} pictures fit, written '
        '${plot.solutions}');

    final picture = plot.picture;
    if (picture != null) {
      claim(all.length == 1 && all.single.join(',') == picture.join(','),
          '${plot.name}: the picture is not the one written');
      final solved = rules.lineSolve(plot.rowTallies, plot.colTallies);
      claim(
          solved != null &&
              rules.complete(solved.$1, solved.$2) &&
              solved.$1.join(',') == picture.join(','),
          '${plot.name}: reason alone does not reach the picture');
    }
    if (plot.solutions == 0) {
      claim(plot.rowsAsk != plot.colsAsk,
          '${plot.name}: dead but the tallies ask alike');
    }

    final verdict = plot.solutions == 1
        ? 'one picture, and the line-solver reaches it'
        : plot.solutions == 0
            ? 'no picture: rows ask ${plot.rowsAsk}, columns '
                '${plot.colsAsk}'
            : '${plot.solutions} pictures fit, and the tallies cannot '
                'tell them apart';
    stdout.writeln(' ${number + 1} ${plot.name.padRight(16)} '
        '${plot.wide} by ${plot.high}  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
