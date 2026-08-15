import 'dart:io';

import 'package:tablesham/table/parties.dart';
import 'package:tablesham/table/rules.dart';

/// Seats every table every way, holds Touchard's arithmetic to
/// the sweep, and refuses the bake on any disagreement: this
/// is what `make tables` runs, and the README quotes its
/// ledger verbatim.
void main() {
  for (final party in Parties.all) {
    final ways =
        Rules(party.couples).waysBySweep(given: party.given);
    if (ways != party.ways) {
      stderr.writeln('${party.name}: sweep finds $ways, '
          'label says ${party.ways}');
      exit(1);
    }
  }

  // The two counts at every size.
  if (!Rules.lawsHold()) {
    stderr.writeln('A LAW BROKE');
    exit(1);
  }

  // The whole-table turns, counted two ways: the sweep reads
  // each landing for one step shared by every husband, and
  // the turnings are built step by step with no sweep at all.
  // Every step but nought and the last lands, so there are
  // couples less two of them.
  for (final couples in [2, 3, 4, 5]) {
    final rules = Rules(couples);
    final built = rules.turnings();
    if (built.length != couples - 2 ||
        rules.turnsBySweep() != built.length) {
      stderr.writeln('THE TURNS OF $couples PARTED: '
          '${rules.turnsBySweep()} swept, $built built');
      exit(1);
    }
    for (var step = 0; step < couples; step++) {
      if (built.contains(step) == (step == 0 || step == couples - 1)) {
        stderr.writeln('STEP $step OF $couples MISREAD');
        exit(1);
      }
    }
  }

  // The one seating of three turns the table one way: every
  // husband three seats round from his wife.
  final three = Rules(3).landing()!;
  if (Rules(3).turnOf(three) != 1) {
    stderr.writeln('THE THREE DID NOT TURN AS ONE');
    exit(1);
  }
  for (var wife = 0; wife < 3; wife++) {
    final gap = three.indexOf(wife);
    if ((2 * gap + 1 - 2 * wife) % 6 != 3) {
      stderr.writeln('HUSBAND $wife IS NOT THREE SEATS ROUND');
      exit(1);
    }
  }

  // The four-couple pair are mirrors of one another, and both
  // whole-table turns: three seats one way, three the other.
  final four = <List<int>>[];
  Rules(4).seatings((seated) {
    if (Rules(4).lands([...seated])) four.add(List.of(seated));
  });
  if (four.length != 2) {
    stderr.writeln('THE FOURS MOVED');
    exit(1);
  }
  final mirrored = Rules(4).mirror(four[0]);
  if ('$mirrored' != '${four[1]}' || '$mirrored' == '${four[0]}') {
    stderr.writeln('THE FOURS ARE NOT MIRRORS: $four');
    exit(1);
  }
  final turnsOfFour = [
    Rules(4).turnOf(four[0]),
    Rules(4).turnOf(four[1]),
  ]..sort();
  if ('$turnsOfFour' != '[1, 2]') {
    stderr.writeln('THE FOURS DO NOT TURN 1 AND 2: $turnsOfFour');
    exit(1);
  }
  // Step 1 is three seats on round the table, step 2 is five
  // on, which is three seats back the other way.
  if ((2 * 1 + 1) % 8 != 3 || (2 * 2 + 1) % 8 != 8 - 3) {
    stderr.writeln('THE SEAT ARITHMETIC MOVED');
    exit(1);
  }

  // Three of the thirteen turn the table as one; with the host
  // held in his chair, one of the five does, and it is the
  // turn of two gaps.
  if (Rules(5).turnsBySweep() != 3) {
    stderr.writeln('THE FIVES DO NOT TURN THRICE');
    exit(1);
  }
  final host = Parties.at(2).given!;
  if (Rules(5).turnsBySweep(given: host) != 1 ||
      Rules(5).turnOf(Rules(5).turned(2))! != 2 ||
      Rules(5).turned(2)[host.$1] != host.$2) {
    stderr.writeln('THE HELD HOST DOES NOT TURN ONCE');
    exit(1);
  }

  // Two couples: both seatings, two quarrels apiece.
  var seatingsOfTwo = 0;
  Rules(2).seatings((seated) {
    seatingsOfTwo++;
    if (Rules(2).quarrels([...seated]).length != 2) {
      stderr.writeln('A SEATING OF TWO QUARRELLED '
          '${Rules(2).quarrels([...seated]).length} TIMES');
      exit(1);
    }
  });
  if (seatingsOfTwo != 2) {
    stderr.writeln('TWO COUPLES SEAT $seatingsOfTwo WAYS');
    exit(1);
  }

  stdout.writeln(
      'every seating of every table swept and held to '
      'Touchard\'s arithmetic, falls and rises over the couples '
      'parted: nought ways for two couples, one for three, two '
      'for four, thirteen for five, and five once the host is '
      'held in his chair; the whole-table turns counted both '
      'ways too, one and two and three of them, the pair of '
      'four read as mirrors, and both seatings of two quarrel '
      'twice over');
  stdout.writeln('');

  for (var number = 0; number < Parties.count; number++) {
    final party = Parties.at(number);
    final name = party.name.padRight(18);
    stdout.writeln(party.winnable
        ? ' ${number + 1} $name ${party.task}: ${party.ways} '
            'seating${party.ways == 1 ? '' : 's'} of the sweep '
            'land${party.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${party.task}: none of the two, '
            'and the circle of four said so first');
  }
}
