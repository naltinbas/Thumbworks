import 'dart:io';

import 'package:lampfield/lamp/levels.dart';
import 'package:lampfield/lamp/play.dart';
import 'package:lampfield/lamp/rules.dart';

/// Sends every message, puts out every lamp, reads each one back two
/// ways, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_lamps.dart
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

  final all = Rules.messages();
  check(all.length == Rules.howManyMessages && all.length == 256,
      'messages: ${all.length}');
  check(all.map((m) => m.join()).toSet().length == 256, 'a message twice');

  // The nine sums and how the messages fall among them.
  final classes = <int, List<List<int>>>{};
  for (final message in all) {
    check(Rules.valid(message), 'a message that is not one: $message');
    classes.putIfAbsent(Rules.over9(message), () => []).add(message);
  }
  check(classes.length == Rules.over, 'sums seen: ${classes.length}');
  final sizes = {for (final e in classes.entries) e.key: e.value.length};
  check(sizes[0] == 30, 'the code holds ${sizes[0]}');
  var most = 0;
  for (final n in sizes.values) {
    if (n > most) most = n;
  }
  check(most == 30, 'the largest sum holds $most');
  check(most >= all.length ~/ Rules.over,
      'the largest sum is under the share ${all.length ~/ Rules.over}');
  var total = 0;
  for (final n in sizes.values) {
    total += n;
  }
  check(total == 256, 'the sums hold $total messages between them');

  final code = classes[0]!;

  // The second voice: for a message with a lamp out, go through all 256
  // and keep the ones in the code that could have left it. It counts
  // rather than reasons.
  List<List<int>> couldBe(List<int> seen) => [
        for (final message in code)
          if ([
            for (var gone = 1; gone <= Rules.lamps; gone++)
              Rules.lost(message, gone).join(),
          ].contains(seen.join()))
            message,
      ];

  var readings = 0;
  for (final message in code) {
    for (var gone = 1; gone <= Rules.lamps; gone++) {
      readings++;
      final seen = Rules.lost(message, gone);
      check(seen.length == Rules.lamps - 1, 'a lost lamp left ${seen.length}');
      // The reader's arithmetic.
      final read = Rules.read(seen);
      check(read != null && read.join() == message.join(),
          'the reader made ${read?.join()} of ${message.join()} with lamp '
          '$gone out');
      // And the counting, which must find that message and no other.
      final could = couldBe(seen);
      check(could.length == 1 && could.first.join() == message.join(),
          '${could.length} messages could leave ${seen.join()}');
    }
  }
  check(readings == 240, 'readings: $readings');

  // No two messages in the code look the same with a lamp out.
  final left = <String, String>{};
  for (final message in code) {
    for (var gone = 1; gone <= Rules.lamps; gone++) {
      final key = Rules.lost(message, gone).join();
      final held = left[key];
      check(held == null || held == message.join(),
          'two messages leave $key: $held and ${message.join()}');
      left[key] = message.join();
    }
  }

  // The asks.
  for (final level in Levels.all) {
    var n = 0, cheapest = 99;
    for (final message in all) {
      if (!level.meets(message)) continue;
      n++;
      final taps = Rules.taps(Rules.opening, message);
      if (taps < cheapest) cheapest = taps;
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

  // The pointer lands every ask it can, in the fewest lamps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final lamp = play.next;
      check(lamp != null, '${level.name} lost its pointer');
      if (lamp == null) break;
      play = play.tap(lamp);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  // The hopeless ask, worn down by four messages.
  var stuck = Play.of(Levels.all.last);
  for (final lamp in [1, 2, 3, 4]) {
    stuck = stuck.tap(lamp);
  }
  check(stuck.seen.length == 4, 'the hopeless ask saw ${stuck.seen.length}');
  check(stuck.gaveUp, 'the hopeless ask did not admit it');

  if (failed) {
    stderr.writeln('the valley is not sound; no bake');
    exit(1);
  }

  final spread = (sizes.keys.toList()..sort()).map((k) => '${sizes[k]} at $k');
  final ledger = StringBuffer()
    ..write('every message the ${Rules.lamps} lamps can send taken, all '
        '${commas(all.length)} of them, and sorted by what the places of '
        'their lit lamps add to over ${Rules.over}: ${spread.join(', ')}, '
        'which is ${commas(all.length)} messages between '
        '${classes.length} sums, so the largest of them holds at least '
        '${all.length ~/ Rules.over} and the code, the sum that comes to '
        'nothing, holds $most')
    ..write('; then every one of the ${code.length} messages in the code sent '
        'with each of its ${Rules.lamps} lamps put out in turn, '
        '${commas(readings)} readings, and each reading made twice: once by '
        'the reader\'s arithmetic, which is told nothing but the seven lamps '
        'still showing and puts one back by counting how far short of '
        'nothing the sum falls, and once by going through all '
        '${commas(all.length)} messages and keeping the ones in the code that '
        'could have left those seven showing')
    ..write('; the two agree on every reading, the counting never finds two, '
        'and the arithmetic never gets one wrong')
    ..write('; and no two of the ${code.length} messages in the code look the '
        'same with a lamp out, which is why the reader never has a choice to '
        'make');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(all.length)} messages '
            '${level.ways == 1 ? 'lands' : 'land'} it, the nearest '
            '${level.fewest} ${level.fewest == 1 ? 'lamp' : 'lamps'} off'
        : 'none of the ${commas(all.length)}, and the sums say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
