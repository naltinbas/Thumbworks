import 'dart:io';

import 'package:inkfen/ink/lines.dart';
import 'package:inkfen/ink/rules.dart';

/// Dips every inking of every line, holds the alternation and
/// matching laws, and refuses the bake on any disagreement:
/// this is what `make inks` runs, and the README quotes its
/// ledger verbatim.
void main() {
  for (final line in Lines.all) {
    final rules = Rules(line.posts, line.strings);
    final ways = rules.waysTo(line.pot);
    if (ways != line.ways) {
      stderr.writeln('${line.name}: sweep finds $ways, '
          'label says ${line.ways}');
      exit(1);
    }
  }

  // The full four's landings are always the three matchings.
  final four = Rules(4, Lines.at(2).strings);
  if (!four.matchingsHold(3)) {
    stderr.writeln('A FULL FOUR LANDING BROKE THE MATCHINGS');
    exit(1);
  }

  // The mended ring always wears some ink exactly once, and
  // no ink three times.
  final five = Rules(5, Lines.at(3).strings);
  var spread = true;
  five.inkings(3, (inks) {
    if (!five.lands(inks)) return;
    final worn = [0, 0, 0, 0];
    for (final ink in inks) {
      worn[ink]++;
    }
    if (!worn.sublist(1).contains(1)) spread = false;
    if (worn.sublist(1).any((count) => count > 2)) spread = false;
  });
  if (!spread) {
    stderr.writeln('THE MENDED RING MISWORE');
    exit(1);
  }

  // Drop any one string of the odd ring and two inks land the
  // rest, both ways of the path.
  for (var drop = 0; drop < 5; drop++) {
    final strings = [
      for (var at = 0; at < 5; at++)
        if (at != drop) Lines.at(4).strings[at],
    ];
    if (Rules(5, strings).waysTo(2) != 2) {
      stderr.writeln('A DROPPED STRING FAILED TO LAND');
      exit(1);
    }
  }

  stdout.writeln(
      'every inking of every line dipped, 16 and 32 and 64 and '
      '243 and 729 of them: the path and the even ring take two '
      'inks two ways each, the full four takes three inks in '
      'exactly the six orders of its three matchings, the odd '
      'ring refuses two inks outright yet lands thirty ways '
      'with three, and dropping any one of its strings hands '
      'the other four back to two inks');
  stdout.writeln('');

  for (var number = 0; number < Lines.count; number++) {
    final line = Lines.at(number);
    final name = line.name.padRight(18);
    stdout.writeln(line.winnable
        ? ' ${number + 1} $name ${line.task}: ${line.ways} '
            'inking${line.ways == 1 ? '' : 's'} of the sweep '
            'land${line.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${line.task}: none of the 32, '
            'and the alternation said so first');
  }
}
