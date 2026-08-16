import 'dart:io';

import 'package:pippinstow/sight/levels.dart';
import 'package:pippinstow/sight/play.dart';
import 'package:pippinstow/sight/rules.dart';

/// Looks at every tree of the orchard two ways, counts what the orchard
/// promises, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_sights.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  check(Rules.side == 10 && Rules.count == 100 && Rules.trees.first == (1, 1) && Rules.trees.last == (10, 10), 'the orchard');
  var seen = 0, edgeSeen = 0, edges = 0;
  final behind = <int, int>{}, hiding = <int, int>{};
  for (final t in Rules.trees) {
    final byFactor = Rules.seenByFactor(t), byLine = Rules.seenByLine(t);
    check(byFactor == byLine, 'the two sights differ on ${Rules.tell(t)}');
    final between = Rules.between(t);
    // Every tree in the way is a fraction of this one, and the nearest is the front.
    for (final u in between) {
      check(t.$1 * u.$2 == t.$2 * u.$1 && u.$1 < t.$1 && u.$2 < t.$2, 'a tree in the way off the line: ${Rules.tell(u)} before ${Rules.tell(t)}');
    }
    final front = Rules.front(t);
    check((front == null) == byFactor, 'the front of ${Rules.tell(t)}');
    if (front != null) check(between.first == front && Rules.seenByFactor(front), 'the front of ${Rules.tell(t)} is ${Rules.tell(front)}, the way holds ${between.map(Rules.tell)}');
    check(between.length == Rules.gcd(t.$1, t.$2) - 1, '${Rules.tell(t)} has ${between.length} in the way');
    if (byFactor) {
      seen++;
      hiding[Rules.hides(t).length] = (hiding[Rules.hides(t).length] ?? 0) + 1;
      for (final u in Rules.hides(t)) {
        check(!Rules.seenByFactor(u) && Rules.front(u) == t, '${Rules.tell(t)} hides ${Rules.tell(u)}, whose front is ${Rules.front(u)}');
      }
    } else {
      behind[between.length] = (behind[between.length] ?? 0) + 1;
      check(Rules.hides(t).isEmpty, 'a hidden tree hiding: ${Rules.tell(t)}');
    }
    if (t.$1 == 1 || t.$2 == 1) {
      edges++;
      if (byFactor) edgeSeen++;
    }
  }
  check(seen == 63, 'in sight $seen');
  check(behind.toString() == '{1: 19, 2: 7, 3: 3, 4: 3, 5: 1, 6: 1, 7: 1, 8: 1, 9: 1}', 'hidden behind $behind');
  check(hiding[9] == 1 && hiding[4] == 2 && hiding[2] == 4 && hiding[1] == 12 && hiding[0] == 44 && hiding.length == 5, 'hiding $hiding');
  check(edges == 19 && edgeSeen == 19, 'the edges: $edges trees, $edgeSeen in sight');
  check(Rules.hides((1, 1)).length == 9 && Rules.tellAll(Rules.hides((1, 2))) == '(2, 4), (3, 6), (4, 8) and (5, 10)', 'the long shadows');
  check(Rules.between((6, 9)).toString() == '[(2, 3), (4, 6)]' && Rules.front((6, 9)) == (2, 3), 'the tree (6, 9)');
  final farRow = Rules.trees.where((t) => t.$2 == 10 && Rules.seenByFactor(t)).map((t) => t.$1).toList();
  check(farRow.join(',') == '1,3,7,9', 'the far row $farRow');
  var deep = 0, deepAll = 0;
  for (final t in Rules.trees) {
    if (t.$1 >= 7 && t.$2 >= 7) {
      deepAll++;
      if (Rules.seenByFactor(t)) deep++;
    }
  }
  check(deep == 10 && deepAll == 16, 'the deep corner $deep of $deepAll');

  // The asks.
  for (final level in Levels.all) {
    final ways = Rules.trees.where(level.meets).length;
    check(ways == level.ways, '${level.name}: ${level.ways} said, $ways swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      final play = open.tap(open.next!);
      check(play.isDone && play.moves == 1, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == (1, 10) && Levels.at(1).aim == (3, 3) && Levels.at(2).aim == (2, 1) && Levels.at(3).aim == (8, 7), 'the aims');
  final dead = Play.of(Levels.at(4)).tap((1, 5)).tap((3, 1)).tap((1, 1));
  check(dead.edgeTries == 3 && dead.gaveUp, 'the hidden edge does not admit it after three edge trees');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every tree of the hundred looked at two ways, by the factor of its file and row and along the line from the gate for a tree in the way, the two agreeing on all a hundred: 63 in sight and 37 hidden, 19 of those behind one tree, 7 behind two, 3 behind three, 3 behind four and one each behind five, six, seven, eight and nine, every hidden tree fronted by the nearest tree on its line and that one in sight; every tree of the two edges in sight, nineteen; (1, 1) hides nine, (1, 2) and (2, 1) four each, four trees hide two, twelve hide one and 44 hide none; the tenth row holds four in sight, at files 1, 3, 7 and 9, and the far corner ten of its sixteen\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the 100 trees land${level.ways == 1 ? 's' : ''} it'
        : 'none of the 100, and the first step said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
