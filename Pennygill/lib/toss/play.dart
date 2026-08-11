import 'call.dart';
import 'odds.dart';
import 'wager.dart';

/// A match part played: the calls, the flips, and the rounds taken.
class Play {
  const Play._(
    this.wager,
    this.yours,
    this.theirs,
    this.flips,
    this.yourRounds,
    this.theirRounds,
    this.roundOver,
  );

  Play.of(Wager wager)
      : this._(
          wager,
          null,
          wager.theyCallFirst ? wager.theirCall : null,
          const [],
          0,
          0,
          false,
        );

  final Wager wager;

  /// Your call, once made.
  final Call? yours;

  /// The house's call, once made.
  final Call? theirs;

  /// The flips of the round in hand, true for heads.
  final List<bool> flips;

  /// Rounds taken so far.
  final int yourRounds;
  final int theirRounds;

  /// Whether the round in hand has just ended, waiting to be cleared.
  final bool roundOver;

  bool get called => yours != null && theirs != null;

  bool get isOver =>
      yourRounds >= wager.stakes || theirRounds >= wager.stakes;

  bool get won => yourRounds >= wager.stakes;

  /// Makes your call. On most tables the house replies at once with the
  /// old rule; on the turned table it has called already; on the even
  /// table it calls your opposite.
  Play call(Call call) {
    if (yours != null || isOver) return this;
    if (wager.theyCallFirst) {
      return Play._(wager, call, theirs, flips, yourRounds, theirRounds,
          false);
    }
    final reply = wager.evenTable ? Call(call.flips ^ 7) : call.beatenBy;
    return Play._(
        wager, call, reply, flips, yourRounds, theirRounds, false);
  }

  /// Whether the last three flips are somebody's call.
  Call? get shownBy {
    if (flips.length < 3) return null;
    var run = 0;
    for (var flip = flips.length - 3; flip < flips.length; flip++) {
      run = (run << 1) | (flips[flip] ? 1 : 0);
    }
    if (yours?.flips == run) return yours;
    if (theirs?.flips == run) return theirs;
    return null;
  }

  /// One flip of the coin. The coin is outside the game: the caller draws
  /// it and hands it in, so a test can hand in what it likes.
  Play flip(bool heads) {
    if (!called || isOver || roundOver) return this;
    final grown = [...flips, heads];
    final after = Play._(
        wager, yours, theirs, grown, yourRounds, theirRounds, false);
    final shown = after.shownBy;
    if (shown == null) return after;
    return Play._(
      wager,
      yours,
      theirs,
      grown,
      yourRounds + (shown == yours ? 1 : 0),
      theirRounds + (shown == theirs ? 1 : 0),
      true,
    );
  }

  /// Clears the table for the next round of the same match.
  Play get nextRound {
    if (!roundOver || isOver) return this;
    return Play._(
        wager, yours, theirs, const [], yourRounds, theirRounds, false);
  }

  /// The chance the house's call shows before yours, exact, or null
  /// before the calls are made.
  Ratio? get theirChance {
    if (!called) return null;
    return Odds.byWalk(yours!, theirs!);
  }

  /// The reply that would beat the house's call, for the turned table.
  Call? get beatingReply =>
      wager.theyCallFirst ? wager.theirCall.beatenBy : null;
}
