/// The two roads from Start to End, over the top junction or the bottom
/// one, and the shortcut between them: how a crowd of drivers settles,
/// and how long each takes.
///
/// The crowd is counted in hundreds. Start to the top and bottom to End
/// take one minute per hundred drivers on them; the top to End and Start
/// to the bottom take 45 minutes whatever the crowd; the shortcut, top
/// to bottom, takes no time at all when it is open.
class Rules {
  /// The crowd runs from [least] to [most] hundreds, two at a time, so
  /// that an even split is whole.
  static const least = 2, most = 60, step = 2;

  /// The fixed roads' minutes.
  static const fixed = 45;

  /// Every setting: a crowd and the shortcut open or shut.
  static int get settings => ((most - least) ~/ step + 1) * 2;

  /// How the crowd settles: (by the top, by the bottom, across the
  /// shortcut), in hundreds, when no driver can do better by switching.
  /// The first voice, worked out by cases.
  static (int, int, int) settle(int crowd, bool open) {
    if (!open) return (crowd ~/ 2, crowd ~/ 2, 0);
    // With the shortcut open, the top-across-bottom way costs a driver
    // both variable roads and no fixed one; while the crowd is under 45
    // it beats either old way whatever the others do, so all take it;
    // past 45 the old ways come back into use until the variable roads
    // carry 45 each.
    if (crowd <= fixed) return (0, 0, crowd);
    return (crowd - fixed, crowd - fixed, 2 * fixed - crowd);
  }

  /// The minutes each way takes under a settling: top way, bottom way,
  /// across, the last null when the shortcut is shut.
  static (int, int, int?) minutes(int crowd, bool open) {
    final (top, bottom, across) = settle(crowd, open);
    final startTop = top + across, bottomEnd = bottom + across;
    return (startTop + fixed, fixed + bottomEnd, open ? startTop + bottomEnd : null);
  }

  /// The minutes every driver takes once settled: the used ways all take
  /// the same.
  static int journey(int crowd, bool open) {
    final (top, bottom, across) = settle(crowd, open);
    final (t, b, a) = minutes(crowd, open);
    if (across > 0) return a!;
    if (top > 0) return t;
    return b;
  }

  /// The potential of a split, doubled to keep it whole: for each road,
  /// its minutes summed over the crowd on it as it fills, x squared over
  /// two for a variable road and 45 x for a fixed one; the split the
  /// crowd settles into is the one that makes it least, since a driver
  /// who could gain by switching would lower it. The second voice, over
  /// every whole split.
  static int potential(int top, int bottom, int across) =>
      (top + across) * (top + across) + 2 * fixed * top + 2 * fixed * bottom + (bottom + across) * (bottom + across);

  /// The split of least potential over every whole split of the crowd,
  /// the shortcut open or shut: (top, bottom, across).
  static (int, int, int) settleByPotential(int crowd, bool open) {
    (int, int, int)? best;
    var least = 0;
    for (var across = 0; across <= (open ? crowd : 0); across++) {
      for (var top = 0; top + across <= crowd; top++) {
        final bottom = crowd - top - across;
        final p = potential(top, bottom, across);
        if (best == null || p < least) {
          best = (top, bottom, across);
          least = p;
        }
      }
    }
    return best!;
  }

  /// Whether the shortcut helps, hurts or makes no odds on this crowd.
  static String verdictOf(int crowd) {
    final open = journey(crowd, true), shut = journey(crowd, false);
    return open < shut ? 'helps' : open > shut ? 'hurts' : 'no odds';
  }

  /// A crowd told: 'forty hundred'.
  static String tell(int hundreds) => '${_words(hundreds)} hundred';

  static String _words(int n) {
    const ones = ['nought', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'];
    const tens = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty'];
    if (n < 20) return ones[n];
    return n % 10 == 0 ? tens[n ~/ 10] : '${tens[n ~/ 10]}-${ones[n % 10]}';
  }
}
