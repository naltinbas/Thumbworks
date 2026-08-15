import 'dart:io';

import 'package:crustleigh/show/levels.dart';
import 'package:crustleigh/show/rules.dart';

/// Sweeps every show of three ballots over three and four pies, counts
/// it two ways, holds the ring to the turnings and the modest winner to
/// the lemma, and refuses the bake on any disagreement: this is what
/// `make shows` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, both ways.
  for (final level in Levels.all) {
    final (met, all) = Rules.sweep(level.pies, level.meets);
    final (metBags, allBags) = Rules.sweepBags(level.pies, level.meets);
    if (met != level.ways || all != level.settings) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
    if (metBags != met || allBags != all) {
      stderr.writeln('${level.name}: THE BAGS COUNT $metBags OF $allBags, THE SWEEP $met OF $all');
      exit(1);
    }
  }

  // Three pies: the rings are exactly the turnings; every other show has
  // a pie beating both others; that pie is somebody's first every time,
  // and never has fewer points than another; and the lemma's sum holds
  // on every show for a pie first on no ballot.
  var rings = 0, turnings = 0, winners = 0, modest = 0, betrayed = 0, lemma = 0;
  Rules.sweep(3, (p) {
    final isRing = Rules.ring(p, 3), isTurning = Rules.allRotations(p);
    if (isRing) rings++;
    if (isTurning) turnings++;
    if (isRing != isTurning) {
      stderr.writeln('A RING THAT IS NOT THE TURNINGS, OR THE OTHER WAY: $p');
      exit(1);
    }
    final w = Rules.condorcetWinner(p, 3);
    if (w != null) {
      winners++;
      if (!Rules.firsts(p).contains(w)) modest++;
      final pts = Rules.points(p, 3);
      if (pts.any((x) => x > pts[w])) betrayed++;
    }
    if ((w == null) != isRing) {
      stderr.writeln('NO WINNER AND NO RING, OR BOTH: $p');
      exit(1);
    }
    for (var pie = 0; pie < 3; pie++) {
      if (Rules.firsts(p).contains(pie)) continue;
      final others = [0, 1, 2].where((q) => q != pie).toList();
      final sum = Rules.count(p, pie, others[0]) + Rules.count(p, pie, others[1]);
      if (sum > 3) {
        stderr.writeln('A PIE FIRST ON NO BALLOT RANKED OVER THE OTHERS $sum TIMES: $p');
        exit(1);
      }
      lemma++;
    }
    return false;
  });
  if (rings != 12 || turnings != 12 || winners != 204 || modest != 0 || betrayed != 0) {
    stderr.writeln('THREE PIES: $rings RINGS, $turnings TURNINGS, $winners WINNERS, $modest MODEST, $betrayed BETRAYED');
    exit(1);
  }
  if (lemma == 0) {
    stderr.writeln('THE LEMMA WAS NEVER TRIED');
    exit(1);
  }

  // Four pies: the ring never has a winner, and the other counts.
  final (noWinner, _) = Rules.sweep(4, (p) => Rules.condorcetWinner(p, 4) == null);
  final (ringWithWinner, _) = Rules.sweep(4, (p) => Rules.ring(p, 4) && Rules.condorcetWinner(p, 4) != null);
  final (threeRing, _) = Rules.sweep(4, (p) {
    for (var a = 0; a < 4; a++) {
      for (var b = 0; b < 4; b++) {
        for (var c = 0; c < 4; c++) {
          if (a == b || b == c || a == c) continue;
          if (Rules.beats(p, a, b) && Rules.beats(p, b, c) && Rules.beats(p, c, a)) return true;
        }
      }
    }
    return false;
  });
  if (noWinner != 1536 || ringWithWinner != 0 || threeRing != 2352) {
    stderr.writeln('FOUR PIES: $noWinner NO WINNER, $ringWithWinner RINGS WITH A WINNER, $threeRing THREE-RINGS');
    exit(1);
  }
  final modestFirst = Rules.first(4, Levels.at(3).meets);
  if (modestFirst.toString() != '[[0, 1, 2, 3], [2, 1, 0, 3], [3, 1, 0, 2]]') {
    stderr.writeln('THE FIRST MODEST SHOW IS $modestFirst');
    exit(1);
  }
  final ringFirst = Rules.first(3, Levels.at(0).meets);
  if (ringFirst.toString() != '[[0, 1, 2], [1, 2, 0], [2, 0, 1]]') {
    stderr.writeln('THE FIRST RING IS $ringFirst');
    exit(1);
  }

  stdout.writeln(
      'every show of three ballots over three pies swept, 216 shows, and over four '
      'pies, 13,824, each count read twice, ballot by ballot and by the bag of '
      'ballots dealt to the judges six, three or one ways: with three pies the '
      'majority runs in a ring in 12 shows, exactly the shows whose ballots are '
      'the three turnings of one ranking, and every other show, 204, has a pie '
      'that beats both others, which is somebody\'s first choice in all 204 and '
      'never has fewer points than another; a pie first on no ballot is ranked '
      'over the other two at most three times between them on every show, so '
      'the modest winner never comes; with four pies the ring runs round all four '
      'in 720 shows, never with a pie beating every other, 1,536 shows have no '
      'such pie, 2,352 have some three pies in a ring, 288 have a pie beating '
      'every other while another has more points, and 192 have a pie beating '
      'every other that is first on no ballot, the first of them bramble second '
      'on all three ballots');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(25);
    final settings = _commas(level.settings);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the $settings shows land it'
        : ' ${number + 1} $name ${level.task}: none of the $settings, and the lemma said so first');
  }
}

String _commas(int n) {
  final s = '$n';
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}
