import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: who is in which cottage, the tenant waiting to
/// swap, the swaps made, and the go before, so one can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.where,
    required this.held,
    required this.swaps,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : where = Rules.opening,
        held = null,
        swaps = 0,
        seen = const {},
        before = null;

  /// A go standing at a lane, no swaps counted: what the mark draws.
  Play.standing(this.level, this.where)
      : held = null,
        swaps = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The cottage each tenant is in.
  final List<int> where;

  /// The tenant waiting for somebody to swap with, or null.
  final int? held;

  final int swaps;

  /// The lanes tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The swaps a hopeless ask runs to before the lane admits it.
  static const gaveUpAt = 12;

  /// The lanes a hopeless ask lets the player try before the lane admits
  /// it.
  static const enough = 6;

  List<List<int>> get orders => level.orders;

  /// The tenant in each cottage.
  List<int> get living {
    final who = List.filled(Rules.cottages, -1);
    for (var t = 0; t < Rules.cottages; t++) {
      who[where[t]] = t;
    }
    return who;
  }

  /// Where each tenant puts the cottage they are in, 0 being best.
  List<int> get standings => [
        for (var t = 0; t < Rules.cottages; t++)
          Rules.rank(orders, t, where[t]),
      ];

  /// The tenants in the cottage they wanted most.
  List<int> get topped => Rules.topped(orders, where);

  /// A group that could better all of its members by trading among
  /// themselves, or null when none can.
  List<int>? get beaters => Rules.blockers(orders, where, firmly: false);

  /// A group that could better one of its members without setting
  /// another back, or null.
  List<int>? get nudgers => Rules.blockers(orders, where, firmly: true);

  /// Picks a tenant up, or swaps the one waiting with this one.
  Play tap(int tenant) {
    if (isOver || tenant < 0 || tenant >= Rules.cottages) return this;
    final waiting = held;
    if (waiting == null) {
      return Play._(
        level: level,
        where: where,
        held: tenant,
        swaps: swaps,
        seen: seen,
        before: before,
      );
    }
    if (waiting == tenant) {
      return Play._(
        level: level,
        where: where,
        held: null,
        swaps: swaps,
        seen: seen,
        before: before,
      );
    }
    final to = [...where];
    to[waiting] = where[tenant];
    to[tenant] = where[waiting];
    return Play._(
      level: level,
      where: to,
      held: null,
      swaps: swaps + 1,
      seen: !level.winnable ? {...seen, Rules.write(to)} : seen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(where);

  /// A hopeless ask, admitted: [enough] lanes tried, or [gaveUpAt]
  /// swaps.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || swaps >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every lane that lands the ask, worked out once per ask.
  static final Map<String, List<List<int>>> _winners = {};

  static List<List<int>> winners(Level level) => _winners.putIfAbsent(
      '${level.name}:${level.street}',
      () => Rules.landings(level.orders, level.meets));

  /// The nearest lane that lands the ask, and the swaps to it.
  (List<int>, int)? get nearest {
    List<int>? best;
    var away = -1;
    for (final lane in winners(level)) {
      final n = Rules.between(where, lane);
      if (away < 0 || n < away) {
        away = n;
        best = lane;
      }
    }
    return best == null ? null : (best, away);
  }

  /// What the pointer says: the two tenants to swap. Null when there is
  /// nothing to point at.
  (int, int)? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    // A swap that puts one tenant where it belongs and takes the other
    // off a cottage it does not belong in shortens the walk by one.
    for (var a = 0; a < Rules.cottages; a++) {
      if (where[a] == near.$1[a]) continue;
      for (var b = 0; b < Rules.cottages; b++) {
        if (a == b || where[b] == near.$1[b]) continue;
        final to = [...where];
        to[a] = where[b];
        to[b] = where[a];
        if (Rules.between(to, near.$1) < near.$2) return (a, b);
      }
    }
    return null;
  }

  /// The pointer's words, given who is waiting.
  String pointed((int, int) aim) {
    final one = Rules.letter(aim.$1), two = Rules.letter(aim.$2);
    if (held == null) return 'Tap tenant $one, then tenant $two.';
    if (held == aim.$1) return 'Now tap tenant $two.';
    if (held == aim.$2) return 'Now tap tenant $one.';
    return 'Tap tenant ${Rules.letter(held!)} again to put them down, then '
        'swap $one with $two.';
  }
}

/// Why one lane and no other: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Four tenants, four cottages, and each tenant owns the one they '
      'start in. Any group of them may walk out and share out the '
      'cottages that group owns between them, and no others. That is the '
      'whole of what anybody is allowed to do.\n\n'
      'A lane is beaten if some group can leave with all of its members '
      'better off. A lane is firm if no group can leave with one of its '
      'members better off and nobody worse. Every street has lanes '
      'nothing beats, and it has exactly one firm lane. Not usually one, '
      'and not one up to a tie: one.\n\n'
      'The firm lane can be found without trying any lane at all. Every '
      'tenant points at whoever owns the cottage they want most. Because '
      'everybody points at exactly one person and there are only four of '
      'them, the pointing has to close into rings. Everybody in a ring '
      'takes the cottage they are pointing at and leaves. Do it again '
      'with whoever is left. Shapley and Scarf published this in 1974 and '
      'credited the rings to Gale.\n\n'
      'The rings also settle why no lane ever beats the one they give. '
      'The tenants in the first ring get the cottage they wanted most out '
      'of all four, so nothing anywhere can improve on it for them, and a '
      'lane that beats another has to better everybody.\n\n'
      'The game never asserts what it has not computed. Every one of the '
      '24 lanes of every ask is tried against every group, and the rings '
      'are run as a second voice that tries no lane. Both were held '
      'against all 331,776 streets four tenants can have, and on every '
      'one of them the firm lane was exactly the rings\' lane and there '
      'was exactly one.\n\n'
      'This is ask $number, ${level.name}. ${level.note}';
}
