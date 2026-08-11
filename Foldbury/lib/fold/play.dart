import 'fewest.dart';
import 'fold.dart';

/// A fold part posted.
class Play {
  Play._(this.fold, this.watch, this.posted);

  factory Play.of(Fold fold, Watch watch) => Play._(fold, watch, 0);

  final Fold fold;

  /// The answer and its floors, worked out when the fold opens.
  final Watch watch;

  /// The gates with a shepherd, as bits.
  final int posted;

  bool isPosted(int gate) => (posted & (1 << gate)) != 0;

  int get standing {
    var count = 0;
    var left = posted;
    while (left != 0) {
      left &= left - 1;
      count++;
    }
    return count;
  }

  /// Whether a lane has a shepherd at either end.
  bool laneWatched(int lane) =>
      isPosted(fold[lane].from) || isPosted(fold[lane].to);

  int get unwatched {
    var count = 0;
    for (var lane = 0; lane < fold.many; lane++) {
      if (!laneWatched(lane)) count++;
    }
    return count;
  }

  bool get isDone => fold.watches(posted);

  bool get isFewest => isDone && standing <= fold.fewest;

  Play touch(int gate) {
    if (gate < 0 || gate >= fold.count) return this;
    return Play._(fold, watch, posted ^ (1 << gate));
  }

  Play get again => Play.of(fold, watch);

  /// The fewest shepherds a night can still be watched with from here,
  /// counting the ones already posted: the same search, over the lanes still
  /// dark, with the posted gates given.
  int get couldStillBe {
    for (var extra = 0; extra <= fold.count; extra++) {
      if (_extendable(0, posted, extra)) return standing + extra;
    }
    return fold.count;
  }

  bool _extendable(int from, int with_, int extra) {
    if (extra == 0) return fold.watches(with_);
    for (var gate = from; gate < fold.count; gate++) {
      if ((with_ & (1 << gate)) != 0) continue;
      if (_extendable(gate + 1, with_ | (1 << gate), extra - 1)) return true;
    }
    return false;
  }

  /// Asked. A gate to post next that keeps the night at what it can still
  /// be.
  int? get next {
    if (isDone) return null;
    final could = couldStillBe;
    for (var gate = 0; gate < fold.count; gate++) {
      if (isPosted(gate)) continue;
      if (touch(gate).couldStillBe == could) return gate;
    }
    return null;
  }
}
