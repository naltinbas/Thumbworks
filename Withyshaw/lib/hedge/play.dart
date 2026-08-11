import 'hedge.dart';
import 'rules.dart';
import 'worth.dart';

/// A hedge part cut: the stalks as they stand, and whose bill it is.
class Play {
  const Play._(
    this.hedge,
    this.stalks,
    this.made,
    this.theirLast,
    this.overBy,
    this.before,
  );

  Play.of(Hedge hedge)
      : this._(hedge, hedge.stalks, 0, null, Bill.none, null);

  final Hedge hedge;

  /// The stalks as they stand.
  final List<(int, int)> stalks;

  /// Cuts of your own.
  final int made;

  /// The hedger's last cut, as (stalk, withy), for the drawing, or null.
  final (int, int)? theirLast;

  /// Who ran out of cuts, if anyone yet.
  final Bill overBy;

  /// The play before your last cut, or null at the start.
  final Play? before;

  bool get isOver => overBy != Bill.none;

  bool get won => overBy == Bill.them;

  /// The worth of what stands.
  Worth get worth => Rules.worthOfHedge(stalks);

  /// Whether you, cutting next, still hold the hedge.
  bool get winnable => !isOver && worth.isPositive;

  /// Whether a withy stands and is yours to cut.
  bool mayCut(int stalk, int at) {
    if (isOver || stalk < 0 || stalk >= stalks.length) return false;
    final (bits, length) = stalks[stalk];
    if (at < 0 || at >= length) return false;
    return (bits >> at) & 1 == 1;
  }

  bool _anyOf(List<(int, int)> standing, bool yours) {
    for (final (bits, length) in standing) {
      for (var at = 0; at < length; at++) {
        if (((bits >> at) & 1 == 1) == yours) return true;
      }
    }
    return false;
  }

  /// Your cut, and the hedger's on its heels.
  Play cut(int stalk, int at) {
    if (!mayCut(stalk, at)) return this;
    final cutOnce = [
      for (var other = 0; other < stalks.length; other++)
        if (other == stalk)
          (stalks[other].$1 & ((1 << at) - 1), at)
        else
          stalks[other],
    ];
    if (!_anyOf(cutOnce, false)) {
      return Play._(hedge, cutOnce, made + 1, null, Bill.them, this);
    }
    // The hedger's cut: the winning one, else the highest red standing,
    // which drops the least of its own.
    var theirs = Rules.winningCut(cutOnce, false);
    if (theirs == null) {
      var bestStalk = -1, bestAt = -1;
      for (var which = 0; which < cutOnce.length; which++) {
        final (bits, length) = cutOnce[which];
        for (var at2 = length - 1; at2 >= 0; at2--) {
          if ((bits >> at2) & 1 == 0 && at2 > bestAt) {
            bestStalk = which;
            bestAt = at2;
            break;
          }
        }
      }
      theirs = (bestStalk, bestAt);
    }
    final cutTwice = [
      for (var other = 0; other < cutOnce.length; other++)
        if (other == theirs.$1)
          (cutOnce[other].$1 & ((1 << theirs.$2) - 1), theirs.$2)
        else
          cutOnce[other],
    ];
    if (!_anyOf(cutTwice, true)) {
      return Play._(hedge, cutTwice, made + 1, theirs, Bill.you, this);
    }
    return Play._(hedge, cutTwice, made + 1, theirs, Bill.none, this);
  }

  /// The whole last exchange back, or this at the start.
  Play get back => before ?? this;

  /// A winning cut for you, or null when there is none.
  (int, int)? get next {
    if (isOver) return null;
    return Rules.winningCut(stalks, true);
  }
}

enum Bill { none, you, them }
