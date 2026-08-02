import 'dart:math';

import 'ground.dart';
import 'stretches.dart';

/// One stretch as it was written down: the tiles, how many presses it needs,
/// and the line that proved it.
class Piece {
  const Piece(this.written, this.jumps, this.holds);

  final String written;

  /// How many separate presses the proof needed. This is the difficulty.
  final int jumps;

  /// The steps the button was held on in that proof.
  final List<int> holds;

  Ground get ground => Ground.of(written);
  int get length => written.length;
}

/// The stretches the game is built from.
///
/// Nothing here was invented at runtime. Every one was played to the end by
/// the verifier before it went in the list — see tool/build_stretches.dart —
/// because checking a stretch means playing it, and playing it takes long
/// enough that a phone should not be doing it while somebody waits.
///
/// The run is these joined end to end. That is safe because every proof ends
/// with the runner standing on the last tile, so each stretch begins from the
/// state its own proof began from.
class Library {
  const Library._();

  static final all = [
    for (final one in kStretches) Piece(one.$1, one.$2, one.$3),
  ];

  static int get count => all.length;

  /// The hardest stretch there is, by presses.
  static int get hardest =>
      all.map((one) => one.jumps).reduce((a, b) => a > b ? a : b);

  /// A stretch of at most [jumps] presses, chosen by [random].
  ///
  /// At most, rather than exactly: an endless run that only ever handed out
  /// its current difficulty would be a metronome. Mixing an easy one in among
  /// the hard ones is what gives a player somewhere to breathe, and it is the
  /// difference between a run that gets harder and a run that gets louder.
  static Piece pick(Random random, {required int jumps}) {
    final fit = all.where((one) => one.jumps <= jumps).toList();
    return fit[random.nextInt(fit.isEmpty ? all.length : fit.length)];
  }

  /// How hard the run should be by the time [tiles] have gone by.
  ///
  /// One more press allowed every forty tiles or so, which at the runner's
  /// pace is about six seconds. Slow enough that the first minute is a
  /// welcome and fast enough that the third is not.
  static int reachFor(double tiles) {
    final want = 1 + (tiles / 40).floor();
    return want > hardest ? hardest : want;
  }
}
