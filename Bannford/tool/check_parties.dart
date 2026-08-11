import 'dart:io';

import 'package:bannford/banns/parties.dart';
import 'package:bannford/banns/rules.dart';

/// Sweeps every pairing of every shipped party and refuses the bake on
/// any disagreement. The suite runs the asking-rounds besides.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Parties.count; number++) {
    final party = Parties.at(number);
    final rules = Rules(party.prefs);

    var pairings = 0;
    var settles = 0;
    for (final pairing in rules.allPairings()) {
      pairings++;
      if (rules.settled(pairing)) settles++;
    }
    claim(settles == party.settles,
        '${party.name}: $settles settle, written ${party.settles}');

    if (party.sided) {
      final round = rules.askingRound();
      claim(rules.settled(round),
          '${party.name}: the asking-round ended uneasy');
    }

    final verdict = party.winnable
        ? '${party.settles} of $pairings pairings settle'
        : 'none of $pairings pairings settles';
    stdout.writeln(' ${number + 1} ${party.name.padRight(17)} '
        '${party.people} people  $verdict'
        '${party.sided ? '  (asking-round agrees)' : ''}');
  }

  // The odd house, watched breaking: whoever holds Dot is somebody's
  // first choice, and that somebody elopes with them.
  final odd = Rules(Parties.at(4).prefs);
  for (final pairing in odd.allPairings()) {
    final holdsDot = pairing.indexOf(3);
    var first = -1;
    for (var who = 0; who < 3; who++) {
      if (odd.prefs[who].first == holdsDot) first = who;
    }
    claim(first >= 0, 'nobody puts $holdsDot first');
    final elopers = odd.eloping(pairing);
    claim(
        elopers.contains((holdsDot, first)) ||
            elopers.contains((first, holdsDot)),
        'the odd house pairing $pairing held');
  }
  stdout.writeln('\nthe odd house breaks all three ways, each time by '
      'the one wedded to Dot running off with whoever puts them first');

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
