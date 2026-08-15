/// The law of the line: prisoners in a row, the man at the back
/// seeing every cap ahead of him and none behind, each in turn calling
/// black or white for his own cap.
class Rules {
  /// Caps as bits: bit i is prisoner i's cap, true for black; prisoner
  /// nought stands at the back and sees prisoners 1 to n - 1.
  static List<bool> deal(int n, int bits) => [for (var i = 0; i < n; i++) (bits >> i) & 1 == 1];

  /// The black caps prisoner [i] can see: those ahead of him.
  static int blackAhead(List<bool> caps, int i) => [for (var j = i + 1; j < caps.length; j++) if (caps[j]) j].length;

  /// The plan's call for prisoner [i], given what he sees ahead and
  /// what he has heard called behind him: the man at the back calls
  /// black when he sees an odd count of black caps ahead; every man
  /// after him calls the colour that keeps the count of black caps,
  /// heard behind and seen ahead and his own, at the parity the first
  /// man told.
  static bool planCall(List<bool> caps, int i, List<bool> heard) {
    final ahead = blackAhead(caps, i);
    if (i == 0) return ahead.isOdd;
    final told = heard[0];
    var behind = 0;
    for (var j = 1; j < i; j++) {
      if (heard[j]) behind++;
    }
    // told == parity of black among 1..n-1 == (behind + own + ahead) odd
    return (behind + ahead).isOdd != told;
  }

  /// The plan run down the whole line: the calls, and which are right.
  static (List<bool> calls, List<bool> right) plan(List<bool> caps) {
    final calls = <bool>[];
    for (var i = 0; i < caps.length; i++) {
      calls.add(planCall(caps, i, calls));
    }
    return (calls, [for (var i = 0; i < caps.length; i++) calls[i] == caps[i]]);
  }

  /// Every deal of [n] caps run through the plan: how many deals save
  /// all but the first, how many save the first too, and how many
  /// right calls in all.
  static (int allButFirst, int allSaved, int rightCalls) sweep(int n) {
    var allBut = 0, all = 0, right = 0;
    for (var bits = 0; bits < (1 << n); bits++) {
      final caps = deal(n, bits);
      final (_, ok) = plan(caps);
      final rest = ok.skip(1).every((r) => r);
      if (rest) allBut++;
      if (rest && ok[0]) all++;
      right += ok.where((r) => r).length;
    }
    return (allBut, all, right);
  }

  /// Every plan the first man could have, for a line of [n]: a call for
  /// each of the 2^(n-1) views ahead of him. Each plan is right on how
  /// many of the 2^n deals? This walks every plan and returns the
  /// least and the most.
  static (int fewest, int most, int plans) firstManEveryPlan(int n) {
    final views = 1 << (n - 1);
    final plans = 1 << views;
    var fewest = 1 << n, most = -1;
    for (var plan = 0; plan < plans; plan++) {
      var right = 0;
      for (var bits = 0; bits < (1 << n); bits++) {
        final view = bits >> 1;
        final call = (plan >> view) & 1 == 1;
        if (call == ((bits & 1) == 1)) right++;
      }
      if (right < fewest) fewest = right;
      if (right > most) most = right;
    }
    return (fewest, most, plans);
  }
}
