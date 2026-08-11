import 'dart:io';

import 'package:hirebeck/book/days.dart';
import 'package:hirebeck/book/rules.dart';

/// Sweeps every choice of every day, strikes the piercing o'clocks,
/// and refuses the bake on any disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Days.count; number++) {
    final day = Days.at(number);
    final rules = Rules(day.starts, day.ends);

    final fullest = rules.fullestBySweep();
    claim(fullest == day.fullest,
        '${day.name}: sweep says $fullest, written ${day.fullest}');
    claim(rules.fullestWays() == day.ways,
        '${day.name}: ways ${rules.fullestWays()}, written ${day.ways}');
    claim(Rules.weigh(rules.byEarlyFinish()) == fullest,
        '${day.name}: the early-finish rule fell short');
    claim(rules.stands(rules.byEarlyFinish()),
        '${day.name}: the early-finish book clashes');

    // The piercing certificate: as many strikes as the fullest book,
    // one inside every hiring.
    final strikes = rules.piercing();
    claim(strikes.length == fullest,
        '${day.name}: ${strikes.length} strikes against $fullest');
    claim(rules.pierced(strikes),
        '${day.name}: a hiring dodges every strike');

    final verdict = day.winnable
        ? 'ask ${day.ask} met ${day.ways} way${day.ways == 1 ? '' : 's'}'
        : 'ask ${day.ask} unmeetable: ${strikes.length} o\'clocks '
            'pierce every hiring';
    stdout.writeln(' ${number + 1} ${day.name.padRight(17)} '
        '${day.hirings} hirings, fullest ${day.fullest}  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
