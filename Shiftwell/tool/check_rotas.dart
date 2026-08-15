import 'dart:io';

import 'package:shiftwell/rota/rotas.dart';
import 'package:shiftwell/rota/rules.dart';

/// Finishes every rota every way, sweeps every fill of three and
/// four shifts, holds the symmetries, and refuses the bake on any
/// disagreement: this is what `make rotas` runs, and the README
/// quotes its ledger verbatim.
void main() {
  for (final rota in Rotas.all) {
    final ways = Rules(4, rota.fixed).waysBySweep();
    if (ways != rota.ways) {
      stderr.writeln('${rota.name}: sweep finds $ways, label says ${rota.ways}');
      exit(1);
    }
  }

  // All 576 rotas of four, and the first-day symmetry: renaming
  // the hands turns any rota into one whose first day reads 1 2 3
  // 4, so 576 is 24 finishings times the 24 orders of the first
  // day. Read down instead of across, the first station gives 24
  // as well.
  final empty = Rules(4, const {});
  final all = empty.waysBySweep();
  final firstDay = Rules(4, const {(0, 0): 1, (0, 1): 2, (0, 2): 3, (0, 3): 4}).waysBySweep();
  final firstStation = Rules(4, const {(0, 0): 1, (1, 0): 2, (2, 0): 3, (3, 0): 4}).waysBySweep();
  if (all != 576 || firstDay != 24 || firstStation != 24 || firstDay * 24 != all) {
    stderr.writeln('THE ROTAS OF FOUR MOVED: $all, $firstDay, $firstStation');
    exit(1);
  }

  // Evans on the four-rota: every sound fill of three finishes, in
  // 8, 16 or 24 ways; of the sound fills of four, 13,824 never
  // finish.
  final threeSpread = <int, int>{};
  var threes = 0;
  Rules.fills(4, 3, (filled) {
    threes++;
    final ways = Rules(4, filled).waysBySweep();
    if (ways == 0) {
      stderr.writeln('A FILL OF THREE NEVER FINISHES: $filled');
      exit(1);
    }
    threeSpread[ways] = (threeSpread[ways] ?? 0) + 1;
  });
  // And the fills of one and two shifts, 64 and 1,728, all finish.
  var ones = 0, twos = 0;
  Rules.fills(4, 1, (filled) {
    ones++;
    if (!Rules(4, filled).finishes()) {
      stderr.writeln('A FILL OF ONE NEVER FINISHES');
      exit(1);
    }
  });
  Rules.fills(4, 2, (filled) {
    twos++;
    if (!Rules(4, filled).finishes()) {
      stderr.writeln('A FILL OF TWO NEVER FINISHES');
      exit(1);
    }
  });
  if (ones != 64 || twos != 1728) {
    stderr.writeln('THE FILLS OF ONE AND TWO MOVED: $ones, $twos');
    exit(1);
  }
  if (threes != 25920 ||
      threeSpread[8] != 12672 ||
      threeSpread[16] != 12096 ||
      threeSpread[24] != 1152 ||
      threeSpread.length != 3) {
    stderr.writeln('THE FILLS OF THREE MOVED: $threes $threeSpread');
    exit(1);
  }
  var fours = 0, spoilt = 0;
  Rules.fills(4, 4, (filled) {
    fours++;
    if (!Rules(4, filled).finishes()) spoilt++;
  });
  if (fours != 239760 || spoilt != 13824) {
    stderr.writeln('THE FILLS OF FOUR MOVED: $fours, $spoilt SPOILT');
    exit(1);
  }

  // The stuck shift: no hand left for the last shift of the first
  // day, and the sweep finds no finishing.
  final stuckRota = Rotas.at(4);
  final stuck = Rules(4, stuckRota.fixed);
  if (stuck.stuck(stuckRota.fixed) != (0, 3) ||
      stuck.candidates(stuckRota.fixed, (0, 3)).isNotEmpty) {
    stderr.writeln('THE STUCK SHIFT IS NOT STUCK');
    exit(1);
  }
  if (stuck.finishes()) {
    stderr.writeln('THE STUCK ROTA FINISHED');
    exit(1);
  }

  // The diagonal's two finishings are each the other with days
  // and stations swapped.
  final diagonal = <Map<Shift, int>>[];
  Rules(4, Rotas.at(2).fixed).finishings(Rotas.at(2).fixed, (g) => diagonal.add(Map.of(g)));
  if (diagonal.length != 2) {
    stderr.writeln('THE DIAGONAL FINISHES ${diagonal.length} WAYS');
    exit(1);
  }
  for (final shift in stuck.shifts) {
    final swapped = (shift.$2, shift.$1);
    if (diagonal[0][shift] != diagonal[1][swapped]) {
      stderr.writeln('THE DIAGONAL PAIR ARE NOT SWAPS AT $shift');
      exit(1);
    }
  }

  stdout.writeln(
      'every finishing of every rota swept: 576 rotas of four in all, 24 '
      'from a fixed first day and 24 from a fixed first station, which is '
      '576 over the 24 orders of the day; every one of the 25,920 sound '
      'fills of three shifts finishes, in 8, 16 or 24 ways, and the 1,792 '
      'of one or two besides, 13,824 of the '
      '239,760 sound fills of four never do, and the stuck shift has no '
      'hand left for it, the sweep finding no finishing');
  stdout.writeln('');

  for (var number = 0; number < Rotas.count; number++) {
    final rota = Rotas.at(number);
    final name = rota.name.padRight(16);
    stdout.writeln(rota.winnable
        ? ' ${number + 1} $name ${rota.task}: ${rota.ways} '
            'rota${rota.ways == 1 ? '' : 's'} of the sweep '
            'finish${rota.ways == 1 ? 'es' : ''} it'
        : ' ${number + 1} $name ${rota.task}: none, and the stuck shift '
            'said so first');
  }
}
