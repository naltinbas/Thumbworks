import 'dart:io';

import 'package:trickmere/deck/levels.dart';
import 'package:trickmere/deck/rules.dart';

/// Sweeps every layout of every hand, holds the assistant's rule to
/// the sweep and to the whole deck, and refuses the bake on any
/// disagreement: this is what `make tricks` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level: the sweep of layouts against the label, and the rule's
  // layout among the working ones.
  for (final level in Levels.all) {
    final working = Rules.working(level.hand, hiddenFixed: level.hiddenFixed);
    var layouts = 0;
    Rules.layouts(level.hand, (h, _) {
      if (level.hiddenFixed == null || h == level.hiddenFixed) layouts++;
    });
    if (working.length != level.ways || layouts != level.layouts) {
      stderr.writeln('${level.name}: sweep finds ${working.length} of $layouts, label says ${level.ways} of ${level.layouts}');
      exit(1);
    }
    final rule = Rules.rule(level.hand, hiddenFixed: level.hiddenFixed);
    if ((rule == null) == level.winnable) {
      stderr.writeln('${level.name}: the rule ${rule == null ? 'finds nothing' : 'finds $rule'}');
      exit(1);
    }
    if (rule != null && !working.any((w) => w.$1 == rule.$1 && '${w.$2}' == '${rule.$2}')) {
      stderr.writeln('${level.name}: THE RULE\'S LAYOUT DOES NOT WORK: $rule');
      exit(1);
    }
    if (level.hand.toSet().length != 5 || level.hand.any((c) => c < 0 || c > 51)) {
      stderr.writeln('${level.name}: A BAD HAND');
      exit(1);
    }
  }

  // The six orders tell six numbers, round trip, on every three cards
  // of the deck.
  var triples = 0;
  for (var a = 0; a < 52; a++) {
    for (var b = a + 1; b < 52; b++) {
      for (var c = b + 1; c < 52; c++) {
        for (var n = 1; n <= 6; n++) {
          if (Rules.told(Rules.lay([a, b, c], n)) != n) {
            stderr.writeln('$a $b $c: TELLING $n FAILS');
            exit(1);
          }
        }
        triples++;
      }
    }
  }
  // Every two ranks are within six steps round one way or the other.
  for (var r1 = 1; r1 <= 13; r1++) {
    for (var r2 = 1; r2 <= 13; r2++) {
      if (r1 == r2) continue;
      final a = Rules.stepsRound(r1, r2), b = Rules.stepsRound(r2, r1);
      if (a + b != 13 || (a > 6 && b > 6)) {
        stderr.writeln('RANKS $r1 $r2: $a AND $b');
        exit(1);
      }
    }
  }
  // Every hand of five from the whole deck: the rule finds a layout,
  // and it works. That is 2,598,960 hands.
  var hands = 0;
  final hand = List.filled(5, 0);
  void grow(int i, int from) {
    if (i == 5) {
      hands++;
      final r = Rules.rule(hand);
      if (r == null || Rules.named(r.$2) != r.$1) {
        stderr.writeln('HAND $hand: THE RULE FAILS');
        exit(1);
      }
      return;
    }
    for (var c = from; c < 52; c++) {
      hand[i] = c;
      grow(i + 1, c + 1);
    }
  }

  grow(0, 0);
  if (hands != 2598960 || triples != 22100) {
    stderr.writeln('$hands HANDS, $triples TRIPLES');
    exit(1);
  }

  stdout.writeln(
      'every layout of every hand swept, five cards to hide and '
      'twenty-four orders of the rest, and the assistant\'s rule held to '
      'it, then to the whole deck: on every one of the 2,598,960 hands of '
      'five the rule hides a card and lays four the partner names, since '
      'two of five share a suit, any two ranks stand within six steps '
      'round one way, and three cards laid in one of six orders tell one '
      'to six, checked on all 22,100 threes of the deck; the pair of hearts '
      'lays one way, the two pairs two, the three spades three, the wrap '
      'round one, and the lone club, hidden by order, no way at all');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.layouts} layouts land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.layouts}, and the first card said so first');
  }
}
