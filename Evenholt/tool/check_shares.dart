import 'dart:io';

import 'package:evenholt/share/rules.dart';
import 'package:evenholt/share/shares.dart';

/// Deals every share every way, holds Prouhet's pattern and his
/// polynomial to the sweep, and refuses the bake on any
/// disagreement: this is what `make shares` runs, and the README
/// quotes its ledger verbatim.
void main() {
  for (final share in Shares.all) {
    final ways = Rules(share.count, share.degrees).waysBySweep();
    if (ways != share.ways) {
      stderr.writeln('${share.name}: sweep finds $ways, '
          'label says ${share.ways}');
      exit(1);
    }
  }

  // How many half-and-half shares the sweep deals, token 1 left.
  const dealt = {4: 3, 8: 35, 12: 462, 16: 6435};
  for (final entry in dealt.entries) {
    var seen = 0;
    Rules(entry.key, 1).shares((_) => seen++);
    if (seen != entry.value) {
      stderr.writeln('THE SWEEP OF ${entry.key} DEALT $seen SHARES, '
          'NOT ${entry.value}');
      exit(1);
    }
  }

  // The narrowing, power by power, at every count shipped.
  const narrowing = {
    4: [1, 0, 0],
    8: [4, 1, 0],
    12: [29, 1, 0],
    16: [263, 7, 1],
  };
  for (final entry in narrowing.entries) {
    for (var degrees = 1; degrees <= 3; degrees++) {
      final ways = Rules(entry.key, degrees).waysBySweep();
      if (ways != entry.value[degrees - 1]) {
        stderr.writeln('${entry.key} TOKENS TO $degrees POWERS: '
            '$ways WAYS, NOT ${entry.value[degrees - 1]}');
        exit(1);
      }
    }
  }

  // Prouhet's pattern is the sweep's one share of four in sums,
  // of eight in squares, of sixteen in cubes; and it is the
  // sides of his polynomial, which divides by (1 - x) exactly
  // as many times as there are doublings, one more than the
  // powers that agree.
  for (final (count, degrees) in [(4, 1), (8, 2), (16, 3)]) {
    final rules = Rules(count, degrees);
    final pattern = rules.prouhet()!;
    final swept = rules.landing()!;
    if ('$pattern' != '$swept') {
      stderr.writeln('PROUHET PARTS FROM THE SWEEP AT $count');
      exit(1);
    }
    if (!rules.lands(pattern)) {
      stderr.writeln('PROUHET DOES NOT LAND AT $count');
      exit(1);
    }
    final poly = rules.prouhetPolynomial();
    if (poly.length != count) {
      stderr.writeln('THE POLYNOMIAL OF $count HAS ${poly.length} TERMS');
      exit(1);
    }
    for (var token = 1; token <= count; token++) {
      if (poly[token - 1] != (pattern[token - 1] ? -1 : 1)) {
        stderr.writeln('THE POLYNOMIAL SIDES PART AT $count, TOKEN $token');
        exit(1);
      }
    }
    if (rules.doublings != degrees + 1 ||
        Rules.rootAtOne(poly) != degrees + 1) {
      stderr.writeln('THE ROOT AT ONE OF $count IS '
          '${Rules.rootAtOne(poly)}, NOT ${degrees + 1}');
      exit(1);
    }
    // And one power more does not agree, so the root is exact.
    if (Rules(count, degrees + 1).lands(pattern)) {
      stderr.writeln('PROUHET AGREES ONE POWER TOO MANY AT $count');
      exit(1);
    }
  }

  // The dozen's one share, and that it is nobody's doubling.
  final dozen = Rules(12, 2);
  final dozenShare = dozen.landing()!;
  final dozenLeft = [
    for (var token = 1; token <= 12; token++)
      if (!dozenShare[token - 1]) token,
  ];
  if ('$dozenLeft' != '[1, 3, 7, 8, 9, 11]' || dozen.prouhet() != null) {
    stderr.writeln('THE DOZEN MOVED: $dozenLeft');
    exit(1);
  }

  // Four tokens: three pairings, one agreeing in sums, none in
  // squares, read out for the why.
  final four = Rules(4, 2);
  final pairings = <String>[];
  four.shares((right) {
    final left = [
      for (var token = 1; token <= 4; token++)
        if (!right[token - 1]) token,
    ];
    final sums = four.powerSum(right, side: false, degree: 1);
    final other = four.powerSum(right, side: true, degree: 1);
    final squares = four.powerSum(right, side: false, degree: 2);
    final otherSquares = four.powerSum(right, side: true, degree: 2);
    pairings.add('$left:$sums/$other:$squares/$otherSquares');
  });
  if ('$pairings' !=
      '[[1, 2]:3/7:5/25, [1, 3]:4/6:10/20, [1, 4]:5/5:17/13]') {
    stderr.writeln('THE THREE PAIRINGS MOVED: $pairings');
    exit(1);
  }

  stdout.writeln(
      'every half-and-half share of four, eight, twelve and sixteen '
      'tokens dealt and its powers added up: sums agree 1, 4, 29 and '
      '263 ways, squares too 0, 1, 1 and 7 ways, cubes as well 0, 0, 0 '
      'and 1, and the one share of eight that squares and the one of '
      'sixteen that cubes are both Prouhet\'s doubling pattern, whose '
      'polynomial divides by one less x exactly three and four times, '
      'while four tokens pair off three ways and 1 with 4 against 2 '
      'with 3 alone agrees in sums, 5 and 5, and parts in squares, 17 '
      'and 13');
  stdout.writeln('');

  for (var number = 0; number < Shares.count; number++) {
    final share = Shares.at(number);
    final name = share.name.padRight(16);
    stdout.writeln(share.winnable
        ? ' ${number + 1} $name ${share.task}: ${share.ways} '
            'share${share.ways == 1 ? '' : 's'} of the sweep '
            'land${share.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${share.task}: none of the three '
            'pairings, and the squares 17 and 13 said so first');
  }
}
