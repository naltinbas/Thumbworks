// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:pinderwell/drive/cold.dart';
import 'package:pinderwell/drive/fields.dart';

/// Walks every shipped field and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_fields.dart  (or `make fields`)
void main() {
  // The two constructions first, so the ledger under them can be believed.
  final swept = Cold.sweep(60);
  final laddered = Cold.ladder(60);
  var squares = 0;
  for (var east = 0; east <= 60; east++) {
    for (var north = 0; north <= 60; north++) {
      final cold = swept[east][north];
      if (cold != laddered.contains((east, north))) {
        throw StateError('sweep and ladder part at $east,$north');
      }
      if (cold) squares++;
    }
  }
  print('sweep and ladder agree on every square of a sixty-pace field: '
      '$squares cold\n');

  var wrong = 0;
  for (var number = 0; number < Fields.count; number++) {
    final field = Fields.at(number);
    final fewest = Cold.fewestFrom(field.east, field.north);
    final agree = fewest == field.fewest;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${field.name.padRight(17)} '
        'ewe ${field.east.toString().padLeft(2)} east '
        '${field.north.toString().padLeft(2)} north  '
        '${fewest == null ? "the pinder cannot be beaten" : "fewest $fewest"}'
        '  written down ${field.fewest ?? "none"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong field${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped fields are not what they claim');
  }
}
