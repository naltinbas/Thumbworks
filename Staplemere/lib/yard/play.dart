import 'deal.dart';
import 'fewest.dart';

/// A morning part played: the piles standing, and the bales still to come.
class Play {
  const Play._(this.deal, this.piles, this.placed, this.before);

  Play.of(Deal deal) : this._(deal, const [], 0, null);

  final Deal deal;

  /// Each pile from the ground up, as places in the arrival order. The
  /// weights fall as a pile rises, which is the whole rule of the yard.
  final List<List<int>> piles;

  /// How many bales are down.
  final int placed;

  /// The morning as it stood before the last bale, for taking one back, or
  /// null at the start. The bale goes back on the cart; nothing else moves.
  final Play? before;

  bool get isDone => placed == deal.many;

  /// The weight coming up the lane, or null when the cart is empty.
  int? get arriving => isDone ? null : deal.tods[placed];

  int get standing => piles.length;

  bool get isFewest => standing == deal.fewest;

  /// The weight on top of a pile.
  int topOf(int pile) => deal.tods[piles[pile].last];

  /// Whether the arriving bale may rest there. Asking about the place one
  /// past the last pile asks about the ground, which can always take it.
  bool mayRest(int pile) {
    if (isDone || pile < 0 || pile > piles.length) return false;
    return pile == piles.length || topOf(pile) > arriving!;
  }

  /// Sets the arriving bale down. Returns this unchanged when it may not
  /// rest there.
  Play put(int pile) {
    if (!mayRest(pile)) return this;
    final grown = [
      for (var at = 0; at < piles.length; at++)
        at == pile ? [...piles[at], placed] : piles[at],
      if (pile == piles.length) [placed],
    ];
    return Play._(deal, grown, placed + 1, this);
  }

  /// The last bale back on the cart, or this at the start of the morning.
  Play get back => before ?? this;

  /// The fewest piles the morning can still end in from here, best fit over
  /// what is coming. A test holds this against brute force from part-played
  /// mornings, so the number is exact, not hopeful.
  int get couldStillBe => Runs.byBestFit(
        [for (var pile = 0; pile < piles.length; pile++) topOf(pile)],
        deal.tods.sublist(placed),
      );

  /// The pile the arriving bale should rest on: the lightest top that can
  /// take it, or the ground when nothing can. Null when the cart is empty.
  int? get next {
    if (isDone) return null;
    var snuggest = piles.length;
    for (var pile = 0; pile < piles.length; pile++) {
      if (!mayRest(pile)) continue;
      if (snuggest == piles.length || topOf(pile) < topOf(snuggest)) {
        snuggest = pile;
      }
    }
    return snuggest;
  }

  /// Where each bale of [Runs.thread] sits right now: pile and height, or
  /// still on the cart. For drawing the floor on the yard itself.
  ({int pile, int height})? whereIs(int bale) {
    for (var pile = 0; pile < piles.length; pile++) {
      final height = piles[pile].indexOf(bale);
      if (height != -1) return (pile: pile, height: height);
    }
    return null;
  }
}
