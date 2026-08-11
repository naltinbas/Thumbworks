import 'dart:io';

import 'package:ringmarsh/ring/rules.dart';
import 'package:ringmarsh/ring/watches.dart';

/// Sweeps every ring of every watch, runs the shift-walk, and refuses
/// the bake on any disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Watches.count; number++) {
    final watch = Watches.at(number);
    final rules = Rules(watch.span, watch.length);

    final answers =
        rules.fullRingsUnder(watch.lockedPlaces, watch.lockedBits);
    claim(answers.length == watch.ways,
        '${watch.name}: ${answers.length} ways, written ${watch.ways}');
    for (final ring in answers) {
      claim(rules.isFull(ring), '${watch.name}: a way is not full');
    }

    // The shift-walk voice, wherever the ring is the right length for
    // a full watch at all.
    if (watch.lockedPlaces == 0 && watch.length == watch.words) {
      final built = rules.byShiftWalk();
      claim(rules.isFull(built),
          '${watch.name}: the shift-walk built a ring that is not '
          'full');
    }

    final verdict = watch.winnable
        ? '${watch.ways} of ${1 << watch.length} rings set it'
        : 'no ring of ${1 << watch.length} sets it';
    stdout.writeln(' ${number + 1} ${watch.name.padRight(16)} '
        'words of ${watch.span} round ${watch.length}  $verdict'
        '${watch.lockedPlaces != 0 ? '  (four lanterns held)' : ''}');
  }

  stdout.writeln('\nthe short ring is short the counting way too: '
      'seven places spell at most seven words and the watch asks '
      'eight');

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
