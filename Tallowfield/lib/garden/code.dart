/// The gardener's rule, and what the hedges can and cannot tell.
///
/// Seven lanterns stand among three round hedges, one lantern in each of
/// the seven beds the hedges cut the garden into: three beds inside one
/// hedge alone, three inside a pair, one inside all three. The gardener
/// lights them so every hedge holds an even number of lit lanterns.
///
/// When a draught snuffs or relights one lantern, every hedge around it
/// goes odd. The odd hedges name a bed among themselves, the bed inside
/// exactly the complaining hedges and no other, and that bed holds the
/// changed lantern. Which is to say: three parities find one fault among
/// seven lanterns, and the finding is a picture.
class Code {
  const Code._();

  /// Which lamps stand in each hedge, as bits, lamp n being bit n - 1.
  /// A lamp's number, one to seven, IS which hedges it stands in.
  static const hedgeA = 0x55; // lamps 1, 3, 5, 7
  static const hedgeB = 0x66; // lamps 2, 3, 6, 7
  static const hedgeC = 0x78; // lamps 4, 5, 6, 7

  static const hedges = [hedgeA, hedgeB, hedgeC];

  static bool inHedge(int lamp, int hedge) =>
      hedges[hedge] & (1 << (lamp - 1)) != 0;

  static bool _odd(int pattern, int hedge) {
    var lit = pattern & hedges[hedge];
    var parity = 0;
    while (lit != 0) {
      parity ^= 1;
      lit &= lit - 1;
    }
    return parity == 1;
  }

  /// Which hedges complain of [pattern]: true where the count is odd.
  static List<bool> complaints(int pattern) =>
      [for (var hedge = 0; hedge < 3; hedge++) _odd(pattern, hedge)];

  /// Whether every hedge is even: a planting the gardener would own.
  static bool isSound(int pattern) =>
      !complaints(pattern).contains(true);

  /// The lamp the complaints name, one to seven, or nought when no hedge
  /// complains. The odd hedges read as a number: A is one, B two, C four.
  static int named(int pattern) {
    final odd = complaints(pattern);
    return (odd[0] ? 1 : 0) + (odd[1] ? 2 : 0) + (odd[2] ? 4 : 0);
  }

  /// The lamp whose flip alone would settle every hedge, found the long
  /// way: try each. Nought when the pattern is sound; the anchor test
  /// holds this against [named] everywhere.
  static int namedByTrying(int pattern) {
    if (isSound(pattern)) return 0;
    for (var lamp = 1; lamp <= 7; lamp++) {
      if (isSound(pattern ^ (1 << (lamp - 1)))) return lamp;
    }
    return -1;
  }

  /// Every planting the gardener could own: all sixteen sound patterns.
  static List<int> soundPlantings() => [
        for (var pattern = 0; pattern < 128; pattern++)
          if (isSound(pattern)) pattern,
      ];
}
