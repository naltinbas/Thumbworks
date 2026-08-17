import 'dart:io';

import 'package:reckonby/count/levels.dart';
import 'package:reckonby/count/play.dart';
import 'package:reckonby/count/rules.dart';

/// Reads every setting of the wheels twice, counts the house up a tick
/// at a time, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_wheels.dart
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

  int factorial(int n) {
    var out = 1;
    for (var k = 2; k <= n; k++) {
      out *= k;
    }
    return out;
  }

  // The folding sum, checked well past the wheels the house has.
  for (var k = 1; k <= 12; k++) {
    check(k * factorial(k) == factorial(k + 1) - factorial(k),
        '$k times $k factorial');
    var added = 0;
    for (var i = 1; i <= k; i++) {
      added += i * factorial(i);
    }
    check(added == factorial(k + 1) - 1, 'the sum to $k: $added');
  }
  check(Rules.most == factorial(Rules.wheels + 1) - 1, 'the top: ${Rules.most}');
  check(Rules.most == 719, 'the top is not 719');
  check(Rules.howManyReadings == factorial(Rules.wheels + 1),
      'the readings: ${Rules.howManyReadings}');

  // Every setting, read twice and counted up.
  final all = Rules.readings();
  check(all.length == Rules.howManyReadings && all.length == 720,
      'settings walked: ${all.length}');
  final seen = <int, List<int>>{};
  for (var tick = 0; tick < all.length; tick++) {
    final at = all[tick];
    check(Rules.valid(at), 'a wheel off its stop at $at');
    final added = Rules.reading(at);
    // The odometer's tick count is the reading, which is the second
    // voice: it adds nothing and carries instead.
    check(added == tick, 'the setting ${Rules.tellWheels(at)} on tick $tick '
        'adds to $added');
    // And dividing the number back down gives the same wheels.
    check(Rules.wheelsFor(added)!.join(',') == at.join(','),
        'the wheels of $added');
    check(!seen.containsKey(added),
        '$added reads two ways: ${seen[added]} and $at');
    seen[added] = at;
    // No setting of the cheaper wheels can make up the next wheel's
    // worth, which is what makes the reading unique.
    for (var k = 1; k <= Rules.wheels; k++) {
      var under = 0;
      for (var i = 1; i < k; i++) {
        under += Rules.top(i) * Rules.worth(i);
      }
      check(under == Rules.worth(k) - 1,
          'the wheels under $k come to $under, not ${Rules.worth(k) - 1}');
    }
  }
  check(seen.length == 720, 'numbers read: ${seen.length}');
  for (var number = 0; number <= Rules.most; number++) {
    check(seen.containsKey(number), '$number is not read at all');
  }
  check(Rules.wheelsFor(Rules.most + 1) == null, 'the house read 720');
  check(Rules.wheelsFor(-1) == null, 'the house read a number below nothing');
  check(Rules.tickUp(all.last) == null, 'the house ticked past its top');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (final at in all) {
      if (level.meets(at)) n++;
    }
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    if (level.winnable) {
      check(level.aim != null && level.meets(level.aim!),
          '${level.name}: the aim misses');
      // The turns are the wheels of the number added up.
      var added = 0;
      for (final wheel in level.aim!) {
        added += wheel;
      }
      check(level.fewest == added,
          '${level.name}: ${level.fewest} turns against $added');
    } else {
      check(level.aim == null && level.number > Rules.most,
          '${level.name} can be read');
    }
    check(!level.meets(Rules.opening), '${level.name} is landed at the opening');
  }

  // The pointer lands every ask it can, in the fewest turns.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 40) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.turn(aim.$1, aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  // The hopeless ask: the sham admits it after four readings, well
  // before the wheels are anywhere near their tops.
  var stuck = Play.of(Levels.all.last);
  for (var turn = 0; turn < 4; turn++) {
    stuck = stuck.turn(1 + turn % Rules.wheels, 1);
  }
  check(stuck.seen.length == 4, 'the hopeless ask saw ${stuck.seen.length}');
  check(stuck.gaveUp, 'the hopeless ask did not admit it');
  // And the top itself, which is what puts 720 out of reach.
  final full = [for (var k = 1; k <= Rules.wheels; k++) Rules.top(k)];
  check(Rules.reading(full) == Rules.most && Rules.most == 719,
      'the full house reads ${Rules.reading(full)}');
  check(Play.standing(Levels.all.last, full).under == 0,
      'the full house is not at the top');

  if (failed) {
    stderr.writeln('the counting house is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every setting of the ${Rules.wheels} wheels taken, '
        '${commas(all.length)} of them, and each read twice: once by adding '
        'the wheels up, each times the factorial of its place, and once by '
        'counting the house up a tick at a time from nothing and carrying as '
        'an odometer does, which adds nothing at all: the tick a setting '
        'falls on is what it adds to, on every one of the '
        '${commas(all.length)}')
    ..write('; the ${commas(all.length)} settings read the '
        '${commas(all.length)} numbers from nothing to ${Rules.most}, each '
        'number exactly once and none of them twice, and dividing a number '
        'back down by 2, then 3, then 4 and on returns the wheels it came '
        'from')
    ..write('; the wheels under the kth, all at their tops, come to one less '
        'than the kth is worth, which is why no two settings can read the '
        'same: ')
    ..write([
      for (var k = 2; k <= Rules.wheels; k++)
        'under the ${Rules.tellWorth(k)} wheel they come to '
            '${Rules.worth(k) - 1}'
    ].join(', '))
    ..write('; and the top is ${Rules.most} because k times k factorial is '
        '(k + 1) factorial less k factorial, so the wheels at their tops fold '
        'up to ${Rules.wheels + 1} factorial less one, checked out to 12 '
        'wheels where it comes to ${commas(factorial(13) - 1)}');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? 'one setting of the ${commas(all.length)} reads it, in '
            '${level.fewest} turns'
        : 'no setting of the ${commas(all.length)}, and the folding sum says '
            'why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
