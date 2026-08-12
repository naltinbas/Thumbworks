import 'dart:io';

import 'package:tanglemere/web/rules.dart';
import 'package:tanglemere/web/webs.dart';

/// Searches every weave, sweeps every painting, and refuses the bake
/// on any disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  final five = Rules(5);
  final six = Rules(6);

  // The Ramsey pair, swept outright.
  final fiveSafe = five.safePaintings();
  final sixSafe = six.safePaintings();
  claim(fiveSafe == 12, 'five posts hold $fiveSafe safe paintings');
  claim(sixSafe == 0, 'six posts hold $sixSafe safe paintings');

  // Every safe five-post painting is a ring of each colour.
  var rings = 0;
  for (var paint = 0; paint < (1 << five.threads); paint++) {
    var mono = false;
    for (final (x, y, z) in five.triangles) {
      final a = (paint >> x) & 1;
      final b = (paint >> y) & 1;
      final c = (paint >> z) & 1;
      if (a == b && b == c) {
        mono = true;
        break;
      }
    }
    if (!mono) {
      claim(five.isRingAndStar(paint),
          'a safe five-post painting is not two rings');
      rings++;
    }
  }
  claim(rings == 12, 'counted $rings safe paintings the second way');

  // The counting argument, run on every six-post painting: it must
  // hand back a one-colour triangle every time.
  for (var paint = 0; paint < (1 << six.threads); paint++) {
    final (x, y, z) = six.pigeonTriangle(paint);
    final a = (paint >> x) & 1;
    final b = (paint >> y) & 1;
    final c = (paint >> z) & 1;
    claim(a == b && b == c,
        'the counting argument missed on painting $paint');
  }

  stdout.writeln('five posts: 12 safe paintings, every one two '
      'rings; six posts: none of 32,768, and the counting argument '
      'finds the triangle on every painting');
  stdout.writeln('');

  for (var number = 0; number < Webs.count; number++) {
    final web = Webs.at(number);
    final rules = web.dots == 5 ? five : six;
    // The player's standing: mover value if first, else the reply's.
    final standing = web.playerFirst
        ? rules.value(0, 0)
        : -rules.value(0, 0);
    claim(standing == web.standing,
        '${web.name}: search says $standing, written ${web.standing}');

    final verdict = switch (web.standing) {
      1 => 'the player holds the win',
      0 => 'best weaving holds the draw',
      _ => 'lost before the first thread',
    };
    stdout.writeln(' ${number + 1} ${web.name.padRight(16)} '
        '${web.dots} posts, ${web.playerFirst ? 'first' : 'second'} '
        'seat  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
