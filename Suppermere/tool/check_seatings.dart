import 'dart:io';

import 'package:suppermere/hall/levels.dart';
import 'package:suppermere/hall/rules.dart';

/// Sweeps every seating of every supper, holds the walk and the odd
/// ring to the sweep, on the suppers and on every quarrel map of five,
/// and refuses the bake on any disagreement: this is what `make
/// seatings` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, the walk and the ring.
  for (final level in Levels.all) {
    final rules = level.rules;
    final (landing, all) = rules.sweep();
    if (landing != level.ways || all != level.seatings) {
      stderr.writeln('${level.name}: sweep finds $landing of $all, label says ${level.ways} of ${level.seatings}');
      exit(1);
    }
    final walk = rules.byWalking();
    final ring = rules.oddRing();
    if ((walk == null) == level.winnable || (ring == null) != level.winnable) {
      stderr.writeln('${level.name}: walk ${walk == null ? 'clashes' : 'seats'}, ring $ring');
      exit(1);
    }
    if (walk != null && (!rules.lands(walk) || landing != (1 << rules.parties))) {
      stderr.writeln('${level.name}: THE WALK\'S SEATING FAILS, OR $landing IS NOT 2 TO THE ${rules.parties} PARTIES');
      exit(1);
    }
    if (ring != null) {
      if (ring.length.isEven || ring.length < 3) {
        stderr.writeln('${level.name}: RING $ring IS NOT ODD');
        exit(1);
      }
      for (var i = 0; i < ring.length; i++) {
        final a = ring[i], b = ring[(i + 1) % ring.length];
        if (!level.quarrels.contains((a < b ? a : b, a < b ? b : a))) {
          stderr.writeln('${level.name}: RING $ring HAS NO QUARREL $a $b');
          exit(1);
        }
      }
    }
    for (final (a, b) in level.quarrels) {
      if (a >= b || b >= level.guests) {
        stderr.writeln('${level.name}: BAD QUARREL ($a, $b)');
        exit(1);
      }
    }
  }

  // Every quarrel map on five guests, 1,024 of them: the sweep lands
  // some seating exactly when the walk seats everyone, exactly when no
  // odd ring is found; when it lands, it lands 2 to the parties ways;
  // and every ring found is odd and made of quarrels.
  final pairs = <Quarrel>[for (var a = 0; a < 5; a++) for (var b = a + 1; b < 5; b++) (a, b)];
  var maps = 0, seatable = 0;
  for (var mask = 0; mask < (1 << pairs.length); mask++) {
    final quarrels = [for (var i = 0; i < pairs.length; i++) if ((mask >> i) & 1 == 1) pairs[i]];
    final rules = Rules(5, quarrels);
    maps++;
    final (landing, all) = rules.sweep();
    final walk = rules.byWalking();
    final ring = rules.oddRing();
    if (all != 32 || (walk == null) != (landing == 0) || (ring == null) != (walk != null)) {
      stderr.writeln('MAP $mask: sweep $landing, walk $walk, ring $ring');
      exit(1);
    }
    if (walk != null) {
      seatable++;
      if (!rules.lands(walk) || landing != (1 << rules.parties)) {
        stderr.writeln('MAP $mask: WALK FAILS OR COUNT $landing');
        exit(1);
      }
    } else {
      if (ring!.length.isEven || ring.length < 3) {
        stderr.writeln('MAP $mask: RING $ring');
        exit(1);
      }
      for (var i = 0; i < ring.length; i++) {
        final a = ring[i], b = ring[(i + 1) % ring.length];
        if (!quarrels.contains((a < b ? a : b, a < b ? b : a))) {
          stderr.writeln('MAP $mask: RING $ring BROKEN AT $a $b');
          exit(1);
        }
      }
    }
  }

  stdout.writeln(
      'every seating of every supper swept, and every quarrel map of five '
      'guests taken whole, ${_commas(maps)} maps: the sweep finds a seating exactly '
      'when the walk seats every guest across from every quarreller, '
      'exactly when no odd ring of quarrels is found, $seatable maps of the '
      '${_commas(maps)}, and where it does the seatings number two to the power of '
      'the parties; every ring found is odd and made of quarrels; the four '
      'ring seats 2 ways of 16, the family 2 of 64, the two rings 4 of 256, '
      'the cube 2 of 256, and the five ring none of 32');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(13);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.seatings} seatings land it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.seatings}, and the odd ring said so first');
  }
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
