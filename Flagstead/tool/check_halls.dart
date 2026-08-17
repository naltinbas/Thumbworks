import 'dart:io';

import 'package:flagstead/hall/levels.dart';
import 'package:flagstead/hall/play.dart';
import 'package:flagstead/hall/rules.dart';

/// Takes every hall and every standing, adds the squares two ways, and
/// refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_halls.dart
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

  var settings = 0, apartOnce = 0, whole = 0, same = 0, wholeInside = 0;
  final ways = <String, int>{for (final level in Levels.all) level.name: 0};
  final cheapest = <String, (int, int, int, int)?>{
    for (final level in Levels.all) level.name: null,
  };
  for (final (wide, tall, px, py) in Rules.settings()) {
    settings++;
    // Square-cornered: the two sums agree, by distances and by algebra.
    final one = Rules.acrossOne(wide, tall, 0, px, py);
    final two = Rules.acrossTwo(wide, tall, 0, px, py);
    final (byAlgebraOne, byAlgebraTwo) =
        Rules.sumsByAlgebra(wide, tall, 0, px, py);
    check(one == byAlgebraOne && two == byAlgebraTwo,
        'the sums of $wide by $tall at ($px, $py): $one and $two against '
        '$byAlgebraOne and $byAlgebraTwo');
    check(one == two, 'a square hall $wide by $tall at ($px, $py) came apart');
    if (one != two) apartOnce++;
    if (Rules.allWhole(wide, tall, 0, px, py)) {
      whole++;
      if (Rules.inside(wide, tall, 0, px, py)) wholeInside++;
    }
    if (Rules.allSame(wide, tall, 0, px, py)) same++;

    for (final level in Levels.all) {
      if (!level.meets(wide, tall, px, py)) continue;
      ways[level.name] = ways[level.name]! + 1;
      final held = cheapest[level.name];
      final taps = level.taps(wide, tall, px, py);
      if (held == null || taps < level.taps(held.$1, held.$2, held.$3, held.$4)) {
        cheapest[level.name] = (wide, tall, px, py);
      }
    }
  }
  check(settings == Rules.howMany && settings == 11025,
      'settings swept: $settings');
  check(apartOnce == 0, 'square halls that came apart: $apartOnce');
  check(whole == 26 && wholeInside == 2, 'whole halls: $whole, inside $wholeInside');
  check(same == 16, 'halls with all four alike: $same');

  // The leaned hall: the two sums differ by twice the lean times the
  // width, wherever the peg stands.
  for (var lean = 1; lean <= 3; lean++) {
    for (final (wide, tall, px, py) in Rules.settings()) {
      final apart = Rules.apart(wide, tall, lean, px, py);
      check(apart == 2 * lean * wide,
          'a hall $wide by $tall leaned $lean at ($px, $py) came apart by '
          '$apart');
      final (one, two) = Rules.sumsByAlgebra(wide, tall, lean, px, py);
      check(one - two == apart, 'the algebra of a leaned hall');
    }
  }

  // The asks.
  for (final level in Levels.all) {
    check(ways[level.name] == level.ways,
        '${level.name}: ${ways[level.name]} against ${level.ways}');
    if (level.winnable) {
      final aim = level.aim!;
      check(level.meets(aim.$1, aim.$2, aim.$3, aim.$4),
          '${level.name}: the aim misses');
      final best = cheapest[level.name]!;
      check(level.taps(aim.$1, aim.$2, aim.$3, aim.$4) ==
              level.taps(best.$1, best.$2, best.$3, best.$4),
          '${level.name}: the aim is not the cheapest');
    } else {
      check(level.aim == null && ways[level.name] == 0,
          '${level.name} was landed');
    }
  }

  // The pointer lands every ask it can.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 60) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.follow(aim);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  if (failed) {
    stderr.writeln('the hall is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every hall from ${Rules.leastSide} by ${Rules.leastSide} to '
        '${Rules.mostSide} by ${Rules.mostSide} taken with the peg on every '
        'point of the field, ${commas(settings)} standings, and the two sums '
        'worked out twice, once by squaring the four distances and adding '
        'the opposite pairs and once by multiplying the brackets out, which '
        'never takes a distance at all: the two agree on every standing, and '
        'so do the sums themselves, ${commas(settings)} times out of '
        '${commas(settings)}')
    ..write('; the peg stands where all four distances are whole numbers of '
        'paces on $whole standings, and on $wholeInside of those it is '
        'inside the hall, both of them the six by eight and its turn about '
        'with the peg three and four paces in, every distance five')
    ..write('; all four distances come out alike on $same standings, which '
        'are the halls of even sides with the peg at the middle')
    ..write('; lean the far wall over and the two sums part company by '
        'twice the lean times the width, the same amount wherever the peg '
        'stands, which the sweep checks over all ${commas(settings)} '
        'standings at leans of one, two and three');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(settings)} standings land '
            'it, the cheapest in ${level.fewest} '
            '${level.fewest == 1 ? 'tap' : 'taps'}'
        : 'none of the ${commas(settings)}, and the lean says why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
