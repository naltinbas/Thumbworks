import 'dart:io';

import 'package:fusewick/fuse/level.dart';
import 'package:fusewick/fuse/levels.dart';
import 'package:fusewick/fuse/play.dart';
import 'package:fusewick/fuse/rules.dart';

/// Sweeps every plan of lighting for every count of fuses, and refuses
/// the bake on any disagreement: this is what `make burns` runs, and
/// the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, and its plan played through
  // the play to the time asked.
  for (final level in Levels.all) {
    final (times, striking, plans) = Rules.sweep(level.fuses, level.asked);
    if (striking != level.ways || plans != level.plans) {
      stderr.writeln('${level.name}: sweep finds $striking of $plans, label says ${level.ways} of ${level.plans}');
      exit(1);
    }
    if (times.contains(level.asked) != level.winnable) {
      stderr.writeln('${level.name}: the times ${times.toList()} and the label disagree');
      exit(1);
    }
    if (level.winnable) {
      final plan = Rules.plan(level.fuses, level.asked)!;
      var play = Play.of(level);
      var guard = 0;
      while (!play.isDone && guard++ < 20) {
        final n = play.next;
        if (n == null) break;
        play = n.$1 == 'light' ? play.light(n.$2, n.$3) : play.burn();
      }
      if (!play.isDone) {
        stderr.writeln('${level.name}: THE PLAN $plan DOES NOT STRIKE ${level.asked}');
        exit(1);
      }
    }
  }

  // The times one, two and three fuses can strike, and every burnout on
  // whole quarter-minutes.
  final byCount = <int, List<int>>{};
  for (var n = 1; n <= 3; n++) {
    final (times, _, plans) = Rules.sweep(n, -1);
    byCount[n] = times.toList()..sort();
    if (times.any((t) => t % 2 != 0)) {
      stderr.writeln('$n FUSES: A BURNOUT OFF THE HALF MINUTE');
      exit(1);
    }
    if (plans != [3, 19, 231][n - 1]) {
      stderr.writeln('$n FUSES: $plans PLANS');
      exit(1);
    }
  }
  if ('${byCount[1]}' != '[120, 240]' ||
      '${byCount[2]}' != '[120, 180, 240, 360, 480]' ||
      '${byCount[3]}' != '[120, 180, 210, 240, 270, 300, 360, 420, 480, 600, 720]') {
    stderr.writeln('THE TIMES MOVED: $byCount');
    exit(1);
  }
  // Two fuses strike only multiples of fifteen; three strike multiples
  // of seven and a half.
  if (byCount[2]!.any((t) => t % 60 != 0) || byCount[3]!.any((t) => t % 30 != 0)) {
    stderr.writeln('THE MULTIPLES MOVED');
    exit(1);
  }

  String words(List<int> ts) => ts.map(Level.minutes).map((w) => w.replaceAll(' minutes', '')).join(', ');
  stdout.writeln(
      'every plan of lighting swept for one, two and three fuses, 3 and 19 '
      'and 231 plans, each fuse an hour end to end and lit at either end at '
      'the start or at a burnout: one fuse strikes ${words(byCount[1]!)}, '
      'two strike ${words(byCount[2]!)}, all multiples of fifteen, and three '
      'strike ${words(byCount[3]!)}, all multiples of seven and a half; every '
      'burnout falls on a whole half minute, and twenty is struck by no plan '
      'of two');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(24);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.plans} plans strike${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.plans}, and the first burnout said so first');
  }
}
