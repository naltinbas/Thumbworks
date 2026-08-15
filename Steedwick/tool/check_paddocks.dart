import 'dart:io';

import 'package:steedwick/paddock/errands.dart';
import 'package:steedwick/paddock/rules.dart';

/// Rides every standing from home, holds the ring's order to the
/// ride, and refuses the bake on any disagreement: this is what
/// `make paddocks` runs, and the README quotes its ledger verbatim.
void main() {
  if (!Rules.ringHolds()) {
    stderr.writeln('THE KNIGHT\'S MOVES DO NOT RUN ROUND IN ONE RING');
    exit(1);
  }
  final walk = Rules.walk();
  for (final errand in Errands.all) {
    var fewest = 1 << 20;
    var rides = 0;
    for (final entry in walk.fewest.entries) {
      if (!errand.meets(walk.standings[entry.key]!)) continue;
      if (entry.value < fewest) {
        fewest = entry.value;
        rides = walk.rides[entry.key]!;
      } else if (entry.value == fewest) {
        rides += walk.rides[entry.key]!;
      }
    }
    if (rides == 0) fewest = 0;
    if (fewest != errand.fewest || rides != errand.rides) {
      stderr.writeln('${errand.name}: ride finds $fewest moves, $rides rides, '
          'label says ${errand.fewest}, ${errand.rides}');
      exit(1);
    }
  }

  // The ride reaches 280 standings of the 1,680, exactly those with
  // home's order round the ring, and no other; every move from any
  // reached standing keeps the order; sixteen is the farthest.
  final homeOrder = Rules.orderRound(Rules.home);
  var all = 0, ordered = 0;
  Rules.allStandings((s) {
    all++;
    final same = '${Rules.orderRound(s)}' == '$homeOrder';
    if (same) ordered++;
    if (same != walk.fewest.containsKey(Rules.key(s))) {
      stderr.writeln('STANDING $s: ORDER SAME $same, REACHED ${walk.fewest.containsKey(Rules.key(s))}');
      exit(1);
    }
  });
  if (all != 1680 || ordered != 280 || walk.fewest.length != 280) {
    stderr.writeln('THE COUNTS MOVED: $all, $ordered, ${walk.fewest.length}');
    exit(1);
  }
  var farthest = 0;
  for (final entry in walk.fewest.entries) {
    if (entry.value > farthest) farthest = entry.value;
    for (final n in Rules.nextStandings(walk.standings[entry.key]!)) {
      if ('${Rules.orderRound(n)}' != '$homeOrder') {
        stderr.writeln('A MOVE FROM ${entry.key} BROKE THE ORDER');
        exit(1);
      }
    }
  }
  if (farthest != 16 || '$homeOrder' != '[0, 2, 3, 1]') {
    stderr.writeln('THE FARTHEST IS $farthest, THE ORDER $homeOrder');
    exit(1);
  }
  // The colour swap comes out one way only, the half turn, and the
  // pale swap's order is another.
  final halfTurn = Rules.key([8, 6, 2, 0]);
  final otherSwap = Rules.key([6, 8, 2, 0]);
  if (walk.fewest[halfTurn] != 16 || walk.fewest.containsKey(otherSwap)) {
    stderr.writeln('THE COLOUR SWAP MOVED');
    exit(1);
  }
  if ('${Rules.orderRound([2, 0, 6, 8])}' != '[0, 3, 2, 1]' && '${Rules.orderRound([2, 0, 6, 8])}' == '$homeOrder') {
    stderr.writeln('THE PALE SWAP KEEPS THE ORDER');
    exit(1);
  }

  stdout.writeln(
      'every standing ridden to from home, 280 of the 1,680, and they are '
      'exactly the standings that keep home\'s order round the ring, pale '
      'one, dark three, dark four, pale two, since a knight\'s moves on '
      'the outer stalls run round in one ring and every move keeps the '
      'order: pale one reaches the bottom-left in 3, the quarter turn '
      'takes 8, both pales down 13, Guarini\'s colour swap 16 and one way '
      'only, sixteen being as far as any standing lies, and the pale swap '
      'is never reached');
  stdout.writeln('');

  for (var number = 0; number < Errands.count; number++) {
    final errand = Errands.at(number);
    final name = errand.name.padRight(17);
    stdout.writeln(errand.winnable
        ? ' ${number + 1} $name ${errand.task}: ${errand.fewest} moves at the fewest, '
            '${_commas(errand.rides)} fewest ride${errand.rides == 1 ? '' : 's'}'
        : ' ${number + 1} $name ${errand.task}: never, and the ring said so first');
  }
}

/// 4726784 as 4,726,784.
String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
