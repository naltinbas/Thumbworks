/// One coin: what it is called, what it is worth in pence, and how it is
/// spoken of on the tray.
class Coin {
  const Coin(this.name, this.pence, this.face);

  final String name;
  final int pence;

  /// What is stamped on it, the old way: 6d, 1/-, 2/6.
  final String face;
}

/// A till: the coins in it, and what they make of an amount.
class Till {
  Till({required this.name, required List<Coin> coins, this.decimal = false})
      : coins = List.unmodifiable(coins);

  final String name;

  /// Whether this is new money, spoken in plain pence.
  final bool decimal;

  /// Smallest first, and the smallest is always a penny, so every amount can
  /// be made somehow.
  final List<Coin> coins;

  int get kinds => coins.length;

  Coin get largest => coins.last;

  /// How an amount is written on this till: 3/6 the old way, 88p the new.
  String spoken(int pence) {
    if (decimal) return '${pence}p';
    if (pence < 12) return '${pence}d';
    final shillings = pence ~/ 12;
    final left = pence % 12;
    return left == 0 ? '$shillings/-' : '$shillings/$left';
  }
}

/// The tills that ship.
///
/// The old till is the English coinage as it really was, and it is the whole
/// reason this game exists: with a florin at 24 pence and a half crown at 30,
/// taking the biggest coin that fits is not always the fewest coins. The new
/// till is decimal, and on it the biggest coin that fits is always right,
/// which a test proves by trying every amount up to five pounds.
class Tills {
  const Tills._();

  static final old = Till(
    name: 'The Old Till',
    coins: const [
      Coin('penny', 1, '1d'),
      Coin('threepence', 3, '3d'),
      Coin('sixpence', 6, '6d'),
      Coin('shilling', 12, '1/-'),
      Coin('florin', 24, '2/-'),
      Coin('half crown', 30, '2/6'),
    ],
  );

  static final decimal = Till(
    name: 'The New Till',
    decimal: true,
    coins: const [
      Coin('penny', 1, '1'),
      Coin('twopence', 2, '2'),
      Coin('fivepence', 5, '5'),
      Coin('tenpence', 10, '10'),
      Coin('twenty pence', 20, '20'),
      Coin('fifty pence', 50, '50'),
    ],
  );
}
