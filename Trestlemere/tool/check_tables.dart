import 'dart:io';

import 'package:trestlemere/table/levels.dart';
import 'package:trestlemere/table/play.dart';
import 'package:trestlemere/table/rules.dart';

/// Walks every seating of the guests, counts them again without writing
/// one down, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_tables.dart
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

  check(Rules.guests == 6, 'guests at the supper: ${Rules.guests}');

  // The first voice: every seating, written out one by one.
  final all = Rules.seatings();
  final byTables = <int, int>{};
  final marks = <String>{};
  for (final seating in all) {
    final tidied = Rules.tidy(seating);
    byTables[tidied.length] = (byTables[tidied.length] ?? 0) + 1;
    marks.add(Rules.write(tidied));
    var seated = 0;
    for (final table in tidied) {
      check(table.isNotEmpty, 'an empty table was counted');
      seated += table.length;
    }
    check(seated == Rules.guests, 'a seating seats $seated guests');
  }
  check(all.length == 203, 'seatings walked: ${all.length}');
  check(marks.length == all.length,
      'the walk wrote a seating twice: ${marks.length} of ${all.length}');

  // The second voice, which seats nobody: the last guest either joins a
  // table already laid or takes a trestle of their own.
  for (var k = 1; k <= Rules.guests; k++) {
    check(Rules.byRecurrence(Rules.guests, k) == byTables[k],
        'at $k tables the counting says '
        '${Rules.byRecurrence(Rules.guests, k)} and the walk says '
        '${byTables[k]}');
  }
  check(Rules.allWays(Rules.guests) == all.length,
      'the row adds to ${Rules.allWays(Rules.guests)}');
  // The same two voices held against each other for every smaller
  // supper, so the agreement is not one lucky row.
  for (var n = 0; n <= Rules.guests; n++) {
    final here = Rules.seatings(n);
    check(Rules.allWays(n) == here.length,
        'at $n guests the counting says ${Rules.allWays(n)} and the walk '
        'says ${here.length}');
    final split = <int, int>{};
    for (final s in here) {
      final k = Rules.tidy(s).length;
      split[k] = (split[k] ?? 0) + 1;
    }
    for (var k = 1; k <= n; k++) {
      check(Rules.byRecurrence(n, k) == split[k],
          'at $n guests and $k tables: ${Rules.byRecurrence(n, k)} against '
          '${split[k]}');
    }
  }

  // The rows the game shows.
  check(byTables[1] == 1 && byTables[2] == 31 && byTables[3] == 90 &&
      byTables[4] == 65 && byTables[5] == 15 && byTables[6] == 1,
      'the row came out $byTables');

  // The asks.
  final open = Rules.seatOf([[0, 1, 2, 3, 4, 5]]);
  for (final level in Levels.all) {
    final wins = all.where(level.meets).toList();
    check(wins.length == level.ways,
        '${level.name}: ${wins.length} against ${level.ways}');
    check(!level.meets([
      [0, 1, 2, 3, 4, 5]
    ]), '${level.name} is landed with everybody at one trestle');
    if (level.winnable) {
      var cheapest = Rules.guests;
      for (final win in Play.winners(level)) {
        final n = Play.between(open, win);
        if (n < cheapest) cheapest = n;
      }
      check(level.fewest == cheapest,
          '${level.name}: ${level.fewest} against $cheapest');
    } else {
      check(level.fewest == null && wins.isEmpty, '${level.name} was landed');
      // The reason needs no seating: the smallest four different tables
      // want more guests than there are.
      check(Rules.fewestFor(level.tables) > Rules.guests,
          '${level.name} is hopeless for some other reason');
    }
  }
  check(Rules.fewestFor(4) == 10, 'four different tables want '
      '${Rules.fewestFor(4)} guests');
  check(Rules.fewestFor(3) == 6, 'three different tables want '
      '${Rules.fewestFor(3)} guests');

  // Three tables of different sizes have to be one, two and three, and
  // three tables with nobody alone have to be two, two and two.
  for (final seating in all) {
    final tidied = Rules.tidy(seating);
    if (tidied.length != 3) continue;
    if (Rules.allDifferent(tidied)) {
      check(Rules.sizes(tidied).join() == '123',
          'a three-table seating of different sizes came out '
          '${Rules.sizes(tidied)}');
    }
    if (Rules.nobodyAlone(tidied)) {
      check(Rules.sizes(tidied).join() == '222',
          'a three-table seating with nobody alone came out '
          '${Rules.sizes(tidied)}');
    }
  }

  // The pointer lands every ask it can, in the moves it promises.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 12) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.sit(aim.$1, aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} was never seated');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  // The hopeless ask, worn down by six seatings.
  final dead = Levels.all.last;
  check(Play.of(dead).next == null, 'the hopeless ask kept a pointer');
  var stuck = Play.of(dead);
  for (final step in [(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (1, 0)]) {
    final was = stuck;
    stuck = stuck.sit(step.$1, step.$2);
    check(stuck.mark != was.mark, 'a move that seated nobody at $step');
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');
  check(!Play.of(dead).gaveUp, 'it admitted it at once');

  if (failed) {
    stderr.writeln('the supper is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every way of seating ${Rules.guests} guests at trestles walked, '
        '${commas(all.length)} of them, a seating being only which guests '
        'share a table, since the trestles have no names and an empty one is '
        'no table at all: every seating came out once and once only, and '
        'each seats all ${Rules.guests}')
    ..write('; split by how many tables they use they come to '
        '${[for (var k = 1; k <= Rules.guests; k++) byTables[k]].join(', ')}, '
        'from everybody together to everybody apart, and those add to '
        '${commas(all.length)}')
    ..write('; a second voice seats nobody at all and gets the same numbers '
        'from the last guest alone, who either joins one of the tables laid '
        'or takes a trestle of their own, so the ways at k tables come to k '
        'times the ways for one guest fewer at k, plus the ways for one '
        'guest fewer at k less one, which is Stirling counting of the second '
        'kind; the two agree at every table count, and again at every '
        'smaller supper from none up to ${Rules.guests}')
    ..write('; three tables of different sizes have to be one, two and three '
        'and there are ${Levels.at(1).ways} such seatings, three tables with '
        'nobody alone have to be two, two and two and there are '
        '${Levels.at(2).ways}, and two tables of the same size have to be '
        'three and three and there are ${Levels.at(3).ways}')
    ..write('; four tables of four different sizes would want 1 and 2 and 3 '
        'and 4 guests, which is ${Rules.fewestFor(4)}, and there are '
        '${Rules.guests}, so none of the ${commas(all.length)} does it and '
        'no supper of fewer than ${Rules.fewestFor(4)} ever could');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(all.length)} seatings do it, the '
            'nearest ${level.fewest} moves away'
        : 'none of the ${commas(all.length)}, and the adding up said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
