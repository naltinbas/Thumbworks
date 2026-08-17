/// A chest of coins and three heirs, each holding a bond the estate
/// cannot cover.
///
/// The Mishnah rules one case of a contested garment (Bava Metzia 1:1):
/// two men hold it, one claiming all of it and the other half, and it
/// goes three quarters and one quarter, because the second has conceded
/// half already and only the other half is in dispute. Aumann and
/// Maschler read that one case as a rule for any two claims and any
/// estate: each claimant concedes the amount by which the estate passes
/// his own claim, and what neither concedes is halved.
///
/// The estate table of Ketubot 93a divides among three widows with bonds
/// of 100, 200 and 300 zuz: 100 goes equally, 200 goes 50, 75 and 75,
/// and 300 goes 50, 100 and 150. Robert Aumann and Michael Maschler
/// showed in 1985 what the three rows have in common. Each is the one
/// division in which every pair of heirs splits the coins the two of
/// them hold between them by the garment rule, and each is the
/// nucleolus of the bankruptcy game, the game in which a set of heirs
/// is worth whatever the estate leaves once every heir outside it is
/// paid in full, and nothing when that leaves nothing. Their paper is
/// Game Theoretic Analysis of a Bankruptcy Problem from the Talmud,
/// Journal of Economic Theory 36 (1985), pages 195 to 213.
///
/// Here the bonds are 12, 24 and 36 coins, which is the Talmud's 100,
/// 200 and 300 zuz at twenty-five zuz to three coins, so every share in
/// the table is a whole number of coins.
class Rules {
  /// The three bonds, smallest first.
  static const bonds = [12, 24, 36];

  /// What one coin is worth in the Talmud's zuz, as a fraction: 25 over
  /// 3.
  static const zuzOver = 25, zuzUnder = 3;

  static const heirs = 3;

  static const names = ['A', 'B', 'C'];

  /// The arithmetic is kept in twelfths of a coin, which is fine enough
  /// for every share the rules can leave: the garment rule halves, and
  /// the half-claims rule can divide a remainder by two or by three.
  static const parts = 12;

  /// The garment rule, in twelfths of a coin: each claimant concedes the
  /// amount by which [estate] passes his own claim, and the rest is
  /// halved.
  static (int, int) garmentParts(int claimA, int claimB, int estate) {
    final take = estate < claimA + claimB ? estate : claimA + claimB;
    // What B concedes goes to A, and it is whatever the estate passes
    // B's own claim.
    final toA = take - claimB > 0 ? take - claimB : 0;
    final toB = take - claimA > 0 ? take - claimA : 0;
    final rest = take - toA - toB;
    return (
      parts * toA + parts ~/ 2 * rest,
      parts * toB + parts ~/ 2 * rest,
    );
  }

  /// The nucleolus found the long way, by trying every split in
  /// twelfths and keeping the one whose largest excess is least, then
  /// the second largest and so on. Slow, so the checker runs it small.
  static (int, int) nucleolusBySearch(int claimA, int claimB, int estate) {
    final take = estate < claimA + claimB ? estate : claimA + claimB;
    final whole = parts * take;
    final worthA = parts * (take - claimB > 0 ? take - claimB : 0);
    final worthB = parts * (take - claimA > 0 ? take - claimA : 0);
    List<int>? best;
    (int, int)? bestSplit;
    for (var toA = 0; toA <= whole; toA++) {
      final toB = whole - toA;
      // What each coalition is owed less what it is given.
      final excesses = [0 - 0, worthA - toA, worthB - toB, whole - whole]
        ..sort((a, b) => b.compareTo(a));
      if (best == null || _under(excesses, best)) {
        best = excesses;
        bestSplit = (toA, toB);
      }
    }
    return bestSplit!;
  }

  /// Whether [a] comes before [b] read as a sorted list of excesses.
  static bool _under(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return a[i] < b[i];
    }
    return false;
  }

  /// Whether the pair [i] and [j] of [purses] hold their coins split the
  /// way the garment rule wants.
  static bool levelPair(List<int> purses, int i, int j) {
    final (wantI, wantJ) =
        garmentParts(bonds[i], bonds[j], purses[i] + purses[j]);
    return parts * purses[i] == wantI && parts * purses[j] == wantJ;
  }

  /// How far out of true the scale between [i] and [j] hangs, in
  /// twelfths of a coin: nought when it is level.
  static int tilt(List<int> purses, int i, int j) {
    final (wantI, _) = garmentParts(bonds[i], bonds[j], purses[i] + purses[j]);
    return parts * purses[i] - wantI;
  }

  /// Every scale level at once.
  static bool allLevel(List<int> purses) {
    for (var i = 0; i < heirs; i++) {
      for (var j = i + 1; j < heirs; j++) {
        if (!levelPair(purses, i, j)) return false;
      }
    }
    return true;
  }

  /// The estate as Aumann and Maschler divide it, without looking at
  /// any pair: equal awards on half claims while the estate is under
  /// half the claims, and claims less the same rule above it. Claims
  /// and estate in coins, the answer in twelfths.
  static List<int> halfClaimsParts(List<int> claims, int estate) {
    final total = claims.reduce((a, b) => a + b);
    // Nothing above the claims is anybody's to divide.
    final take = estate < total ? estate : total;
    final halves = [for (final claim in claims) parts ~/ 2 * claim];
    if (2 * take <= total) {
      return _equalAwards(halves, parts * take);
    }
    final above = _equalAwards(halves, parts * (total - take));
    return [
      for (var i = 0; i < claims.length; i++) parts * claims[i] - above[i],
    ];
  }

  /// The garment rule read off the same half-claims rule, for two
  /// claimants: the second voice on a pair.
  static (int, int) halfClaimsPairParts(int claimA, int claimB, int estate) {
    final take = estate < claimA + claimB ? estate : claimA + claimB;
    final got = halfClaimsParts([claimA, claimB], take);
    return (got[0], got[1]);
  }

  /// Constrained equal awards in twelfths: everyone gets the same until
  /// their cap stops them. Every amount it is given here divides evenly,
  /// two ways or three, so nothing is lost to the truncating divide, and
  /// the checker holds the shares to the estate they came from.
  static List<int> _equalAwards(List<int> caps, int amount) {
    final got = List.filled(caps.length, 0);
    var left = amount;
    final order = [for (var i = 0; i < caps.length; i++) i]
      ..sort((a, b) => caps[a].compareTo(caps[b]));
    var sharing = caps.length;
    for (final i in order) {
      final share = left ~/ sharing;
      if (caps[i] <= share) {
        got[i] = caps[i];
        left -= caps[i];
        sharing--;
      } else {
        for (final k in order.sublist(order.indexOf(i))) {
          got[k] = share;
        }
        break;
      }
    }
    return got;
  }

  /// The division that levels every scale, from the half-claims rule,
  /// or null when it does not land on whole coins.
  static List<int>? division(int estate) {
    final shares = halfClaimsParts(bonds, estate);
    if (shares.any((share) => share % parts != 0)) return null;
    return [for (final share in shares) share ~/ parts];
  }

  /// The shares the half-claims rule leaves, in twelfths.
  static List<int> shares(int estate) => halfClaimsParts(bonds, estate);

  /// Every way [estate] coins can go into the three purses.
  static Iterable<List<int>> divisions(int estate) sync* {
    for (var a = 0; a <= estate; a++) {
      for (var b = 0; b <= estate - a; b++) {
        yield [a, b, estate - a - b];
      }
    }
  }

  static int howManyDivisions(int estate) => (estate + 1) * (estate + 2) ~/ 2;

  static bool valid(List<int> purses, int estate) =>
      purses.length == heirs &&
      purses.every((coins) => coins >= 0) &&
      purses.reduce((a, b) => a + b) <= estate;

  /// How many taps the dials take to put [coins] in a purse.
  static int taps(int coins) => coins ~/ 3 + coins % 3;

  /// A count of twelfths told in words: '7 1/2', '4 1/3'.
  static String tellParts(int amount) {
    final whole = amount ~/ parts;
    final left = amount % parts;
    if (left == 0) return '$whole';
    var top = left, bottom = parts;
    for (var d = 2; d <= top; d++) {
      while (top % d == 0 && bottom % d == 0) {
        top ~/= d;
        bottom ~/= d;
      }
    }
    return whole == 0 ? '$top/$bottom' : '$whole $top/$bottom';
  }

  /// What a purse of [coins] comes to in the Talmud's zuz, told exactly.
  static String tellZuz(int coins) {
    final over = coins * zuzOver;
    if (over % zuzUnder == 0) return '${over ~/ zuzUnder}';
    return '${over ~/ zuzUnder} ${over % zuzUnder}/$zuzUnder';
  }
}
