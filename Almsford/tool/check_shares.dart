import 'dart:io';

import 'package:almsford/alms/levels.dart';
import 'package:almsford/alms/play.dart';
import 'package:almsford/alms/rules.dart';

/// Walks every share-out from every arrangement the grain can stand in,
/// compares the running totals, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_shares.dart
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

  final all = Rules.arrangements();
  final shapes = Rules.shapes();
  check(all.length == Rules.howManyArrangements && all.length == 1001,
      'arrangements: ${all.length}');
  check(shapes.length == 30, 'shapes: ${shapes.length}');
  for (final at in all) {
    check(Rules.valid(at), 'a bad arrangement $at');
  }

  /// The shapes a share-out can reach, walked outward.
  Set<String> reachable(List<int> from) {
    final seen = <String>{from.join(',')};
    final queue = <List<int>>[from];
    final out = <String>{Rules.shape(from).join(',')};
    for (var head = 0; head < queue.length; head++) {
      final at = queue[head];
      for (var give = 0; give < Rules.bins; give++) {
        for (var take = 0; take < Rules.bins; take++) {
          if (!Rules.canShare(at, give, take)) continue;
          final next = Rules.share(at, give, take);
          // A share never raises a running total.
          final before = Rules.running(Rules.shape(at));
          final after = Rules.running(Rules.shape(next));
          for (var i = 0; i < Rules.bins; i++) {
            check(after[i] <= before[i],
                'a share raised a running total: $at to $next');
          }
          if (seen.add(next.join(','))) {
            out.add(Rules.shape(next).join(','));
            queue.add(next);
          }
        }
      }
    }
    return out;
  }

  var walked = 0, pairs = 0;
  for (final from in all) {
    walked++;
    final got = reachable(from);
    final want = <String>{
      for (final to in shapes)
        if (Rules.covers(from, to)) to.join(','),
    };
    check(got.length == want.length && got.containsAll(want),
        'from ${Rules.tellBins(from)}: walked ${got.length}, totals '
        '${want.length}');
    pairs += shapes.length;
  }
  check(walked == 1001, 'arrangements walked: $walked');

  // The level field is under every shape, and the one heap over every
  // shape.
  final level = [for (var b = 0; b < Rules.bins; b++) Rules.grain ~/ Rules.bins];
  final heap = [Rules.grain, for (var b = 1; b < Rules.bins; b++) 0];
  for (final at in all) {
    check(Rules.covers(at, level), 'the level field is out of reach from $at');
    check(Rules.covers(heap, at), 'the one heap does not cover $at');
    check(Rules.covers(at, heap) == (Rules.shape(at).first == Rules.grain),
        'the one heap from $at');
  }
  check(Play.standing(Levels.at(3), level).settled,
      'the level field is not settled');
  var stirring = 0;
  for (final at in all) {
    if (Play.standing(Levels.at(0), at).settled) stirring++;
  }
  check(stirring == 1, 'settled arrangements: $stirring');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (final at in all) {
      if (level.meets(at)) n++;
    }
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    check(level.shape.fold(0, (a, b) => a + b) == Rules.grain,
        '${level.name}: the shape does not hold the grain');
    check(Rules.covers(Rules.opening, level.shape) == level.winnable,
        '${level.name}: the totals and the ask disagree');
    check(!level.meets(Rules.opening), '${level.name} is landed at the opening');
  }

  // The pointer lands every ask it can, in the fewest shares.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    check(play.toGo!.$1 == level.fewest,
        '${level.name}: ${play.toGo!.$1} shares against ${level.fewest}');
    var steps = 0;
    while (!play.isDone && steps < 40) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.tap(aim.$1).tap(aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  // The hopeless ask: nothing reaches it, and the sham admits it.
  final heapAsk = Levels.all.last;
  for (final at in all) {
    if (Rules.shape(at).first == Rules.grain) continue;
    check(!Rules.covers(at, heapAsk.shape),
        'the one heap is covered from ${Rules.tellBins(at)}');
  }
  var stuck = Play.of(heapAsk);
  for (final (give, take) in [(4, 0), (4, 1), (4, 2), (4, 3)]) {
    stuck = stuck.tap(give).tap(take);
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');

  if (failed) {
    stderr.writeln('the almshouse is not sound; no bake');
    exit(1);
  }

  final fromOpening = reachable(Rules.opening);
  final ledger = StringBuffer()
    ..write('every arrangement of the ${Rules.grain} measures over the '
        '${Rules.bins} bins taken, ${commas(all.length)} of them standing in '
        '${shapes.length} shapes, and from each one every share-out walked in '
        'full: a share never raises the fullest bin, nor the two fullest '
        'together, nor the three, and so on down, on any share of any walk')
    ..write('; and the shapes a walk reaches are exactly the shapes whose '
        'running totals are no greater, checked on all ${commas(pairs)} pairs '
        'of an arrangement and a shape, the walk moving grain and the totals '
        'moving none')
    ..write('; the level field, two in every bin, is under every shape there '
        'is, so a share-out always reaches it, and it is the one arrangement '
        'of the ${commas(all.length)} where nothing can move at all, no bin '
        'being two ahead of another')
    ..write('; the one heap is over every shape, so nothing but itself '
        'reaches it: from the opening ${fromOpening.length} of the '
        '${shapes.length} shapes can be reached and the one heap is the shape '
        'that cannot');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(all.length)} arrangements '
            '${level.ways == 1 ? 'stands' : 'stand'} that way, the fewest in '
            '${level.fewest} ${level.fewest == 1 ? 'share' : 'shares'}'
        : 'none of the walks reach it, and the running totals say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
