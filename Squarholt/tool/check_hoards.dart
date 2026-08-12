import 'dart:io';

import 'package:squarholt/hoard/hoards.dart';
import 'package:squarholt/hoard/rules.dart';

/// Dials every pair of tiles, holds both laws and the old
/// identity, and refuses the bake on any disagreement: this is
/// what `make hoards` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final hoard in Hoards.all) {
    final ways = Rules.writings(hoard.target).length;
    if (ways != hoard.ways) {
      stderr.writeln('${hoard.name}: sweep finds $ways, '
          'label says ${hoard.ways}');
      exit(1);
    }
  }

  // The remainder law to 200 and Fermat's law under 100.
  if (!Rules.lawsHold()) {
    stderr.writeln('A LAW BROKE');
    exit(1);
  }

  // The writings pinned, pair for pair.
  if ('${Rules.writings(5)}' != '[(1, 2)]' ||
      '${Rules.writings(25)}' != '[(3, 4)]' ||
      '${Rules.writings(50)}' != '[(1, 7), (5, 5)]' ||
      '${Rules.writings(65)}' != '[(1, 8), (4, 7)]' ||
      '${Rules.writings(97)}' != '[(4, 9)]' ||
      Rules.writings(43).isNotEmpty) {
    stderr.writeln('A WRITING MOVED');
    exit(1);
  }

  // The old identity builds the half hundred from five times
  // ten, one writing per sign.
  String sorted(List<(int, int)> pairs) {
    final held = List.of(pairs)
      ..sort((one, two) =>
          one.$1 != two.$1 ? one.$1 - two.$1 : one.$2 - two.$2);
    return '$held';
  }

  final fifty = Rules.composed((1, 2), (1, 3));
  if (sorted(fifty) != sorted(Rules.writings(50))) {
    stderr.writeln('THE IDENTITY MISSED FIFTY: $fifty');
    exit(1);
  }
  final sixtyFive = Rules.composed((1, 2), (2, 3));
  if (sorted(sixtyFive) != sorted(Rules.writings(65))) {
    stderr.writeln('THE IDENTITY MISSED SIXTY-FIVE');
    exit(1);
  }

  // The dead hoard's neighbours both write.
  if ('${Rules.writings(41)}' != '[(4, 5)]' ||
      '${Rules.writings(45)}' != '[(3, 6)]') {
    stderr.writeln('THE NEIGHBOURS MOVED');
    exit(1);
  }

  // Five is the smallest hoard of two different tiles; the
  // twins pay two first.
  if ('${Rules.writings(2)}' != '[(1, 1)]') {
    stderr.writeln('THE TWINS MOVED');
    exit(1);
  }
  for (var hoard = 1; hoard < 5; hoard++) {
    for (final (a, b) in Rules.writings(hoard)) {
      if (a != b) {
        stderr.writeln('A SMALLER DISTINCT PAIR: $hoard');
        exit(1);
      }
    }
  }

  stdout.writeln(
      'every pair of tiles dialled and every hoard to two '
      'hundred read for its remainder: three past a four-times '
      'never writes, every prime one past a four-times under a '
      'hundred writes exactly once, and the old identity builds '
      'the half hundred and sixty-five from their factors, one '
      'writing per sign');
  stdout.writeln('');

  for (var number = 0; number < Hoards.count; number++) {
    final hoard = Hoards.at(number);
    final name = hoard.name.padRight(18);
    stdout.writeln(hoard.winnable
        ? ' ${number + 1} $name ${hoard.task}: '
            '${hoard.ways} writing${hoard.ways == 1 ? '' : 's'} '
            'on the dials land${hoard.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${hoard.task}: none, and the '
            'remainder said so before the dials turned');
  }
}
