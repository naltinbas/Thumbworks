import 'dart:io';

import 'package:knaveley/isle/levels.dart';
import 'package:knaveley/isle/play.dart';
import 'package:knaveley/isle/rules.dart';

/// Tries every naming of every ask against every telling, and refuses
/// the bake on any disagreement.
///
/// Run with: dart run tool/check_tellings.dart
void main() {
  String commas(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  var namings = 0;
  final held = <String, int>{};
  for (final level in Levels.all) {
    var holds = 0;
    for (final naming in Rules.namings(level.villagers)) {
      namings++;
      final caught = Rules.caught(level.tellings, naming);
      final whole = Rules.consistent(level.tellings, naming);
      // The two readings agree: a naming holds when nobody is caught
      // out by it.
      check(whole == caught.isEmpty,
          '${level.name}: ${Rules.tellNaming(naming)} holds $whole with '
          '${caught.length} caught');
      // A villager is caught out exactly when kind and telling disagree.
      for (var who = 0; who < level.villagers; who++) {
        final agrees =
            naming[who] == Rules.holds(level.tellings[who], who, naming);
        check(agrees != caught.contains(who),
            '${level.name}: ${Rules.tellName(who)} under '
            '${Rules.tellNaming(naming)}');
      }
      if (whole) holds++;
    }
    held[level.name] = holds;
    check(holds == level.ways,
        '${level.name}: $holds against ${level.ways}');
    check(level.answers.length == holds, '${level.name}: the answers');
    if (level.winnable) {
      final aim = level.aim!;
      check(level.meets(aim), '${level.name}: the aim misses');
      var cheapest = level.villagers + 1;
      for (final naming in level.answers) {
        final turns = naming.where((kind) => kind == Rules.knave).length;
        if (turns < cheapest) cheapest = turns;
      }
      check(level.fewest == cheapest, '${level.name}: the fewest');
    } else {
      check(level.aim == null, '${level.name} has an aim');
    }
  }

  // Nobody can say 'I am a knave', whatever else is said: the telling
  // catches out every naming there is.
  for (var many = 1; many <= 5; many++) {
    for (final naming in Rules.namings(many)) {
      check(naming[0] != Rules.holds([Rules.selfKnave], 0, naming),
          'a naming let somebody call themselves a knave');
    }
  }

  // Every set of tellings three villagers can make, drawn from the
  // fourteen this island allows each of them.
  List<List<dynamic>> sayings(int who) => [
        for (var about = 0; about < 3; about++)
          if (about != who) ...[
            [Rules.isKnight, about],
            [Rules.isKnave, about],
          ],
        for (var a = 0; a < 3; a++)
          for (var b = a + 1; b < 3; b++) ...[
            [Rules.same, a, b],
            [Rules.different, a, b],
            [Rules.someKnave, a, b],
          ],
        [Rules.selfKnave],
      ];
  var sets = 0, withSelf = 0;
  final byHolds = <int, int>{};
  for (final first in sayings(0)) {
    for (final second in sayings(1)) {
      for (final third in sayings(2)) {
        sets++;
        final tellings = [first, second, third];
        var holds = 0;
        for (final naming in Rules.namings(3)) {
          if (Rules.consistent(tellings, naming)) holds++;
        }
        byHolds[holds] = (byHolds[holds] ?? 0) + 1;
        final hasSelf =
            tellings.any((telling) => telling[0] == Rules.selfKnave);
        if (hasSelf) {
          withSelf++;
          check(holds == 0, 'a set with "I am a knave" was held');
        }
      }
    }
  }
  check(sets == 2744, 'sets swept: $sets');

  // The pointer lands every ask it can, in the fewest taps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 12) {
      final who = play.next;
      check(who != null, '${level.name} lost its pointer');
      if (who == null) break;
      play = play.turn(who);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  if (failed) {
    stderr.writeln('the island is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every naming of every ask tried against every telling, '
        '$namings namings in all, and each read twice, once by asking '
        'whether the whole naming holds and once by counting the villagers '
        'caught out by it: the two agree on every naming, and a naming holds '
        'exactly when nobody is caught')
    ..write('; the asks come out at ')
    ..write(Levels.all
        .map((level) => '${held[level.name]} of ${level.namings} for '
            '${level.name}')
        .join(', '))
    ..write('; the telling "I am a knave" catches out every naming there is, '
        'on an island of one villager or five, since a knight saying it '
        'would speak falsely and a knave saying it would speak true')
    ..write('; and taking every set of tellings three villagers could make '
        'from the fourteen this island allows each of them, ${commas(sets)} '
        'sets in all: ')
    ..write([
      for (final at in byHolds.keys.toList()..sort())
        '${commas(byHolds[at]!)} sets are held by $at '
            '${at == 1 ? 'naming' : 'namings'}'
    ].join(', '))
    ..write(', and every one of the ${commas(withSelf)} sets in which '
        'somebody says "I '
        'am a knave" is held by none');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${level.namings} namings '
            '${level.ways == 1 ? 'holds' : 'hold'} it, the nearest '
            '${level.fewest} ${level.fewest == 1 ? 'tap' : 'taps'} from '
            'calling everybody a knight'
        : 'none of the ${level.namings}, and the first telling says why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
