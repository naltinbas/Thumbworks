import 'worth.dart';

/// The two answers: the worth arithmetic, and the game search.
///
/// A stalk is a run of withies from the ground up, each yours (blue) or
/// the hedger's (red). You may cut only your own, the hedger only its
/// own; a cut drops everything above it; whoever cannot cut has lost.
///
/// The worth of a stalk is counted from the ground: whole ones for each
/// withy while the colour holds, and from the first change of colour
/// each withy is worth half the one before, signed its own way. The
/// worth of a hedge is the sum of its stalks, and the theorem is the
/// game: you hold the hedge exactly when the worth is positive, whoever
/// moves; at exactly nought, whoever must cut first loses.
///
/// The search knows none of that. It tries every cut of every stalk,
/// memoised, and the anchor lays the two over each other on every hedge
/// of up to three stalks of up to four withies.
class Rules {
  const Rules._();

  /// A stalk as bits from the ground: set is yours, clear the hedger's,
  /// paired with its length. Kept as a small record everywhere.
  static Worth worthOf(int stalk, int length) {
    var worth = Worth.nought;
    if (length == 0) return worth;
    final first = stalk & 1;
    var at = 0;
    // Whole ones while the colour holds.
    while (at < length && (stalk >> at) & 1 == first) {
      worth += Worth(first == 1 ? 1 : -1, 1);
      at++;
    }
    // Halving from the change on.
    var piece = 2;
    while (at < length) {
      worth += Worth((stalk >> at) & 1 == 1 ? 1 : -1, piece);
      piece *= 2;
      at++;
    }
    return worth;
  }

  /// The worth of a whole hedge.
  static Worth worthOfHedge(List<(int, int)> stalks) {
    var worth = Worth.nought;
    for (final (stalk, length) in stalks) {
      worth += worthOf(stalk, length);
    }
    return worth;
  }

  static final _memo = <String, bool>{};

  /// Whether the side to cut loses [stalks] against perfect play, by the
  /// search. [yourCut] is whether it is your cut.
  static bool isLoss(List<(int, int)> stalks, bool yourCut) {
    final key =
        '${stalks.map((s) => '${s.$1}:${s.$2}').join(',')}|$yourCut';
    final kept = _memo[key];
    if (kept != null) return kept;

    var loss = true;
    for (var which = 0; which < stalks.length && loss; which++) {
      final (stalk, length) = stalks[which];
      for (var at = 0; at < length && loss; at++) {
        final colour = (stalk >> at) & 1;
        if ((colour == 1) != yourCut) continue;
        // Cut at [at]: the stalk becomes its lowest [at] withies.
        final after = [
          for (var other = 0; other < stalks.length; other++)
            if (other == which)
              (stalk & ((1 << at) - 1), at)
            else
              stalks[other],
        ];
        if (isLoss(after, !yourCut)) loss = false;
      }
    }
    return _memo[key] = loss;
  }

  /// A winning cut for the side to move, as (stalk index, withy index),
  /// or null from a lost hedge.
  static (int, int)? winningCut(List<(int, int)> stalks, bool yourCut) {
    for (var which = 0; which < stalks.length; which++) {
      final (stalk, length) = stalks[which];
      for (var at = 0; at < length; at++) {
        final colour = (stalk >> at) & 1;
        if ((colour == 1) != yourCut) continue;
        final after = [
          for (var other = 0; other < stalks.length; other++)
            if (other == which)
              (stalk & ((1 << at) - 1), at)
            else
              stalks[other],
        ];
        if (isLoss(after, !yourCut)) return (which, at);
      }
    }
    return null;
  }
}
