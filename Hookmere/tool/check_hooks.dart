import 'dart:io';

import 'package:hookmere/shape/levels.dart';
import 'package:hookmere/shape/play.dart';
import 'package:hookmere/shape/rules.dart';

/// Counts every staircase twice, by the hooks and one filling at a
/// time, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_hooks.dart
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

  /// Both voices, written out for any number of boxes so the sweep can
  /// widen past the eight the game plays with.
  List<List<int>> staircasesOf(int boxes) {
    final out = <List<int>>[];
    void build(int left, int most, List<int> so) {
      if (left == 0) {
        out.add(List.of(so));
        return;
      }
      for (var k = left < most ? left : most; k >= 1; k--) {
        build(left - k, k, [...so, k]);
      }
    }

    build(boxes, boxes, const []);
    return out;
  }

  int hooksOf(List<int> rows, int boxes) {
    var product = 1;
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r]; c++) {
        var below = 0;
        for (final row in rows) {
          if (row > c) below++;
        }
        product *= rows[r] - c + below - r - 1;
      }
    }
    var fact = 1;
    for (var k = 2; k <= boxes; k++) {
      fact *= k;
    }
    check(fact % product == 0, 'the hooks of $rows do not divide $boxes!');
    return fact ~/ product;
  }

  final held = <String, int>{};
  int counted(List<int> rows) {
    final key = rows.join(',');
    if (key.isEmpty) return 1;
    final at = held[key];
    if (at != null) return at;
    var out = 0;
    for (var i = 0; i < rows.length; i++) {
      if (i + 1 < rows.length && rows[i + 1] == rows[i]) continue;
      final less = [
        for (var j = 0; j < rows.length; j++)
          if (j == i) rows[j] - 1 else rows[j],
      ]..removeWhere((r) => r == 0);
      out += counted(less);
    }
    held[key] = out;
    return out;
  }

  // The sweep, from one box up to ten.
  final perBoxes = <int, (int, int)>{};
  for (var boxes = 1; boxes <= 10; boxes++) {
    final all = staircasesOf(boxes);
    var squares = 0, most = 0;
    for (final rows in all) {
      final byHooks = hooksOf(rows, boxes);
      final one = counted(rows);
      check(byHooks == one,
          '$boxes boxes, staircase $rows: $byHooks by hooks, $one counted');
      squares += byHooks * byHooks;
      if (byHooks > most) most = byHooks;
      // A staircase and its turning have the same count.
      final turned = [
        for (var c = 0; c < rows[0]; c++)
          [for (final row in rows) if (row > c) 1].length,
      ];
      check(counted(turned) == one, 'the turning of $rows');
    }
    var fact = 1;
    for (var k = 2; k <= boxes; k++) {
      fact *= k;
    }
    check(squares == fact,
        '$boxes boxes: the squares add to $squares, not $fact');
    perBoxes[boxes] = (all.length, most);
  }
  check(perBoxes[8]!.$1 == 22 && perBoxes[8]!.$2 == 90,
      'eight boxes: ${perBoxes[8]}');
  check(perBoxes[9]!.$1 == 30 && perBoxes[10]!.$1 == 42,
      'nine and ten: ${perBoxes[9]} ${perBoxes[10]}');

  // The staircases the game lays.
  final all = Rules.staircases();
  check(all.length == 22, 'staircases: ${all.length}');
  for (final rows in all) {
    check(Rules.valid(rows), 'a staircase that is not one: $rows');
    check(Rules.byHooks(rows) == Rules.byCounting(rows),
        'the staircase ${Rules.tellShape(rows)}');
    check(Rules.hooks(rows).length == Rules.boxes, 'the hooks of $rows');
    check(Rules.byCounting(Rules.turned(rows)) == Rules.byCounting(rows),
        'the turning of ${Rules.tellShape(rows)}');
  }

  // Every staircase can be reached from every other, a box at a time.
  final away = <String, int>{Rules.opening.join(','): 0};
  final queue = <List<int>>[Rules.opening];
  for (var head = 0; head < queue.length; head++) {
    final at = queue[head];
    for (final from in Rules.corners(at)) {
      for (var to = 0; to <= at.length; to++) {
        final next = Rules.move(at, from, to);
        if (next == null) continue;
        final key = next.join(',');
        if (away.containsKey(key)) continue;
        away[key] = away[at.join(',')]! + 1;
        queue.add(next);
      }
    }
  }
  check(away.length == all.length, 'reached ${away.length} of ${all.length}');
  final furthest = away.values.reduce((a, b) => a > b ? a : b);
  check(furthest == 5, 'the furthest staircase is $furthest moves off');

  // The asks.
  for (final level in Levels.all) {
    var n = 0, cheapest = 99;
    for (final rows in all) {
      if (!level.meets(rows)) continue;
      n++;
      final at = away[rows.join(',')];
      if (at != null && at < cheapest) cheapest = at;
    }
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    if (level.winnable) {
      check(level.fewest == cheapest,
          '${level.name}: ${level.fewest} against $cheapest');
    } else {
      check(level.fewest == null && n == 0, '${level.name} was landed');
    }
    check(!level.meets(Rules.opening), '${level.name} is landed at the opening');
  }

  // The pointer lands every ask it can, in the fewest moves.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    check(play.toGo!.$1 == level.fewest,
        '${level.name}: ${play.toGo!.$1} against ${level.fewest}');
    var steps = 0;
    while (!play.isDone && steps < 20) {
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

  // The hopeless ask, worn down by four staircases.
  var stuck = Play.of(Levels.all.last);
  for (final move in [(1, 0), (0, 1), (1, 3), (0, 3)]) {
    final was = stuck;
    stuck = stuck.tap(move.$1).tap(move.$2);
    check(!identical(stuck, was), 'a move that did nothing at ${was.rows}');
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');

  if (failed) {
    stderr.writeln('the staircase is not sound; no bake');
    exit(1);
  }

  final opening = Rules.opening;
  final ledger = StringBuffer()
    ..write('every staircase eight boxes can be laid in taken, all '
        '${all.length} of them, and each counted twice: once by multiplying '
        'the eight hooks and dividing ${commas(Rules.factorial(Rules.boxes))} '
        'by them, which counts no fillings at all, and once by taking the '
        'largest number off a corner and counting the fillings of what is '
        'left, which is the definition worked out in full: the two agree on '
        'every staircase')
    ..write('; and they agree from one box up to ten, ')
    ..write([
      for (var boxes = 1; boxes <= 10; boxes++)
        '${perBoxes[boxes]!.$1} at $boxes'
    ].join(', '))
    ..write(' staircases, where the counts squared and added come to the '
        'factorial of the boxes every time, ${commas(Rules.factorial(8))} at '
        'eight')
    ..write('; a staircase and the same staircase turned on its side always '
        'count the same, since turning it swaps every hook for another hook '
        'of the same staircase')
    ..write('; the most fillings eight boxes reach is ${perBoxes[8]!.$2}, at '
        'the staircase 4, 2, 1, 1, whose hooks multiply to '
        '${Rules.hookProduct(const [4, 2, 1, 1])}, and the fewest is 1, at '
        'the single row and the single column, whose hooks multiply to '
        '${commas(Rules.hookProduct(const [8]))} exactly')
    ..write('; and moving one box at a time off a corner and onto another, '
        'every one of the ${all.length} staircases can be reached from the '
        '${Rules.tellShape(opening)} the board opens on, the furthest of them '
        '$furthest moves off');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${all.length} staircases '
            '${level.ways == 1 ? 'lands' : 'land'} it, the nearest '
            '${level.fewest} ${level.fewest == 1 ? 'move' : 'moves'} off'
        : 'none of the ${all.length}, nor of the staircases of nine boxes or '
            'ten, and the hooks say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
