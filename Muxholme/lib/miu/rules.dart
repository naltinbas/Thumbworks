/// The law of the letters: strings of M, I and U, starting from MI, and
/// four rules. Rule one: a string ending in I may take a U on the end.
/// Rule two: whatever follows the M may be doubled. Rule three: III
/// anywhere may become U. Rule four: UU anywhere may be dropped.
class Rules {
  const Rules();

  static const start = 'MI';

  /// The most letters a string may run to on the sheet.
  static const longest = 24;

  /// A move: the rule, and where it acts for rules three and four.
  static String describe((int, int) move) => switch (move.$1) {
        1 => 'rule one, a U on the end',
        2 => 'rule two, the rest doubled',
        3 => 'rule three, III to U at letter ${move.$2 + 1}',
        _ => 'rule four, UU dropped at letter ${move.$2 + 1}',
      };

  /// Every move that applies to [s], keeping it on the sheet.
  static List<(int, int)> moves(String s) => [
        if (s.endsWith('I') && s.length + 1 <= longest) (1, 0),
        if (s.length > 1 && 2 * s.length - 1 <= longest) (2, 0),
        for (var p = 1; p + 3 <= s.length; p++)
          if (s.substring(p, p + 3) == 'III') (3, p),
        for (var p = 1; p + 2 <= s.length; p++)
          if (s.substring(p, p + 2) == 'UU') (4, p),
      ];

  /// [s] with [move] made, or null when it does not apply.
  static String? apply(String s, (int, int) move) {
    if (!moves(s).contains(move)) return null;
    final (rule, p) = move;
    return switch (rule) {
      1 => '${s}U',
      2 => s + s.substring(1),
      3 => '${s.substring(0, p)}U${s.substring(p + 3)}',
      _ => s.substring(0, p) + s.substring(p + 2),
    };
  }

  /// How many I in [s].
  static int iCount(String s) => s.split('').where((c) => c == 'I').length;

  /// The invariant: the count of I is never a multiple of three, since it
  /// starts at one and the rules double it or cut it by three.
  static bool keepsFaith(String s) => iCount(s) % 3 != 0;

  /// The walk: every string reachable from MI by derivations that keep
  /// to the sheet, with the fewest steps to each and the move that got
  /// there first.
  static Map<String, (int, String?, (int, int)?)> walk() {
    if (_walk != null) return _walk!;
    final seen = <String, (int, String?, (int, int)?)>{start: (0, null, null)};
    final queue = [start];
    var head = 0;
    while (head < queue.length) {
      final s = queue[head++];
      final d = seen[s]!.$1;
      for (final m in moves(s)) {
        final t = apply(s, m)!;
        if (!seen.containsKey(t)) {
          seen[t] = (d + 1, s, m);
          queue.add(t);
        }
      }
    }
    return _walk = seen;
  }

  static Map<String, (int, String?, (int, int)?)>? _walk;

  /// The fewest steps to [target], or null when it is not reached.
  static int? fewest(String target) => walk()[target]?.$1;

  /// The first shortest derivation to [target], as moves from MI.
  static List<(int, int)>? derivation(String target) {
    final w = walk();
    if (!w.containsKey(target)) return null;
    final out = <(int, int)>[];
    var s = target;
    while (s != start) {
      final (_, from, move) = w[s]!;
      out.add(move!);
      s = from!;
    }
    return out.reversed.toList();
  }

  /// Every derivation of exactly [steps] moves from MI, counted, with
  /// those ending at [target]: (landing, all).
  static (int, int) sweep(String target, int steps) {
    var landing = 0, all = 0;
    void go(String s, int left) {
      if (left == 0) {
        all++;
        if (s == target) landing++;
        return;
      }
      for (final m in moves(s)) {
        go(apply(s, m)!, left - 1);
      }
    }

    go(start, steps);
    return (landing, all);
  }

  /// Whether [s] has the shape of a derivable string: an M first and
  /// nowhere else, only I and U after, and a count of I not a multiple
  /// of three.
  static bool shaped(String s) =>
      s.isNotEmpty && s[0] == 'M' && !s.substring(1).contains('M') && s.substring(1).split('').every((c) => c == 'I' || c == 'U') && keepsFaith(s);
}
