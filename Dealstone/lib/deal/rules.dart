/// The law of the deal.
///
/// Stones in piles, and one move only: take a stone from every
/// pile and stack the takings as a new pile. Brandt's 1982 law
/// says a hand whose count is triangular, one plus two plus so
/// on, always walks to the staircase and stays; and only the
/// staircases stand still, so a count between triangulars
/// never stops dealing. The sweep deals every hand there is
/// and never catches the law out.
class Rules {
  /// One deal: every pile pays a stone, the takings stack.
  static List<int> deal(List<int> hand) {
    final paid = [
      for (final pile in hand)
        if (pile > 1) pile - 1,
    ];
    paid.add(hand.length);
    paid.sort((a, b) => b - a);
    return paid;
  }

  /// Whether a hand stands still under the deal.
  static bool standsStill(List<int> hand) {
    final dealt = deal(hand);
    if (dealt.length != hand.length) return false;
    for (var at = 0; at < hand.length; at++) {
      if (dealt[at] != hand[at]) return false;
    }
    return true;
  }

  /// The road from a hand to the stair of its count, walked;
  /// the hand first. Empty past sixty deals, which never
  /// happens on a triangular count.
  static List<List<int>> road(List<int> hand) {
    final stair = stairOf(count(hand));
    final steps = [List.of(hand)];
    var at = List.of(hand);
    while (stair != null &&
        !_same(at, stair) &&
        steps.length <= 60) {
      at = deal(at);
      steps.add(at);
    }
    return steps;
  }

  static bool _same(List<int> one, List<int> two) {
    if (one.length != two.length) return false;
    for (var at = 0; at < one.length; at++) {
      if (one[at] != two[at]) return false;
    }
    return true;
  }

  static int count(List<int> hand) =>
      hand.fold(0, (sum, pile) => sum + pile);

  /// The staircase holding [stones], or null when no staircase
  /// does: k, k-1 and down to one.
  static List<int>? stairOf(int stones) {
    var step = 0;
    var held = 0;
    while (held < stones) {
      step++;
      held += step;
    }
    if (held != stones) return null;
    return [for (var pile = step; pile >= 1; pile--) pile];
  }

  /// How many deals a hand takes to the stair; -1 when its
  /// count holds no stair.
  static int dealsByWalk(List<int> hand) {
    if (stairOf(count(hand)) == null) return -1;
    return road(hand).length - 1;
  }

  /// Every hand of [stones], largest pile first; calls [visit].
  /// The sweep the checker and the suite share.
  static void hands(int stones, void Function(List<int>) visit) {
    final piles = <int>[];
    void grow(int left, int most) {
      if (left == 0) {
        visit(piles);
        return;
      }
      for (var pile = left < most ? left : most; pile >= 1; pile--) {
        piles.add(pile);
        grow(left - pile, pile);
        piles.removeLast();
      }
    }

    grow(stones, stones);
  }

  /// How many hands of [stones] stand exactly [asked] deals
  /// from the stair.
  static int waysTo(int stones, int asked) {
    var ways = 0;
    hands(stones, (hand) {
      if (dealsByWalk(hand) == asked) ways++;
    });
    return ways;
  }

  /// The laws over every hand of six, eight and ten: triangular
  /// counts always reach their stair, the stair stands still,
  /// and only staircases ever do. True when nothing breaks.
  static bool lawsHold() {
    var sound = true;
    for (final stones in [6, 8, 10]) {
      final stair = stairOf(stones);
      hands(stones, (hand) {
        if (stair != null) {
          if (dealsByWalk(hand) < 0 || dealsByWalk(hand) > 60) {
            sound = false;
          }
        }
        if (standsStill(hand) != _isStair(hand)) sound = false;
      });
    }
    return sound;
  }

  static bool _isStair(List<int> hand) {
    final stair = stairOf(count(hand));
    return stair != null && _same(hand, stair);
  }
}
