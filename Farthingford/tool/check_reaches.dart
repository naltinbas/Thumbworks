import 'dart:io';

import 'package:farthingford/ford/reaches.dart';
import 'package:farthingford/ford/rules.dart';

/// Reads every ford of the stream, proves the kissing against the
/// crossing number, walks every reach to its landing, and refuses
/// the bake on any disagreement: this is what `make reaches` runs,
/// and the README quotes its ledger verbatim.
void main() {
  // Kissing circles and a crossing number of one are the same
  // thing, checked on every pair of fords to depth eight.
  final fords = Rules.fords(8);
  var pairs = 0;
  for (var one = 0; one < fords.length; one++) {
    for (var two = one + 1; two < fords.length; two++) {
      pairs++;
      final (p, q) = fords[one];
      final (r, s) = fords[two];
      final kiss = Rules.circlesKiss(p, q, r, s);
      final unit =
          (Rules.crossing(p, q, r, s)).abs() == 1;
      if (kiss != unit) {
        stderr.writeln('KISS AND CROSSING DISAGREE at '
            '$p/$q, $r/$s');
        exit(1);
      }
    }
  }

  // The depth lemma, swept: between any two kissing banks of the
  // stream, the one shallowest ford is the mediant, sitting at
  // exactly the banks' depths put together. Each pair is swept to
  // its own mediant's depth.
  var kissing = 0;
  for (var one = 0; one < fords.length; one++) {
    for (var two = one + 1; two < fords.length; two++) {
      var (a, b) = fords[one];
      var (c, d) = fords[two];
      if (Rules.crossing(a, b, c, d).abs() != 1) continue;
      kissing++;
      // The sweep wants its banks in stream order.
      if (a * d > c * b) {
        final (p, q) = (a, b);
        (a, b) = (c, d);
        (c, d) = (p, q);
      }
      final (mp, mq) = Rules.mediant(a, b, c, d);
      final shallowest =
          Rules.shallowestBetween(a, b, c, d, mq);
      if (shallowest.length != 1 ||
          shallowest.first.$1 != mp ||
          shallowest.first.$2 != mq) {
        stderr.writeln('THE MEDIANT WAS NOT SHALLOWEST between '
            '$a/$b and $c/$d');
        exit(1);
      }
    }
  }

  stdout.writeln(
      'two fords\' circles kiss exactly when their crossing number '
      'is one, checked on all $pairs pairs to depth eight; and '
      'between each of the $kissing kissing pairs the one '
      'shallowest ford is their mediant, at exactly the banks\' '
      'depths put together');
  stdout.writeln('');

  for (var number = 0; number < Reaches.count; number++) {
    final reach = Reaches.at(number);

    if (reach.winnable) {
      final target = reach.target!;
      final walked = Rules.wadesTo(target.$1, target.$2);
      if (walked != reach.wades) {
        stderr.writeln('${reach.name}: label says ${reach.wades}, '
            'walk says $walked');
        exit(1);
      }
    } else {
      final (a, b) = reach.startA;
      final (c, d) = reach.startC;
      final shallowest = Rules.shallowestBetween(a, b, c, d, 12);
      if (shallowest.first.$2 >= reach.shallowerThan! == false) {
        stderr.writeln('${reach.name}: a shallow ford stood');
        exit(1);
      }
    }

    final name = reach.name.padRight(19);
    stdout.writeln(reach.winnable
        ? ' ${number + 1} $name ${reach.task}: ${reach.wades} '
            'wade${reach.wades == 1 ? '' : 's'} from the banks'
        : ' ${number + 1} $name between ${reach.startA.$1}/'
            '${reach.startA.$2} and ${reach.startC.$1}/'
            '${reach.startC.$2}, ${reach.task}: no ford of any '
            'depth does');
  }
}
