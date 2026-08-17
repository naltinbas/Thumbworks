import 'dart:io';

import 'package:bondwell/bond/levels.dart';
import 'package:bondwell/bond/play.dart';
import 'package:bondwell/bond/rules.dart';

/// Splits every garment two ways, tries every division of every estate,
/// and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_purses.dart
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

  // A garment claimed whole by one and half by the other, with the
  // whole garment on the table: three quarters and one quarter.
  check(Rules.garmentParts(4, 2, 4) == (36, 12), 'the garment itself');
  check(Rules.garmentParts(2, 2, 2) == (12, 12), 'a garment both claim whole');
  check(Rules.garmentParts(10, 4, 12) == (108, 36), 'a bigger garment');

  // Every garment there is, split by the Mishnah's recipe and by the
  // half-claims rule, and the small ones by the nucleolus found the
  // long way.
  const most = 100, searched = 8;
  var pairs = 0, searchedPairs = 0, halfCoins = 0;
  for (var a = 1; a <= most; a++) {
    for (var b = 1; b <= most; b++) {
      for (var estate = 0; estate <= a + b; estate++) {
        pairs++;
        final byRule = Rules.garmentParts(a, b, estate);
        check(byRule == Rules.halfClaimsPairParts(a, b, estate),
            'the garment of $a and $b over $estate: $byRule against '
            '${Rules.halfClaimsPairParts(a, b, estate)}');
        check(
            byRule.$1 + byRule.$2 ==
                Rules.parts * (estate < a + b ? estate : a + b),
            'the garment of $a and $b over $estate does not add up');
        check(byRule.$1 >= 0 && byRule.$2 >= 0,
            'the garment of $a and $b over $estate goes negative');
        check(byRule.$1 % (Rules.parts ~/ 2) == 0,
            'the garment of $a and $b over $estate is finer than a half coin');
        if (byRule.$1 % Rules.parts != 0) halfCoins++;
        if (a <= searched && b <= searched) {
          searchedPairs++;
          check(byRule == Rules.nucleolusBySearch(a, b, estate),
              'the nucleolus of $a and $b over $estate');
        }
      }
    }
  }
  check(pairs == 1020000, 'garments swept: $pairs');

  // Every division of every estate the bonds allow, against the
  // half-claims rule, which never looks at a pair.
  final total = Rules.bonds.reduce((a, b) => a + b);
  var divisions = 0, whole = 0, between = 0;
  final landings = <int, List<int>>{};
  for (var estate = 0; estate <= total; estate++) {
    final winners = <List<int>>[];
    for (final split in Rules.divisions(estate)) {
      divisions++;
      if (Rules.allLevel(split)) winners.add(split);
    }
    final byRule = Rules.division(estate);
    if (byRule == null) {
      // The rule's shares fall between coins, so no division of whole
      // coins can level the scales.
      between++;
      check(winners.isEmpty,
          'estate $estate levels ${winners.length} ways off the rule');
    } else {
      whole++;
      check(winners.length == 1,
          'estate $estate levels ${winners.length} ways');
      check(byRule.join(',') == winners.first.join(','),
          'estate $estate: ${winners.first} against $byRule');
      landings[estate] = winners.first;
    }
  }

  // The Talmud's three rows, at twenty-five zuz to three coins.
  const rows = {100: [100, 100, 100], 200: [150, 225, 225], 300: [150, 300, 450]};
  for (final row in rows.entries) {
    final coins = landings[row.key * Rules.zuzUnder ~/ Rules.zuzOver]!;
    for (var i = 0; i < Rules.heirs; i++) {
      // The rows are held as three times the zuz, so that the hundred
      // divided three ways stays a whole number.
      check(Rules.zuzOver * coins[i] == row.value[i],
          'the Talmud row of ${row.key}: ${coins[i]} coins against '
          '${row.value[i]} thirds of a zuz');
    }
  }

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (final split in Rules.divisions(level.estate)) {
      if (level.meets(split)) n++;
    }
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    final aim = level.aim;
    if (level.winnable) {
      check(aim != null && level.meets(aim), '${level.name}: the aim misses');
    } else {
      check(aim == null, '${level.name} has an aim');
    }
    check(level.divisions == Rules.howManyDivisions(level.estate),
        '${level.name}: divisions');
  }

  // The pointer lands every ask it can, in the fewest taps the dials
  // allow.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 40) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.step(aim.$1, aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  // The hopeless ask, worn down by three tries with the long bond
  // ahead.
  var stuck = Play.of(Levels.all.last);
  for (final tryOut in [[0, 0, 12], [1, 2, 9], [2, 4, 6]]) {
    stuck = Play.of(Levels.all.last);
    for (var i = 0; i < Rules.heirs; i++) {
      if (tryOut[i] > 0) stuck = stuck.step(i, tryOut[i]);
    }
    check(stuck.chest == 0, 'a try that does not fill the purses');
    check(!stuck.allLevel, 'a try with the long bond ahead levels the scales');
  }

  if (failed) {
    stderr.writeln('the estate is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every garment there is taken, claims of one coin to '
        '${commas(most)} on both sides and every estate from nothing up to '
        'the two claims together, ${commas(pairs)} in all, and each one '
        'split twice, once by the Mishnah\'s recipe of conceding what the '
        'estate passes the other claim and halving the rest, and once by '
        'the half-claims rule Aumann and Maschler read the table with, '
        'which never mentions a concession: the two agree on every one, '
        '${commas(halfCoins)} of the splits landing on a half coin and none '
        'of them on anything finer, and on the ${commas(searchedPairs)} '
        'smallest the nucleolus found the long way, by trying every split '
        'and keeping the one whose worst-off coalition is least badly off, '
        'agrees as well')
    ..write('; the garment of the Mishnah itself, one claiming the whole and '
        'one the half, goes three quarters and one quarter')
    ..write('; then every division of every estate from nothing to the '
        '$total coins the bonds come to, ${commas(divisions)} divisions in '
        'all, with a scale between each pair of purses: of the '
        '${total + 1} estates, $whole leave shares that land on whole coins '
        'and each of those hangs all three scales level on exactly one '
        'division, the one the half-claims rule gives, while the other '
        '$between fall between coins and no division of them levels '
        'anything')
    ..write('; the Talmud\'s own rows come out of it at twenty-five zuz to '
        'three coins: ')
    ..write([
      for (final estate in [12, 24, 36])
        '$estate coins go ${landings[estate]!.join(', ')}, which is '
            '${landings[estate]!.map(Rules.tellZuz).join(', ')} zuz'
    ].join('; '))
    ..write('; and with twelve coins on the table, under every bond, no heir '
        'can concede anything, so every pair splits even and the three '
        'purses come out equal, which is why no division of that estate '
        'puts the longest bond ahead of the shortest');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(level.divisions)} divisions lands '
            'it, in ${level.fewest} taps'
        : 'none of the ${commas(level.divisions)}, and twelve coins under '
            'every bond say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
