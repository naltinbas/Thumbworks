import 'dart:io';

import 'package:copestone/wall/pitches.dart';
import 'package:copestone/wall/rules.dart';

/// Lays every wall of every pitch, proves the claims, and refuses
/// the bake on any disagreement: this is what `make pitches` runs,
/// and the README quotes its ledger verbatim.
void main() {
  // Two kinds die at the third course: six walls of three, none of
  // four, and the tallest hunt agrees.
  if (Rules.soundWalls(2, 3) != 2 ||
      Rules.soundWalls(2, 4) != 0 ||
      Rules.tallest(2, 10) != 3) {
    stderr.writeln('THE TWO-KIND WALL MISCOUNTED');
    exit(1);
  }

  // The palindrome pens itself in with every course sound.
  const penned = [0, 1, 0, 2, 0, 1, 0];
  if (!Rules.sound(penned)) {
    stderr.writeln('THE PALINDROME FELL');
    exit(1);
  }
  for (var kind = 0; kind < 3; kind++) {
    if (Rules.sound([...penned, kind])) {
      stderr.writeln('THE PALINDROME GREW');
      exit(1);
    }
  }

  // The sweep's counts at the asked heights.
  if (Rules.soundWalls(3, 8) != 78 ||
      Rules.soundWalls(3, 10) != 144 ||
      Rules.soundWalls(3, 12) != 264) {
    stderr.writeln('A SOUND-WALL COUNT BROKE: '
        '${Rules.soundWalls(3, 8)}, ${Rules.soundWalls(3, 10)}, '
        '${Rules.soundWalls(3, 12)}');
    exit(1);
  }

  // A sound wall never limps: short of its height it either still
  // climbs or is penned outright.
  for (final pitch in Pitches.all) {
    if (!pitch.winnable) continue;
    if (!Rules.neverLimps(pitch.kinds, pitch.height)) {
      stderr.writeln('${pitch.name}: A WALL LIMPED');
      exit(1);
    }
  }

  for (final pitch in Pitches.all) {
    final stands = Rules.soundWalls(pitch.kinds, pitch.height) > 0;
    if (stands != pitch.reachable) {
      stderr.writeln('${pitch.name}: the label lied');
      exit(1);
    }
  }

  stdout.writeln(
      'no run of courses laid twice over: the sweep lays every '
      'wall there is, two kinds of stone die at the third course, '
      'three kinds climb past every height asked, and the '
      'palindrome a-b-a-c-a-b-a stands sound yet pens itself in');
  stdout.writeln('');

  for (var number = 0; number < Pitches.count; number++) {
    final pitch = Pitches.at(number);
    final name = pitch.name.padRight(18);
    final kinds = '${pitch.kinds} kinds';
    stdout.writeln(pitch.winnable
        ? ' ${number + 1} $name $kinds  ${pitch.task}: '
            '${Rules.soundWalls(pitch.kinds, pitch.height)} sound '
            'walls stand that high'
        : ' ${number + 1} $name $kinds  ${pitch.task}: all '
            '${1 << pitch.height} walls of four carry a doubled '
            'run, and three is the roof');
  }
}
