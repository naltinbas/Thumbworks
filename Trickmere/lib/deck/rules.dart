/// A card as one number: suit times thirteen plus rank less one, suits
/// clubs, diamonds, hearts, spades and ranks ace to king.
typedef Playcard = int;

/// The law of the trick: five cards dealt, one hidden by the assistant
/// and the other four laid in a row for the partner, who names the
/// hidden card from the row alone.
class Rules {
  static const suits = ['clubs', 'diamonds', 'hearts', 'spades'];
  static const suitMarks = ['C', 'D', 'H', 'S'];
  static const rankNames = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];

  static int suitOf(Playcard c) => c ~/ 13;
  static int rankOf(Playcard c) => c % 13 + 1;
  static Playcard card(int suit, int rank) => suit * 13 + rank - 1;

  static String name(Playcard c) => '${rankNames[rankOf(c) - 1]}${suitMarks[suitOf(c)]}';

  /// Steps clockwise round the ranks from [from] to [to], ace after king:
  /// 1 to 12, never nought for different ranks.
  static int stepsRound(int from, int to) => (to - from + 13) % 13;

  /// The order of a card among others: by rank, ties by suit.
  static int compare(Playcard a, Playcard b) => rankOf(a) != rankOf(b) ? rankOf(a) - rankOf(b) : suitOf(a) - suitOf(b);

  /// The six orders of three cards low, middle and high, and the number
  /// each tells: LMH 1, LHM 2, MLH 3, MHL 4, HLM 5, HML 6.
  static const orders = [
    [0, 1, 2],
    [0, 2, 1],
    [1, 0, 2],
    [1, 2, 0],
    [2, 0, 1],
    [2, 1, 0],
  ];

  /// The number three cards laid in an order tell.
  static int told(List<Playcard> three) {
    final sorted = List.of(three)..sort(compare);
    final pattern = [for (final c in three) sorted.indexOf(c)];
    for (var i = 0; i < orders.length; i++) {
      if ('${orders[i]}' == '$pattern') return i + 1;
    }
    throw StateError('three cards should have an order');
  }

  /// The three cards laid to tell [number], 1 to 6.
  static List<Playcard> lay(List<Playcard> three, int number) {
    final sorted = List.of(three)..sort(compare);
    return [for (final i in orders[number - 1]) sorted[i]];
  }

  /// What the partner names from a row of four: the first card's suit,
  /// and its rank plus what the other three tell, round the ranks.
  static Playcard named(List<Playcard> row) {
    final mate = row[0];
    final steps = told(row.sublist(1));
    final rank = (rankOf(mate) - 1 + steps) % 13 + 1;
    return card(suitOf(mate), rank);
  }

  /// Every layout of a hand: a card hidden and the other four in some
  /// order; 5 times 24 of them.
  static void layouts(List<Playcard> hand, void Function(Playcard hidden, List<Playcard> row) visit) {
    for (final h in hand) {
      final rest = [for (final c in hand) if (c != h) c];
      _perms(rest, (row) => visit(h, row));
    }
  }

  static void _perms(List<Playcard> cards, void Function(List<Playcard>) visit) {
    final row = <Playcard>[];
    final used = List.filled(cards.length, false);
    void grow() {
      if (row.length == cards.length) {
        visit(row);
        return;
      }
      for (var i = 0; i < cards.length; i++) {
        if (used[i]) continue;
        used[i] = true;
        row.add(cards[i]);
        grow();
        row.removeLast();
        used[i] = false;
      }
    }

    grow();
  }

  /// The layouts of a hand the partner reads right, as (hidden, row).
  static List<(Playcard, List<Playcard>)> working(List<Playcard> hand, {Playcard? hiddenFixed}) {
    final out = <(Playcard, List<Playcard>)>[];
    layouts(hand, (h, row) {
      if (hiddenFixed != null && h != hiddenFixed) return;
      if (named(row) == h) out.add((h, List.of(row)));
    });
    return out;
  }

  /// The assistant's rule for a hand, with no sweep: two cards share a
  /// suit; take a pair with the hidden one within six steps clockwise
  /// of the shown one, show the mate first and lay the other three to
  /// tell the steps. Null when no card can be hidden that way, which
  /// never happens to a hand of five from a full deck.
  static (Playcard, List<Playcard>)? rule(List<Playcard> hand, {Playcard? hiddenFixed}) {
    for (final h in hand) {
      if (hiddenFixed != null && h != hiddenFixed) continue;
      for (final m in hand) {
        if (m == h || suitOf(m) != suitOf(h)) continue;
        final steps = stepsRound(rankOf(m), rankOf(h));
        if (steps < 1 || steps > 6) continue;
        final others = [for (final c in hand) if (c != h && c != m) c];
        return (h, [m, ...lay(others, steps)]);
      }
    }
    return null;
  }
}
