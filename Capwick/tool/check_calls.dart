import 'dart:io';

import 'package:capwick/line/levels.dart';
import 'package:capwick/line/play.dart';
import 'package:capwick/line/rules.dart';

/// Runs the plan down every deal of every line, counts every plan the
/// first man could have, and refuses the bake on any disagreement:
/// this is what `make calls` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Every level: the plan on every deal, against the label.
  for (final level in Levels.all) {
    final n = level.prisoners;
    final (allBut, allSaved, _) = Rules.sweep(n);
    final ways = level.warden ? 0 : allBut;
    if (ways != level.ways || (1 << n) != level.deals) {
      stderr.writeln('${level.name}: sweep finds $ways of ${1 << n}, label says ${level.ways} of ${level.deals}');
      exit(1);
    }
    if (allBut != (1 << n) || allSaved != (1 << (n - 1))) {
      stderr.writeln('${level.name}: the plan saves all but the first on $allBut of ${1 << n}, all on $allSaved');
      exit(1);
    }
    // The plan lands the level's own deal, called through Play.
    var play = Play.of(level);
    while (!play.allCalled) {
      play = play.tap(Rules.planCall(play.caps, play.current, play.calls));
    }
    if (play.isDone != level.winnable) {
      stderr.writeln('${level.name}: the plan ${play.isDone ? 'lands' : 'misses'} the dealt line');
      exit(1);
    }
    if (level.warden && play.rightCount != n - 1) {
      stderr.writeln('${level.name}: the warden line saves ${play.rightCount}');
      exit(1);
    }
  }

  // Every line of two to eight men: the plan saves all but the first on
  // every deal, saves the first on exactly half, and the right calls
  // over all deals are (n - 1) 2^n + 2^(n - 1).
  for (var n = 2; n <= 8; n++) {
    final (allBut, allSaved, right) = Rules.sweep(n);
    if (allBut != (1 << n) || allSaved != (1 << (n - 1)) || right != (n - 1) * (1 << n) + (1 << (n - 1))) {
      stderr.writeln('$n MEN: $allBut, $allSaved, $right');
      exit(1);
    }
  }

  // Every plan the first man could have, for lines of two to five: right
  // on exactly half the deals, no more and no less.
  var plansCounted = 0;
  for (var n = 2; n <= 5; n++) {
    final (fewest, most, plans) = Rules.firstManEveryPlan(n);
    if (fewest != (1 << (n - 1)) || most != (1 << (n - 1))) {
      stderr.writeln('$n MEN: the first man is right on $fewest to $most deals');
      exit(1);
    }
    plansCounted += plans;
  }
  if (plansCounted != 4 + 16 + 256 + 65536) {
    stderr.writeln('$plansCounted PLANS COUNTED');
    exit(1);
  }

  // The named deal: caps 0, 1, 1, 0, 1 from the back; the plan calls
  // black, black, black, white, black, and the first man happens to be
  // wrong.
  final five = Rules.deal(5, 0x16);
  final (calls, ok) = Rules.plan(five);
  if ('$five' != '[false, true, true, false, true]' ||
      '$calls' != '[true, true, true, false, true]' ||
      '$ok' != '[false, true, true, true, true]') {
    stderr.writeln('THE NAMED DEAL MOVED: $five $calls $ok');
    exit(1);
  }

  stdout.writeln(
      'the plan run down every deal of every line of two to eight men, '
      '4 through 256 deals, and it saves every man but the first on every '
      'deal and the first on exactly half; every plan the first man could '
      'have counted for lines of two to five, 4 and 16 and 256 and 65,536 '
      'plans, and each is right on exactly half the deals, no plan more; '
      'the right calls over all deals come to (n - 1) times 2^n plus '
      '2^(n - 1) at every length, and on the dealt five, caps white, '
      'black, black, white, black from the back, the plan calls black, '
      'black, black, white, black and the first man alone is wrong');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(14);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: the plan lands it on ${level.ways} of the '
            '${level.deals} deals'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.deals}, and the first man\'s plans said so first');
  }
}
