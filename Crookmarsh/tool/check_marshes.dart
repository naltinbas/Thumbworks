import 'dart:io';

import 'package:crookmarsh/marsh/marshes.dart';
import 'package:crookmarsh/marsh/rules.dart';

/// Squares every four, walks every hull, sweeps every setting,
/// and refuses the bake on any disagreement: this is what
/// `make frames` runs, and the README quotes its ledger verbatim.
void main() {
  // The two truth tests held together on every four, and the
  // happy ending held on every clear five.
  if (!Rules.lawHolds()) {
    stderr.writeln('THE LAW BROKE');
    exit(1);
  }

  for (final marsh in Marshes.all) {
    final ways = Rules.waysTo(marsh.posts, marsh.asked);
    if (ways != marsh.ways) {
      stderr.writeln('${marsh.name}: sweep finds $ways, '
          'label says ${marsh.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  var clearFours = 0;
  Rules.settings(4, (posts) {
    if (Rules.clearStanding(posts)) clearFours++;
  });
  if (clearFours != 1278 || 240 + 1038 != clearFours) {
    stderr.writeln('THE FOURS MISCOUNTED: $clearFours');
    exit(1);
  }
  var clearFives = 0;
  Rules.settings(5, (posts) {
    if (Rules.clearStanding(posts)) clearFives++;
  });
  if (clearFives != 1668 || 12 + 808 + 848 != clearFives) {
    stderr.writeln('THE FIVES MISCOUNTED: $clearFives');
    exit(1);
  }
  // Frames from five posts come odd, never even.
  for (final even in [0, 2, 4]) {
    if (Rules.waysTo(5, even) != 0) {
      stderr.writeln('AN EVEN FRAME COUNT AT $even');
      exit(1);
    }
  }

  stdout.writeln(
      'every setting of the marsh swept, 1,278 clear fours and '
      '1,668 clear fives: the tuck test and the hull walk agree '
      'on every four there is, every clear five holds one, three '
      'or five frames and never none, and the counts split 240 '
      'crooked to 1,038 true, then 12, 808 and 848');
  stdout.writeln('');

  for (var number = 0; number < Marshes.count; number++) {
    final marsh = Marshes.at(number);
    final name = marsh.name.padRight(20);
    stdout.writeln(marsh.winnable
        ? ' ${number + 1} $name ${marsh.task}: '
            '${withComma(marsh.ways)} '
            'setting${marsh.ways == 1 ? '' : 's'} of the sweep '
            'land${marsh.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${marsh.task}: none of the 1,668, '
            'which is the happy ending theorem doing its work');
  }
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}
