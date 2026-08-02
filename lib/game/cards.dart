/// The four suits.
enum Suit {
  clubs('C', '♣', black: true),
  diamonds('D', '♦', black: false),
  hearts('H', '♥', black: false),
  spades('S', '♠', black: true);

  const Suit(this.letter, this.pip, {required this.black});

  /// The letter used when a card is written down, which is how deals and
  /// tests talk about them.
  final String letter;

  /// What it looks like.
  final String pip;

  final bool black;

  bool get red => !black;
}

/// A card, as a number from 0 to 51.
///
/// One integer rather than a pair of fields, because a solver looks at
/// hundreds of thousands of positions and the difference between a small
/// object and an integer is the difference between a hint that arrives and a
/// hint that does not.
extension type const Card(int index) {
  factory Card.of(Suit suit, int rank) {
    assert(rank >= 1 && rank <= 13, 'ace is 1 and king is 13');
    return Card(suit.index * 13 + rank - 1);
  }

  /// Ace is 1, king is 13.
  int get rank => index % 13 + 1;

  Suit get suit => Suit.values[index ~/ 13];

  bool get black => suit.black;
  bool get red => suit.red;

  bool get isAce => rank == 1;
  bool get isKing => rank == 13;

  /// Whether this may sit on [other] in a column: down one, and the other
  /// colour.
  bool sitsOn(Card other) => rank == other.rank - 1 && black != other.black;

  /// Whether this may go on [other] on a foundation: up one, same suit.
  bool followsOn(Card other) =>
      suit == other.suit && rank == other.rank + 1;

  static const ranks = 'A23456789TJQK';

  String get face => '${ranks[rank - 1]}${suit.letter}';

  /// The whole pack, in the order a new one comes in.
  static List<Card> get pack => [for (var i = 0; i < 52; i++) Card(i)];

  /// Reads a card back from what [face] wrote.
  static Card from(String face) {
    assert(face.length == 2, 'a card is written as rank then suit: $face');
    final rank = ranks.indexOf(face[0].toUpperCase()) + 1;
    final suit = Suit.values.firstWhere(
      (one) => one.letter == face[1].toUpperCase(),
      orElse: () => throw ArgumentError('no suit in $face'),
    );
    assert(rank > 0, 'no rank in $face');
    return Card.of(suit, rank);
  }
}
