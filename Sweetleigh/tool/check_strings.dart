import 'dart:io';

import 'package:sweetleigh/string/rules.dart';
import 'package:sweetleigh/string/shares.dart';

/// Cuts every string every way, slides the window, sweeps every
/// string of each size, and refuses the bake on any disagreement:
/// this is what `make strings` runs, and the README quotes its
/// ledger verbatim.
void main() {
  for (final share in Shares.all) {
    final ways = Rules(share.sweets).waysBySweep(share.cuts);
    if (ways != share.ways) {
      stderr.writeln('${share.name}: sweep finds $ways, label says ${share.ways}');
      exit(1);
    }
  }

  // Two kinds, two cuts, every string: the window is built for all
  // 70 strings of four and four and all 924 of six and six, and it
  // shares fairly every time; the fewest cuts fall 36 and 34, then
  // 400 and 524.
  for (final (counts, wantAll, wantOne, wantTwo) in [
    ({'R': 4, 'B': 4}, 70, 36, 34),
    ({'R': 6, 'B': 6}, 924, 400, 524),
  ]) {
    var all = 0, one = 0, two = 0;
    Rules.strings(counts, (sweets) {
      all++;
      final rules = Rules(sweets);
      final built = rules.window();
      if (built == null || built.length > 2 || !rules.fair(built)) {
        stderr.writeln('THE WINDOW FAILED ON $sweets: $built');
        exit(1);
      }
      final fewest = rules.fewest();
      if (fewest == 1) {
        one++;
      } else if (fewest == 2) {
        two++;
      } else {
        stderr.writeln('$sweets NEEDS $fewest CUTS');
        exit(1);
      }
    });
    if (all != wantAll || one != wantOne || two != wantTwo) {
      stderr.writeln('THE SPREAD OF $counts MOVED: $all, $one, $two');
      exit(1);
    }
  }

  // Three kinds: all 90 strings share with three cuts, 36 with one,
  // 42 with two at the fewest and 12 need three.
  final threes = <int, int>{};
  var count3 = 0;
  Rules.strings({'R': 2, 'G': 2, 'B': 2}, (sweets) {
    count3++;
    final fewest = Rules(sweets).fewest();
    threes[fewest] = (threes[fewest] ?? 0) + 1;
    if (fewest > 3) {
      stderr.writeln('$sweets NEEDS $fewest CUTS');
      exit(1);
    }
  });
  if (count3 != 90 || threes[1] != 36 || threes[2] != 42 || threes[3] != 12) {
    stderr.writeln('THE THREE-KIND SPREAD MOVED: $threes of $count3');
    exit(1);
  }
  // And RRGGBB needs three because any three in a row hold two of a
  // kind, read out.
  const rrggbb = 'RRGGBB';
  for (var start = 0; start + 3 <= 6; start++) {
    final three = rrggbb.substring(start, start + 3).split('');
    if (three.toSet().length == 3) {
      stderr.writeln('RRGGBB HOLDS ONE OF EACH IN A ROW AT $start');
      exit(1);
    }
  }

  // The single cut: the seven first pieces, read out.
  final single = Rules('RRRRBBBB');
  final firsts = <String>[];
  for (var gap = 1; gap < 8; gap++) {
    firsts.add(single.pieces([gap]).first);
    if (single.fair([gap])) {
      stderr.writeln('ONE CUT SHARED RRRRBBBB AT $gap');
      exit(1);
    }
  }
  if (firsts.join(' ') != 'R RR RRR RRRR RRRRB RRRRBB RRRRBBB') {
    stderr.writeln('THE FIRST PIECES MOVED: $firsts');
    exit(1);
  }
  // The middle cut is the one cut of the one-cut share, and the
  // window of RRRRBBBB is the middle four.
  if ('${Rules('RRBBBBRR').landing(1)}' != '[4]' ||
      '${Rules('RRRRBBBB').window()}' != '[2, 6]' ||
      '${Rules('RRRRBBBB').landing(2)}' != '[2, 6]') {
    stderr.writeln('THE NAMED CUTS MOVED');
    exit(1);
  }

  stdout.writeln(
      'every set of cuts of every string swept and every piece handed out '
      'in turn: two kinds share with two cuts on all 70 strings of four '
      'and four and all 924 of six and six, the sliding window built for '
      'each, 36 and 400 of them sharing with one cut and 34 and 524 '
      'needing two; three kinds share with three cuts on all 90 strings '
      'of two, two and two, 36 with one, 42 with two, 12 needing three; '
      'and reds-then-blues holds all four reds in any first piece with '
      'two blues, so one cut never shares it and the middle window does');
  stdout.writeln('');

  for (var number = 0; number < Shares.count; number++) {
    final share = Shares.at(number);
    final name = share.name.padRight(16);
    stdout.writeln(share.winnable
        ? ' ${number + 1} $name ${share.task}: ${share.ways} '
            'set${share.ways == 1 ? '' : 's'} of cuts of the sweep '
            'land${share.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${share.task}: none of the seven, '
            'and the first pieces said so');
  }
}
