import 'dart:io';

import 'package:benchwood/bench/levels.dart';
import 'package:benchwood/bench/play.dart';
import 'package:benchwood/bench/rules.dart';

/// Sweeps every job card there is at every bench size, both by Belady's
/// rule and by trying every eviction, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_walks.dart
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

  // Every job card of ten calls on at most four tools, with the tools
  // named in the order they are first called, so renaming makes no new
  // cards.
  const calls = 10, tools = 4;
  var cards = 0, checks = 0, worse = 0, sameByOldest = 0;
  final byTools = <int, int>{};
  for (final card in Rules.cards(calls, tools)) {
    cards++;
    byTools[card.reduce((a, b) => a > b ? a : b) + 1] =
        (byTools[card.reduce((a, b) => a > b ? a : b) + 1] ?? 0) + 1;
    for (var slots = 1; slots <= tools; slots++) {
      checks++;
      final byRule = Rules.walksByRule(card, slots);
      final fewest = Rules.fewestWalks(card, slots);
      check(byRule == fewest,
          'card ${Rules.tellCard(card)} on $slots slots: $byRule by the rule, '
          '$fewest by trying everything');
      final oldest = Rules.walksByOldest(card, slots);
      check(oldest >= byRule, 'the oldest rule beat Belady on $card');
      if (oldest > byRule) worse++;
      if (oldest == byRule) sameByOldest++;
      // More room never costs Belady's rule a walk.
      if (slots > 1) {
        check(Rules.walksByRule(card, slots) <= Rules.walksByRule(card, slots - 1),
            'a bigger bench cost Belady a walk on $card');
      }
    }
  }
  check(cards == 43947, 'cards swept: $cards');
  check(checks == 175788, 'checks made: $checks');

  // The oldest-first rule can want more walks on a bigger bench, which
  // Belady's cannot. It takes longer cards to show it, so this sweep
  // runs the two rules alone, without the eviction search.
  const longCalls = 12, longTools = 5;
  var longCards = 0, anomalies = 0;
  final anomalyCards = <String>{};
  var anomalyAt = 0;
  for (final card in Rules.cards(longCalls, longTools)) {
    longCards++;
    var oldestBefore = Rules.walksByOldest(card, 1);
    var ruleBefore = Rules.walksByRule(card, 1);
    for (var slots = 2; slots <= longTools; slots++) {
      final oldest = Rules.walksByOldest(card, slots);
      final byRule = Rules.walksByRule(card, slots);
      if (oldest > oldestBefore) {
        anomalies++;
        anomalyCards.add(Rules.tellCard(card));
        anomalyAt = slots;
      }
      check(byRule <= ruleBefore, 'a bigger bench cost Belady a walk on $card');
      oldestBefore = oldest;
      ruleBefore = byRule;
    }
  }
  check(longCards == 2079475, 'long cards swept: $longCards');
  check(anomalyCards.length == 1, 'anomaly cards: $anomalyCards');
  check(anomalyCards.single == Rules.tellCard(Levels.at(2).card),
      'the anomaly card is ${anomalyCards.single}');
  check(anomalyAt == 4, 'the anomaly shows at $anomalyAt slots');

  // The asks, their counts and the way they are meant to be played.
  for (final level in Levels.all) {
    final fewest = Rules.fewestWalks(level.card, level.slots);
    final (runs, good) = Rules.plays(level.card, level.slots, level.walks);
    check(runs == level.runs, '${level.name}: $runs runs against ${level.runs}');
    check(good == level.ways, '${level.name}: $good ways against ${level.ways}');
    check(level.fewest == fewest, '${level.name}: the level fewest');
    if (level.winnable) {
      check(fewest == level.walks,
          '${level.name}: the ask wants ${level.walks}, the fewest is $fewest');
      check(Rules.walksByRule(level.card, level.slots) == fewest,
          '${level.name}: Belady\'s rule missed the fewest');
    } else {
      check(fewest > level.walks,
          '${level.name}: the ask is not hopeless after all');
      check(good == 0, '${level.name}: something landed it');
    }
  }

  // The oldest rule on the first ask's card, which its note quotes.
  check(Rules.walksByOldest(Levels.at(0).card, 2) == 5,
      'the oldest rule on the first card');

  // Belady's own card, and the anomaly on it.
  final anomalyCard = Levels.at(2).card;
  check(Rules.walksByOldest(anomalyCard, 3) == 9, 'the oldest rule on three');
  check(Rules.walksByOldest(anomalyCard, 4) == 10, 'the oldest rule on four');
  check(Rules.walksByRule(anomalyCard, 3) == 7, 'Belady on three');
  check(Rules.walksByRule(anomalyCard, 4) == 6, 'Belady on four');

  // Playing every ask by the pointer lands it in the fewest walks.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var guard = 0;
    while (!play.finished && guard < 40) {
      final slot = play.next;
      check(slot != null, '${level.name} lost its pointer');
      if (slot == null) break;
      play = play.carry(slot);
      guard++;
    }
    check(play.isDone, '${level.name} was not landed by the pointer');
    check(play.walks == level.walks,
        '${level.name} in ${play.walks} against ${level.walks}');
  }

  // The hopeless ask cannot be landed however it is played.
  final dead = Levels.all.last;
  check(!Play.of(dead).isDone, 'the hopeless ask opened landed');
  var runsSeen = 0;
  void walkOut(Play play) {
    if (play.finished) {
      runsSeen++;
      check(!play.isDone, 'a run landed the hopeless ask');
      check(play.walks >= 4, 'a run of ${play.walks} walks');
      return;
    }
    for (var slot = 0; slot < play.bench.length; slot++) {
      walkOut(play.carry(slot));
    }
  }

  walkOut(Play.of(dead));
  check(runsSeen == dead.runs, 'the hopeless ask ran $runsSeen ways');

  if (failed) {
    stderr.writeln('the bench is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every job card of $calls calls on at most $tools tools taken, '
        'the tools named in the order they are first called so that renaming '
        'them makes no new cards, ${commas(cards)} cards in all, and each '
        'one worked at every bench from one slot to $tools, '
        '${commas(checks)} workings: the walks Belady\'s rule takes, '
        'carrying back the tool whose next call is furthest off, and the '
        'fewest walks any way of choosing can manage, found by trying every '
        'eviction from every standing, agree on every one of them')
    ..write('; carrying back whatever has been down longest never beats the '
        'rule and is worse on ${commas(worse)} of the workings, level with '
        'it on ${commas(sameByOldest)}; over the longer cards, every one of '
        'the ${commas(longCards)} of twelve calls on at most $longTools '
        'tools, it wants more walks on a bench one slot bigger on exactly '
        '$anomalies of them, the card ${anomalyCards.single} going from '
        '${anomalyAt - 1} slots to $anomalyAt, while Belady\'s rule never '
        'once does')
    ..write('; on that card the rule takes seven walks on three slots and '
        'six on four, as more room ought to give, where carrying back the '
        'oldest takes nine and then ten')
    ..write('; the asks are counted over every way their cards can be played '
        'out: ')
    ..write(Levels.all
        .map((l) => '${commas(l.runs)} ways for ${l.name}, ${l.ways} of them '
            'keeping to ${l.walks}')
        .join(', '));
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(level.runs)} ways of playing it '
            'keep${level.ways == 1 ? 's' : ''} to ${level.walks} walks, and '
            'that is the fewest there is'
        : 'none of the ${commas(level.runs)} ways, since ${level.fewest} is '
            'the floor';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
