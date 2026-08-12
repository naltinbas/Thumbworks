import 'dart:io';

import 'package:marklow/mark/lows.dart';
import 'package:marklow/mark/rules.dart';

/// Marks every post, reads every gap, walks every numbering, and
/// refuses the bake on any disagreement: this is what
/// `make marks` runs, and the README quotes its ledger verbatim.
void main() {
  for (final low in Lows.all) {
    final rules = Rules(low.posts, low.lines);
    final ways = rules.ways();
    if (ways != low.ways) {
      stderr.writeln('${low.name}: sweep finds $ways, '
          'label says ${low.ways}');
      exit(1);
    }
    if (!rules.complementsHold()) {
      stderr.writeln('${low.name}: a complement fell from grace');
      exit(1);
    }
  }

  // The ring parities, recomputed on both rings.
  final square = Rules(
      4, const [(0, 1), (1, 2), (2, 3), (0, 3)]);
  final ring5 = Rules(
      5, const [(0, 1), (1, 2), (2, 3), (3, 4), (0, 4)]);
  if (!square.ringParityHolds() || !ring5.ringParityHolds()) {
    stderr.writeln('A RING WORE AN ODD SUM');
    exit(1);
  }
  if (ring5.ways() != 0) {
    stderr.writeln('THE FIVE RING GRACED');
    exit(1);
  }
  // The star's hub: every graceful numbering hubs nought or
  // three.
  final star = Rules(4, const [(0, 1), (0, 2), (0, 3)]);
  var hubs = true;
  star.numberings((numbered) {
    if (star.graceful(numbered) &&
        numbered[0] != 0 &&
        numbered[0] != 3) {
      hubs = false;
    }
  });
  if (!hubs) {
    stderr.writeln('A STAR HUBBED OFF THE ENDS');
    exit(1);
  }

  stdout.writeln(
      'every numbering of every low walked, 24 to 720 by shape: '
      'the graceful counts run 4, 12, 16, 8 and none, every '
      'complement of a graceful numbering stays graceful, every '
      'ring wears an even gap sum, and the five-ring\'s asking '
      'of fifteen is odd');
  stdout.writeln('');

  for (var number = 0; number < Lows.count; number++) {
    final low = Lows.at(number);
    final name = low.name.padRight(18);
    stdout.writeln(low.winnable
        ? ' ${number + 1} $name ${low.task}: ${low.ways} '
            'numbering${low.ways == 1 ? '' : 's'} of the sweep '
            'land${low.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${low.task}: none of the 720, '
            'and the parity said so first');
  }
}
