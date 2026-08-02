import 'cards.dart';

/// Turns a number into a layout.
///
/// The shuffle is the one the game has been numbered by since the early
/// nineties: a linear congruential generator, and a pass that swaps each card
/// with one drawn from what is left. Written out here rather than replaced
/// with a modern shuffle for one reason — the deals it produces are the deals
/// everybody else's numbers refer to, which means there is something outside
/// this repository to check the whole thing against.
///
/// That check is worth a great deal. Of the first thirty two thousand deals
/// exactly one cannot be won, and everyone who has ever written one of these
/// knows which: deal 11982. A solver and a shuffle that agree on that agree
/// with the world, and a test says so.
class Deal {
  const Deal._();

  static const columns = 8;

  /// The eight columns of deal [number].
  ///
  /// Numbers start at one. Nothing is stored anywhere: the number *is* the
  /// deal, which is what lets a player be given a deal by name and a test ask
  /// for the same one.
  static List<List<Card>> layout(int number) {
    final deck = [for (var i = 0; i < 52; i++) i];
    var seed = number;

    int next() {
      seed = (seed * 214013 + 2531011) % 2147483648;
      return seed ~/ 65536;
    }

    for (var i = 0; i < 52; i++) {
      final pick = next() % (52 - i);
      final last = 51 - i;
      final held = deck[pick];
      deck[pick] = deck[last];
      deck[last] = held;
    }

    // Dealt from the end of the shuffled deck, because that is the end the
    // shuffle above puts the picked cards on: the first card it draws goes to
    // slot fifty one. Reading it forwards instead gives a perfectly good deal
    // that is nobody else's deal of that number, which would quietly throw
    // away the whole point of using this shuffle.
    final table = List.generate(columns, (_) => <Card>[]);
    for (var i = 0; i < 52; i++) {
      table[i % columns].add(_cardOf(deck[51 - i]));
    }
    return table;
  }

  /// The card a deck value stands for.
  ///
  /// The old numbering runs rank-major with the suits in the order clubs,
  /// diamonds, hearts, spades, which is not the order anything else here uses.
  /// Converting on the way out keeps that oddity in one place.
  static Card _cardOf(int value) {
    const order = [Suit.clubs, Suit.diamonds, Suit.hearts, Suit.spades];
    return Card.of(order[value % 4], value ~/ 4 + 1);
  }
}
