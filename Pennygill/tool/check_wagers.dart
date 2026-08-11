// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:pennygill/toss/call.dart';
import 'package:pennygill/toss/odds.dart';

/// Prints the whole board: every call, the house's reply, and the odds by
/// both reckonings.
///
/// Run with: dart run tool/check_wagers.dart  (or `make board`)
void main() {
  // Conway against the walk on every pair first.
  var pairs = 0;
  for (final one in Call.all) {
    for (final other in Call.all) {
      if (one == other) continue;
      if (Odds.byConway(one, other) != Odds.byWalk(one, other)) {
        throw StateError('the reckonings part at $one vs $other');
      }
      pairs++;
    }
  }
  print('Conway and the walk agree on all $pairs pairs of calls\n');

  for (final call in Call.all) {
    final reply = call.beatenBy;
    final odds = Odds.byWalk(call, reply);
    print('${call.said}  the house calls ${reply.said}  '
        'and shows first $odds');
    if (odds.asDouble <= 0.5) {
      throw StateError('the reply fails to beat ${call.said}');
    }
  }

  // The even reply is exactly even, every call.
  for (final call in Call.all) {
    final even = Odds.byWalk(call, Call(call.flips ^ 7));
    if (even != Ratio.of(1, 2)) {
      throw StateError('the even table is not even at ${call.said}');
    }
  }
  print('\nthe turned-over reply is exactly even on all eight calls');
}
