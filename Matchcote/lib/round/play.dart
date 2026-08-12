import 'cote.dart';
import 'rules.dart';

/// A fixture being paired. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.cote, this.rules, this.laid, this.picked, this.moves,
      this.before);

  factory Play.of(Cote cote) =>
      Play._(cote, Rules(cote.players), const [], null, 0, null);

  /// A play stood at laid rounds, for the mark and the tests.
  factory Play.standing(Cote cote, List<List<(int, int)>> laid) =>
      Play._(cote, Rules(cote.players), List.of(laid), null, 0, null);

  final Cote cote;
  final Rules rules;

  /// The rounds laid past the given ones; the last may be part
  /// full.
  final List<List<(int, int)>> laid;

  /// The player picked towards a pairing, or null.
  final int? picked;

  /// Pairings and unpairings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless cote admits it.
  static const gaveUpAt = 8;

  /// Every round standing, given then laid.
  List<List<(int, int)>> get rounds => [...cote.given, ...laid];

  /// Every pair used anywhere.
  Set<(int, int)> get used => {
        for (final round in rounds) ...round,
      };

  /// The round now filling: the last laid one if part full, else
  /// a fresh one.
  List<(int, int)> get filling =>
      laid.isNotEmpty && laid.last.length < rules.gamesARound
          ? laid.last
          : const [];

  /// The players stood in the filling round.
  Set<int> get stood => {
        for (final (a, b) in filling) ...[a, b],
      };

  bool get isDone => rules.covers(rounds);

  bool get gaveUp => !cote.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Picks a player; the second pairs them into the filling
  /// round, or unpairs a pair standing there.
  Play tapAt(int player) {
    if (isOver) return this;
    final one = picked;
    if (one == null) {
      return Play._(cote, rules, laid, player, moves, before);
    }
    if (one == player) {
      return Play._(cote, rules, laid, null, moves, before);
    }
    final pair = one < player ? (one, player) : (player, one);
    // Unpair when the pair stands in the filling round.
    if (filling.contains(pair)) {
      final trimmed = [
        for (final round in laid)
          [
            for (final held in round)
              if (held != pair) held,
          ],
      ];
      while (trimmed.isNotEmpty && trimmed.last.isEmpty) {
        trimmed.removeLast();
      }
      return Play._(
          cote, rules, trimmed, null, moves + 1, this);
    }
    // Refuse a used pair or a stood player.
    if (used.contains(pair) ||
        stood.contains(one) ||
        stood.contains(player)) {
      return Play._(cote, rules, laid, null, moves, before);
    }
    final next = List.of(laid.map(List<(int, int)>.of));
    if (next.isEmpty ||
        next.last.length >= rules.gamesARound) {
      next.add([]);
    }
    next.last.add(pair);
    return Play._(cote, rules, next, null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The pair the sweep would lay next towards a full fixture;
  /// null when none extends what stands.
  (int, int)? get next {
    if (isDone) return null;
    // Only whole laid rounds carry into the search; a part round
    // must be consistent with some pairing, checked by trying.
    final whole = [
      ...cote.given,
      for (final round in laid)
        if (round.length == rules.gamesARound) round,
    ];
    final part = laid.isNotEmpty &&
            laid.last.length < rules.gamesARound
        ? laid.last
        : const <(int, int)>[];
    final aim = rules.fixture(whole);
    if (aim == null) return null;
    // The target round for the part: the first unlaid one.
    final target = aim[whole.length];
    for (final pair in part) {
      if (!target.contains(pair)) {
        // The part round strays from this fixture: unpair it.
        return pair;
      }
    }
    for (final pair in target) {
      if (!part.contains(pair)) return pair;
    }
    return null;
  }
}
