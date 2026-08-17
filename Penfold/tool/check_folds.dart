import 'dart:io';

import 'package:penfold/fold/levels.dart';
import 'package:penfold/fold/play.dart';
import 'package:penfold/fold/rules.dart';

/// Walks every fold of four fields and two whistles, both by the flock
/// and by the pairs, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_folds.dart
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

  // Every fold there is: every way two whistles can send four fields.
  final maps = <List<int>>[];
  for (var mask = 0; mask < 256; mask++) {
    maps.add([
      for (var field = 0; field < Rules.fields; field++)
        mask >> (2 * field) & 3,
    ]);
  }
  var folds = 0, gathered = 0, worst = 0, atWorst = 0, turning = 0;
  final spread = <int, int>{};
  for (final left in maps) {
    for (final right in maps) {
      folds++;
      final fold = [left, right];
      final fewest = Rules.fewest(fold);
      final pairs = Rules.pairsMeet(fold);
      check((fewest != null) == pairs,
          'fold $fold: ${fewest != null} by the flock, $pairs by the pairs');
      if (Rules.turnsOnly(fold, 0) && Rules.turnsOnly(fold, 1)) {
        turning++;
        check(fewest == null, 'a fold of two turns was gathered');
      }
      if (fewest == null) continue;
      gathered++;
      spread[fewest] = (spread[fewest] ?? 0) + 1;
      if (fewest > worst) {
        worst = fewest;
        atWorst = 1;
      } else if (fewest == worst) {
        atWorst++;
      }
    }
  }
  check(folds == 65536, 'folds swept: $folds');
  check(gathered == 51520, 'folds that gather: $gathered');
  check(worst == 9 && atWorst == 96, 'the longest call: $worst on $atWorst');
  check(spread[1] == 2032 && spread[2] == 22032 && spread[9] == 96,
      'the spread of calls: $spread');

  // A fold is gathered by a single whistle exactly when that whistle
  // sends every field to the same one.
  var oneWhistle = 0;
  for (final left in maps) {
    for (final right in maps) {
      final fold = [left, right];
      final atOnce = Rules.gathered(Rules.after(fold, Rules.whole, 0)) ||
          Rules.gathered(Rules.after(fold, Rules.whole, 1));
      final flat = left.toSet().length == 1 || right.toSet().length == 1;
      check(atOnce == flat, 'one whistle on $fold');
      if (atOnce) oneWhistle++;
    }
  }
  check(oneWhistle == spread[1], 'folds gathered in one: $oneWhistle');

  // The asks, and every call of the length they claim.
  for (final level in Levels.all) {
    final fold = level.whistles;
    final fewest = Rules.fewest(fold);
    if (level.winnable) {
      check(fewest == level.length,
          '${level.name}: $fewest against ${level.length}');
      check(Rules.gatherings(fold, level.length) == level.ways,
          '${level.name}: ${Rules.gatherings(fold, level.length)} calls '
          'against ${level.ways}');
      for (var shorter = 0; shorter < level.length; shorter++) {
        check(Rules.gatherings(fold, shorter) == 0,
            '${level.name} gathers in $shorter');
      }
      check(level.fewest == level.length, '${level.name}: the level fewest');
    } else {
      check(fewest == null, '${level.name} can be gathered');
      check(!Rules.pairsMeet(fold), '${level.name} passes the pair test');
      check(Rules.turnsOnly(fold, 0) && Rules.turnsOnly(fold, 1),
          '${level.name} is not two turns');
      // However long the call, the flock stays four wide.
      for (final call in Rules.calls(12)) {
        check(
            Rules.spread(Rules.afterCall(fold, Rules.whole, call)) ==
                Rules.fields,
            '${level.name} narrowed on ${Rules.tellCall(call)}');
      }
    }
  }

  // The pointer gathers every flock it can, in the fewest whistles.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final whistle = play.next;
      check(whistle != null, '${level.name} lost its pointer');
      if (whistle == null) break;
      final was = play.away!;
      play = play.blow(whistle);
      check(play.away == was - 1, '${level.name} wandered');
      steps++;
    }
    check(play.isDone, '${level.name} never gathered');
    check(play.moves == level.length,
        '${level.name} in ${play.moves} against ${level.length}');
  }

  // The hopeless ask, worn down by the flock standing four ways.
  var stuck = Play.of(Levels.all.last);
  for (var k = 0; k < Play.gaveUpAt && !stuck.gaveUp; k++) {
    stuck = stuck.blow(k % 2);
  }
  check(stuck.gaveUp, 'the turning fold never admitted it');

  if (failed) {
    stderr.writeln('the fold is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every fold of four fields and two whistles taken, '
        '${commas(folds)} of them, and each one walked twice, once over the '
        'flock itself, all sixteen ways it can stand, and once over the '
        'pairs alone, which never looks at more than two sheep: the two '
        'agree on every fold, ${commas(gathered)} of them gathering and '
        '${commas(folds - gathered)} not')
    ..write('; ${commas(oneWhistle)} folds are gathered by a single whistle, '
        'and those are exactly the folds where one whistle sends every field '
        'to the same one; none of the ${commas(gathered)} needs more than '
        '$worst, which is three squared, and $atWorst of them need exactly '
        'that: ')
    ..write([
      for (final at in spread.keys.toList()..sort())
        '${commas(spread[at]!)} at $at'
    ].join(', '))
    ..write('; the $turning folds whose whistles both turn the fields round '
        'without ever bringing two sheep together are all in the '
        '${commas(folds - gathered)} that never gather, and however long '
        'the call the flock stays four wide')
    ..write('; the four folds the asks use gather in ')
    ..write(Levels.all
        .where((l) => l.winnable)
        .map((l) => '${l.length} whistles for ${l.fold}')
        .join(', '))
    ..write(', and nothing shorter does');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(level.calls)} calls of '
            '${level.length} whistles '
            '${level.ways == 1 ? 'gathers' : 'gather'} it, and no shorter '
            'call does'
        : 'no call gathers it, and the two turning whistles say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
