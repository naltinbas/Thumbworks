import 'dart:io';

import 'package:kerbwell/yard/rules.dart';
import 'package:kerbwell/yard/yards.dart';

/// Lays every joined placing of one to ten slabs, measures every
/// kerb, holds the formula and the box to the sweep, and refuses
/// the bake on any disagreement: this is what `make yards` runs,
/// and the README quotes its ledger verbatim.
void main() {
  final rules = Rules(5);
  for (final yard in Yards.all) {
    final (ways, all, _) = rules.sweep(yard.slabs, yard.asked);
    if (ways != yard.ways || all != yard.placings) {
      stderr.writeln('${yard.name}: sweep finds $ways of $all, '
          'label says ${yard.ways} of ${yard.placings}');
      exit(1);
    }
  }

  // Every count from one to ten: the shortest kerb the sweep finds
  // is the formula's, the box kerb never exceeds the kerb on any
  // placing, and the shortest box agrees with the formula too.
  const wantPlacings = [25, 40, 94, 228, 571, 1436, 3546, 8409, 18874, 39622];
  const wantShortest = [4, 6, 8, 8, 10, 10, 12, 12, 12, 14];
  const wantWays = [25, 40, 94, 16, 96, 24, 190, 52, 9, 176];
  for (var count = 1; count <= 10; count++) {
    var all = 0, shortest = 1 << 20, ways = 0;
    var boxOver = false, joinedAll = true;
    rules.placings(count, (slabs) {
      all++;
      final k = Rules.kerb(slabs);
      if (Rules.boxKerb(slabs) > k) boxOver = true;
      if (!Rules.joined(slabs)) joinedAll = false;
      if (k < shortest) {
        shortest = k;
        ways = 1;
      } else if (k == shortest) {
        ways++;
      }
    });
    if (all != wantPlacings[count - 1] ||
        shortest != wantShortest[count - 1] ||
        ways != wantWays[count - 1] ||
        shortest != Rules.shortestByFormula(count) ||
        Rules.shortestBox(count) != shortest ||
        boxOver ||
        !joinedAll) {
      stderr.writeln('COUNT $count MOVED: $all placings, shortest $shortest '
          '($ways ways), formula ${Rules.shortestByFormula(count)}, '
          'box ${Rules.shortestBox(count)}, boxOver $boxOver');
      exit(1);
    }
  }

  // The kerb is always even, and always the box kerb or more, on
  // every placing of five; and every placing of five sits in a
  // box of two by three at least, so its kerb is ten at the least.
  rules.placings(5, (slabs) {
    final (w, h) = Rules.box(slabs);
    if (w * h < 5 || w + h < 5 || Rules.kerb(slabs).isOdd || Rules.kerb(slabs) < 10) {
      stderr.writeln('A FIVE BROKE THE BOX: $slabs');
      exit(1);
    }
  });

  // The named shapes: sixes in ten are rectangles, nines in twelve
  // the full square.
  var sixRects = 0;
  rules.placings(6, (slabs) {
    if (Rules.kerb(slabs) == 10) {
      final (w, h) = Rules.box(slabs);
      if (w * h != 6) {
        stderr.writeln('A SIX IN TEN IS NOT A RECTANGLE: $slabs');
        exit(1);
      }
      sixRects++;
    }
  });
  var nines = 0;
  rules.placings(9, (slabs) {
    if (Rules.kerb(slabs) == 12) {
      final (w, h) = Rules.box(slabs);
      if (w != 3 || h != 3) {
        stderr.writeln('A NINE IN TWELVE IS NOT THE SQUARE: $slabs');
        exit(1);
      }
      nines++;
    }
  });
  // Tens in fourteen fill a two by five or sit in a three by four
  // with two cells bare.
  var tens = 0, tenRects = 0;
  rules.placings(10, (slabs) {
    if (Rules.kerb(slabs) != 14) return;
    tens++;
    final (w, h) = Rules.box(slabs);
    if (w * h == 10) {
      tenRects++;
    } else if (!((w == 3 && h == 4) || (w == 4 && h == 3))) {
      stderr.writeln('A TEN IN FOURTEEN SITS IN A $w BY $h BOX');
      exit(1);
    }
  });
  if (tens != 176 || tenRects != 8) {
    stderr.writeln('THE TENS MOVED: $tens, $tenRects RECTANGLES');
    exit(1);
  }
  if (sixRects != 24 || nines != 9) {
    stderr.writeln('THE NAMED SHAPES MOVED: $sixRects, $nines');
    exit(1);
  }

  stdout.writeln(
      'every joined placing of one to ten slabs laid on the yard, 25 '
      'through 39,622 of them, and every kerb measured: the shortest at '
      'each count is twice the least whole number not below twice the '
      'square root of the count, 4, 6, 8, 8, 10, 10, 12, 12, 12 and 14, '
      'the kerb round the box never exceeds the kerb itself, and every '
      'placing of five sits in a box of at least two by three, so no '
      'kerb of eight ever holds five');
  stdout.writeln('');

  for (var number = 0; number < Yards.count; number++) {
    final yard = Yards.at(number);
    final name = yard.name.padRight(18);
    stdout.writeln(yard.winnable
        ? ' ${number + 1} $name ${yard.task}: ${_commas(yard.ways)} '
            'placing${yard.ways == 1 ? '' : 's'} of the ${_commas(yard.placings)} '
            'land${yard.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${yard.task}: none of the ${yard.placings}, '
            'and the box said so first');
  }
}

/// 39622 as 39,622.
String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
