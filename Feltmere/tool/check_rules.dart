import 'dart:io';

import 'package:feltmere/hat/levels.dart';
import 'package:feltmere/hat/play.dart';
import 'package:feltmere/hat/rules.dart';

/// Tries every agreement the three villagers can come to against every
/// hatting, counts the wins two ways, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_rules.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  check(Rules.hattings.length == 8, 'hattings: ${Rules.hattings.length}');
  check(Rules.sights.length == 4, 'sights: ${Rules.sights.length}');

  // Every villager sees the other two and never their own hat.
  for (final hats in Rules.hattings) {
    for (var who = 0; who < Rules.villagers; who++) {
      final seen = Rules.sightOf(hats, who);
      check(seen.length == 2, 'a villager sees ${seen.length} hats');
      final sight = Rules.sightNumber(hats, who);
      check(Rules.sights[sight][0] == seen[0] && Rules.sights[sight][1] == seen[1],
          'the sight number of $hats for $who');
      // The other hatting with the same sight differs only in this
      // villager's own hat, which is what the count below turns on.
      final other = List.of(hats)..[who] = 1 - hats[who];
      check(Rules.sightNumber(other, who) == sight,
          'the two hattings of a sight do not match');
    }
  }

  var agreements = 0, best = 0, atBest = 0, quietBest = 0;
  final spread = <int, int>{};
  final ways = <String, int>{for (final level in Levels.all) level.name: 0};
  final cheapest = <String, int>{};
  for (final agreement in Rules.agreements()) {
    agreements++;
    final wins = Rules.wins(agreement);
    spread[wins] = (spread[wins] ?? 0) + 1;

    // The count that holds the whole thing up: a word is wrong on
    // exactly one of the two hattings its sight allows, so the wrong
    // words are as many as the words.
    check(Rules.wrongs(agreement) == Rules.words(agreement),
        'the wrong words of $agreement');

    if (wins > best) {
      best = wins;
      atBest = 1;
    } else if (wins == best) {
      atBest++;
    }
    if (Rules.hasQuiet(agreement) && wins > quietBest) quietBest = wins;

    for (final level in Levels.all) {
      if (!level.meets(agreement)) continue;
      ways[level.name] = ways[level.name]! + 1;
      final taps = Rules.taps(agreement);
      final held = cheapest[level.name];
      if (held == null || taps < held) cheapest[level.name] = taps;
    }
  }
  check(agreements == 531441, 'agreements swept: $agreements');
  check(best == 6 && atBest == 4, 'the best: $best on $atBest agreements');
  check(quietBest == 4, 'the best with a villager silent: $quietBest');
  check(spread[7] == null && spread[8] == null, 'something won seven');
  check(spread[4] == 25922 && spread[5] == 624 && spread[6] == 4,
      'the spread: $spread');

  // The asks.
  for (final level in Levels.all) {
    check(ways[level.name] == level.ways,
        '${level.name}: ${ways[level.name]} against ${level.ways}');
    if (level.winnable) {
      check(level.meets(level.aim), '${level.name}: the aim misses');
      check(Rules.taps(level.aim) == cheapest[level.name],
          '${level.name}: the aim takes ${Rules.taps(level.aim)} taps, '
          'cheapest ${cheapest[level.name]}');
    } else {
      check(level.aim.isEmpty, '${level.name} has an aim');
      check(cheapest[level.name] == null, '${level.name} was landed');
    }
  }

  // The plainest agreement of all: speak when the two you see match,
  // and name the other colour.
  final matching = [
    for (var who = 0; who < Rules.villagers; who++)
      [
        for (final sight in Rules.sights)
          sight[0] == sight[1] ? 1 - sight[0] : Rules.quiet,
      ],
  ];
  check(Rules.wins(matching) == 6, 'the matching rule wins ${Rules.wins(matching)}');
  check(Rules.losses(matching).join(' and ') == 'BBB and WWW',
      'the matching rule loses ${Rules.losses(matching)}');

  // The pointer lands every ask it can, in the fewest taps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 30) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      final was = play.agreement[aim.$1][aim.$2];
      var turned = play.turn(aim.$1, aim.$2);
      while (turned.agreement[aim.$1][aim.$2] != level.aim[aim.$1][aim.$2] &&
          turned.agreement[aim.$1][aim.$2] != was) {
        turned = turned.turn(aim.$1, aim.$2);
      }
      play = turned;
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  if (failed) {
    stderr.writeln('the village is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every agreement the three villagers can come to taken, a say for '
        'each of the four sights each of them can have, ${commas(agreements)} '
        'agreements, and each tried against all eight hattings: the wrong '
        'words an agreement calls for are as many as the words themselves on '
        'every one of them, since a word is right on one of the two hattings '
        'its sight allows and wrong on the other')
    ..write('; the hattings won run ')
    ..write([
      for (final at in spread.keys.toList()..sort())
        '${commas(spread[at]!)} agreements winning $at'
    ].join(', '))
    ..write(', so $best is the best there is, $atBest agreements reach it, '
        'and none of the ${commas(agreements)} wins seven or eight')
    ..write('; with one villager silent throughout the best is $quietBest, '
        'half the hattings, which is what one speaker gets on their own')
    ..write('; the plainest of the four best agreements is to speak only '
        'when the two hats you see match and then name the other colour, '
        'which loses ${Rules.losses(matching).join(' and ')} and wins the '
        'other six');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(agreements)} agreements land '
            'it, the cheapest in ${level.fewest} taps'
        : 'none of the ${commas(agreements)}, and the count of wrong words '
            'says why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
