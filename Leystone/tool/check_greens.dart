import 'dart:io';

import 'package:leystone/ley/greens.dart';
import 'package:leystone/ley/rules.dart';

/// Raises every ring of every green, proves the counting against
/// the search, and refuses the bake on any disagreement: this is
/// what `make greens` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // The Close: no three of its four berths share a line at all.
  const close = [(0, 0), (0, 1), (1, 0), (1, 1)];
  for (var one = 0; one < 4; one++) {
    for (var two = one + 1; two < 4; two++) {
      for (var three = two + 1; three < 4; three++) {
        if (Rules.ley(close[one], close[two], close[three])) {
          stderr.writeln('THE CLOSE LEYS');
          exit(1);
        }
      }
    }
  }

  // The two rings of six each spare a whole diagonal.
  final sixes = <List<(int, int)>>[];
  _rings(3, 6, const [], sixes);
  if (sixes.length != 2) {
    stderr.writeln('SIX-RINGS MISCOUNTED: ${sixes.length}');
    exit(1);
  }
  for (final ring in sixes) {
    final sparesMain = !ring.contains((0, 0)) &&
        !ring.contains((1, 1)) &&
        !ring.contains((2, 2));
    final sparesOther = !ring.contains((0, 2)) &&
        !ring.contains((1, 1)) &&
        !ring.contains((2, 0));
    if (!sparesMain && !sparesOther) {
      stderr.writeln('A SIX-RING SPARES NO DIAGONAL');
      exit(1);
    }
  }

  // The counting against the search, on the hopeless green: seven
  // stones on three rows, every laying-out of the 36.
  if (!Rules.oddStoneAlwaysLeys(3, 7)) {
    stderr.writeln('THE ODD STONE STOOD');
    exit(1);
  }

  stdout.writeln(
      'no three stones share a line, on any slope the green knows; '
      'a green of n rows holds two stones a row at most, so the '
      'stone past 2n must ley, and the search of every ring agrees '
      'with the counting');
  stdout.writeln('');

  for (var number = 0; number < Greens.count; number++) {
    final green = Greens.at(number);
    final (most, ways) = Rules.fullest(green.size);

    if (green.winnable) {
      if (most != green.asked || ways != green.ways) {
        stderr.writeln('${green.name}: search says $most stones '
            '$ways ways, label says ${green.asked} of '
            '${green.ways}');
        exit(1);
      }
    } else {
      if (green.asked != most + 1 ||
          Rules.complete(green.size, const [], green.asked) != null) {
        stderr.writeln('${green.name}: the odd stone stood');
        exit(1);
      }
    }

    final name = green.name.padRight(14);
    final wide = '${green.size} by ${green.size}';
    stdout.writeln(green.winnable
        ? ' ${number + 1} $name $wide  ${green.asked} of '
            '${green.size * green.size} berths stand, '
            '${green.ways} ring${green.ways == 1 ? '' : 's'}'
        : ' ${number + 1} $name $wide  ${green.asked} asked of '
            '${green.size * green.size}: some row must hold three, '
            'and a row is a ley');
  }
}

void _rings(int size, int asked, List<(int, int)> from,
    List<List<(int, int)>> out) {
  final berths = [
    for (var x = 0; x < size; x++)
      for (var y = 0; y < size; y++) (x, y),
  ];
  final ring = List.of(from);

  void grow(int at) {
    if (ring.length == asked) {
      out.add(List.of(ring));
      return;
    }
    for (var next = at; next < berths.length; next++) {
      if (ring.length + (berths.length - next) < asked) break;
      if (Rules.leysWith(ring, berths[next]) != null) continue;
      ring.add(berths[next]);
      grow(next + 1);
      ring.removeLast();
    }
  }

  grow(0);
}
