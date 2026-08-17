/// A cattle ring with a sealed tender box. You know what the beast is
/// worth to you, and you write a bid. The rivals write theirs. The
/// highest bid takes the beast, and a tie goes to the rivals, so you
/// win only when your bid is strictly the highest.
///
/// Only the best of the rival bids can ever matter, so the whole story
/// is three numbers: what the beast is worth to you, what you bid, and
/// the best bid against you.
///
/// Under the sealed ring the winner pays the second bid, which is the
/// best rival bid when you win. William Vickrey wrote in 1961 that
/// under that rule bidding what the beast is worth to you is never
/// beaten by any other bid. Under the open ring the winner pays what he
/// bid, and then bidding your worth earns nothing at all while shading
/// under it pays.
class Rules {
  /// The dials run from nothing up to this.
  static const most = 12;

  /// The two rings.
  static const sealed = 'sealed', open = 'open';

  /// Where a go opens: the beast worth 10, a bid of 12 against a rival
  /// bid of 12, which loses the lot and earns nothing either way.
  static const openWorth = 10, openBid = 12, openRival = 12;

  static bool wins(int bid, int rival) => bid > rival;

  /// What the bid earns, run literally: the first voice.
  static int paidBy(String ring, int worth, int bid, int rival) {
    if (!wins(bid, rival)) return 0;
    return ring == sealed ? worth - rival : worth - bid;
  }

  /// What the truthful bid earns.
  static int truthPays(String ring, int worth, int rival) =>
      paidBy(ring, worth, worth, rival);

  /// The second voice for the sealed ring, which runs no auction: the
  /// bid and the worth differ only when the best rival bid falls in the
  /// window between them, and the window is closed at the lower end
  /// because a bid level with a rival loses.
  static int windowGap(int worth, int bid, int rival) {
    if (bid > worth) {
      return (rival >= worth && rival < bid) ? worth - rival : 0;
    }
    if (bid < worth) {
      return (rival >= bid && rival < worth) ? rival - worth : 0;
    }
    return 0;
  }

  /// The second voice for the open ring: shading pays exactly when the
  /// bid wins and sits under the worth, since the truthful bid pays
  /// its whole worth away and earns nothing.
  static bool shadingPays(int worth, int bid, int rival) =>
      bid > rival && bid < worth;

  /// Every setting of the three dials.
  static Iterable<(int, int, int)> settings() sync* {
    for (var worth = 0; worth <= most; worth++) {
      for (var bid = 0; bid <= most; bid++) {
        for (var rival = 0; rival <= most; rival++) {
          yield (worth, bid, rival);
        }
      }
    }
  }

  static int get howManySettings => (most + 1) * (most + 1) * (most + 1);

  static int taps((int, int, int) from, (int, int, int) to) =>
      (from.$1 - to.$1).abs() +
      (from.$2 - to.$2).abs() +
      (from.$3 - to.$3).abs();

  static String tellRing(String ring) => ring == sealed
      ? 'the sealed ring, where the winner pays the second bid'
      : 'the open ring, where the winner pays what he bid';

  static String tellCrowns(int coins) =>
      '$coins ${coins.abs() == 1 ? 'crown' : 'crowns'}';
}
