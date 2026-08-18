import 'dart:io';
import 'dart:typed_data';

import 'package:palingford/paling/levels.dart';
import 'package:palingford/paling/play.dart';
import 'package:palingford/paling/rules.dart';

/// Sweeps every order of the ten palings and reads the longest climb and the
/// longest drop off each, counts the same orders a second time from shapes
/// without writing a fence down, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_palings.dart
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

  const n = Rules.palings;

  // The first voice: every order of the ten, one at a time.
  //
  // For each it works out the longest climb ending at each paling and the
  // longest drop ending at each, which is the tag on that paling. It reads
  // the two longest runs off those, checks no two tags on a fence match, and
  // checks the moves back to the opening come to ten less the longest climb.
  final fence = Uint8List.fromList(List.generate(n, (i) => i + 1));
  final walk = Uint8List(n);
  final up = Uint8List(n);
  final down = Uint8List(n);
  final tagged = Int32List(144);
  final lcs = Int32List((n + 1) * (n + 1));
  final count = List.generate(n + 2, (_) => List.filled(n + 2, 0));
  var swept = 0, stamp = 0, sameTag = 0, movesWrong = 0;

  void look() {
    swept++;
    var mostUp = 1, mostDown = 1;
    for (var i = 0; i < n; i++) {
      var u = 1, d = 1;
      for (var j = 0; j < i; j++) {
        if (fence[j] < fence[i]) {
          if (up[j] + 1 > u) u = up[j] + 1;
        } else {
          if (down[j] + 1 > d) d = down[j] + 1;
        }
      }
      up[i] = u;
      down[i] = d;
      if (u > mostUp) mostUp = u;
      if (d > mostDown) mostDown = d;
    }
    count[mostUp][mostDown]++;

    // No two palings on a fence carry the same tag.
    stamp++;
    for (var i = 0; i < n; i++) {
      final tag = up[i] * 12 + down[i];
      if (tagged[tag] == stamp) {
        sameTag++;
        break;
      }
      tagged[tag] = stamp;
    }

    // The moves back to the opening: ten less the palings that keep their
    // order. The opening climbs the whole way, so that should be ten less
    // the longest climb.
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        final spot = (i + 1) * (n + 1) + j + 1;
        if (fence[i] == j + 1) {
          lcs[spot] = lcs[i * (n + 1) + j] + 1;
        } else {
          final a = lcs[i * (n + 1) + j + 1];
          final b = lcs[spot - 1];
          lcs[spot] = a > b ? a : b;
        }
      }
    }
    if (lcs[n * (n + 1) + n] != mostUp) movesWrong++;
  }

  // Heap's algorithm, which writes every order once.
  look();
  var at = 0;
  while (at < n) {
    if (walk[at] < at) {
      final swapWith = at.isEven ? 0 : walk[at];
      final held = fence[swapWith];
      fence[swapWith] = fence[at];
      fence[at] = held;
      look();
      walk[at]++;
      at = 0;
    } else {
      walk[at] = 0;
      at++;
    }
  }

  var whole = 1;
  for (var k = 2; k <= n; k++) {
    whole *= k;
  }
  check(swept == whole, 'orders swept: $swept against $whole');
  check(sameTag == 0, 'fences with two palings sharing a tag: $sameTag');
  check(movesWrong == 0,
      'fences where the moves home were not ten less the climb: $movesWrong');

  // The second voice: count the same orders from shapes, writing no fence
  // down at all. It has to come to the same as the sweep in every box of
  // limits.
  final shapes = Rules.shapes();
  check(shapes.length == 42, 'shapes of ten: ${shapes.length}');
  check(
      shapes.fold<int>(
              0, (a, s) => a + Rules.tableaux(s) * Rules.tableaux(s)) ==
          whole,
      'the shapes do not add up to $whole');
  var boxes = 0, boxesWrong = 0;
  for (var climbCap = 1; climbCap <= n; climbCap++) {
    for (var dropCap = 1; dropCap <= n; dropCap++) {
      var here = 0;
      for (var c = 1; c <= climbCap; c++) {
        for (var d = 1; d <= dropCap; d++) {
          here += count[c][d];
        }
      }
      boxes++;
      if (here != Rules.byShapes(climbCap, dropCap)) boxesWrong++;
    }
  }
  check(boxes == 100, 'boxes of limits tried: $boxes');
  check(boxesWrong == 0, 'boxes the two voices disagree on: $boxesWrong');

  // The box that matters, said both ways.
  var underFour = 0;
  for (var c = 1; c <= 3; c++) {
    for (var d = 1; d <= 3; d++) {
      underFour += count[c][d];
    }
  }
  check(underFour == 0, 'fences with both runs under four: $underFour');
  check(Rules.byShapes(3, 3) == 0, 'a shape of ten fitted in three by three');
  check(Rules.byShapes(4, 3) == 107604 && Rules.byShapes(3, 4) == 107604,
      'the four by three boxes came out wrong');

  // A pair of limits cannot be tightened when taking either number down by
  // one empties it. Six pairs are like that, and four by three is the one
  // where the two numbers sit nearest each other.
  final snug = <String>[];
  for (var climbCap = 1; climbCap <= n; climbCap++) {
    for (var dropCap = 1; dropCap <= n; dropCap++) {
      if (Rules.byShapes(climbCap, dropCap) == 0) continue;
      if (Rules.byShapes(climbCap - 1, dropCap) == 0 &&
          Rules.byShapes(climbCap, dropCap - 1) == 0) {
        snug.add('$climbCap by $dropCap');
      }
    }
  }
  check(snug.join(', ') == '1 by 10, 2 by 5, 3 by 4, 4 by 3, 5 by 2, 10 by 1',
      'the pairs of limits that cannot be tightened: ${snug.join(', ')}');
  check(Rules.byShapes(4, 2) == 0, 'four by two held something');

  // Nine palings can keep both runs under four. Ten is where it breaks.
  for (var few = 1; few <= 9; few++) {
    check(Rules.byShapes(3, 3, few) > 0,
        'a fence of $few palings could not keep both runs under four');
  }
  // Nine is the last size that does. One shape fits a three by three box
  // exactly, the full square, and it fills 42 ways, so 42 by 42 fences of
  // nine hold both runs under four.
  check(Rules.byShapes(3, 3, 9) == 1764,
      'fences of nine that do it: ${Rules.byShapes(3, 3, 9)}');
  check(Rules.tableaux(const [3, 3, 3]) == 42,
      'fillings of the square shape: ${Rules.tableaux(const [3, 3, 3])}');

  // The player's move, walked out in full at six palings: every ordered pair
  // of orders, and the walk against the count the game uses.
  const few = 6;
  final orders = <List<int>>[];
  void lay(List<int> so, List<bool> used) {
    if (so.length == few) {
      orders.add([...so]);
      return;
    }
    for (var h = 1; h <= few; h++) {
      if (used[h - 1]) continue;
      used[h - 1] = true;
      lay([...so, h], used);
      used[h - 1] = false;
    }
  }

  lay(const [], List.filled(few, false));
  check(orders.length == 720, 'orders of six: ${orders.length}');
  final where = {for (var i = 0; i < orders.length; i++) orders[i].join(): i};
  var pairs = 0, pairsWrong = 0;
  for (final from in orders) {
    final start = where[from.join()]!;
    final far = List.filled(orders.length, -1);
    far[start] = 0;
    final queue = <int>[start];
    for (var head = 0; head < queue.length; head++) {
      final here = orders[queue[head]];
      for (var lift = 0; lift < few; lift++) {
        for (var gap = 0; gap < few; gap++) {
          final to = [...here]..removeAt(lift);
          to.insert(gap, here[lift]);
          final which = where[to.join()]!;
          if (far[which] >= 0) continue;
          far[which] = far[queue[head]] + 1;
          queue.add(which);
        }
      }
    }
    for (var i = 0; i < orders.length; i++) {
      pairs++;
      if (far[i] != few - Rules.shared(from, orders[i])) pairsWrong++;
    }
  }
  check(pairs == 518400, 'ordered pairs of six-paling fences: $pairs');
  check(pairsWrong == 0,
      'pairs where the walk and the count disagree: $pairsWrong');

  // The asks, against the sweep. This walks the orders a second time rather
  // than holding 3,628,800 fences in memory.
  final ways = List.filled(Levels.count, 0);
  final nearest = List.filled(Levels.count, n + 1);
  final again = Uint8List.fromList(List.generate(n, (i) => i + 1));
  final walkAgain = Uint8List(n);
  void weigh() {
    final here = List<int>.generate(n, (i) => again[i]);
    final away = Rules.between(Rules.opening, here);
    for (var l = 0; l < Levels.count; l++) {
      if (!Levels.at(l).meets(here)) continue;
      ways[l]++;
      if (away < nearest[l]) nearest[l] = away;
    }
  }

  weigh();
  at = 0;
  while (at < n) {
    if (walkAgain[at] < at) {
      final swapWith = at.isEven ? 0 : walkAgain[at];
      final held = again[swapWith];
      again[swapWith] = again[at];
      again[at] = held;
      weigh();
      walkAgain[at]++;
      at = 0;
    } else {
      walkAgain[at] = 0;
      at++;
    }
  }

  for (var l = 0; l < Levels.count; l++) {
    final level = Levels.at(l);
    check(ways[l] == level.ways,
        '${level.name}: ${ways[l]} fences against ${level.ways}');
    check(!level.meets(Rules.opening), '${level.name} is landed before a move');
    if (level.winnable) {
      check(nearest[l] == level.fewest,
          '${level.name}: nearest ${nearest[l]} against ${level.fewest}');
      check(level.meets(level.aim),
          '${level.name} points at a fence that does not land it');
      check(Rules.between(Rules.opening, level.aim) == level.fewest,
          '${level.name} points at a fence further off than it promises');
    } else {
      check(level.fewest == null && ways[l] == 0, '${level.name} was landed');
      check(level.aim.isEmpty, '${level.name} keeps a fence to point at');
    }
  }

  // The pointer lands every ask it can, in the moves it promises.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.take(aim.$1).slide(aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} was never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} moves against ${level.fewest}');
  }

  // The hopeless ask, worn down by six fences.
  final dead = Levels.all.last;
  check(Play.of(dead).next == null, 'the hopeless ask kept a pointer');
  var stuck = Play.of(dead);
  for (final move in const [(0, 9), (0, 5), (3, 0), (8, 2), (1, 7), (4, 0)]) {
    final was = stuck;
    stuck = stuck.take(move.$1).slide(move.$2);
    check(stuck.fence.join() != was.fence.join(),
        'a move that changed nothing at $move');
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');
  check(!Play.of(dead).gaveUp, 'it admitted it at once');

  if (failed) {
    stderr.writeln('the fence is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every order of the ten palings tried, all ${commas(swept)} of '
        'them, each tagged paling by paling with the longest climb ending '
        'there and the longest drop ending there: no fence anywhere has two '
        'palings carrying the same tag')
    ..write('; not one of the ${commas(swept)} keeps both runs under four, '
        'while ${commas(Rules.byShapes(4, 3))} keep the climb under five with '
        'the drop under four, and that pair of limits cannot be tightened: '
        'take either number down by one and nothing is left')
    ..write('; a second voice counts the same orders from shapes and writes '
        'no fence down, ${shapes.length} shapes of ten with the hook length '
        'formula for each, and the two agree on all $boxes boxes of limits')
    ..write('; the player\'s move was walked out in full at six palings, all '
        '${commas(pairs)} ordered pairs of orders, and the walk came to six '
        'less the palings that keep their order every time')
    ..write('; the moves home from any fence of ten come to ten less its '
        'longest climb, checked on all ${commas(swept)}')
    ..write('; nine palings can hold both runs under four, in '
        '${commas(Rules.byShapes(3, 3, 9))} ways, which is the 42 fillings of '
        'the one shape that fits a three by three box multiplied by '
        'themselves, and ten palings in none');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(swept)} fences do it, the '
            'nearest ${level.fewest} moves away'
        : 'none of the ${commas(swept)}, and nine tags cannot go round ten '
            'palings';
    stdout
        .writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
