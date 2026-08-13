import 'handful.dart';
import 'rules.dart';

/// A hand being piled. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.handful, this.piles, this.moves, this.before);

  factory Play.of(Handful handful) => Play._(
      handful, List.of(handful.opens)..sort((a, b) => b - a), 0, null);

  /// A play stood at a hand, for the mark and the tests.
  factory Play.standing(Handful handful, List<int> piles) => Play._(
      handful, List.of(piles)..sort((a, b) => b - a), 1, null);

  final Handful handful;

  /// The piles, biggest first.
  final List<int> piles;

  /// Movings taken, counted gross.
  final int moves;

  final Play? before;

  /// The line past which the hopeless handful admits it.
  static const gaveUpAt = 19;

  /// The stones still in the pool.
  int get pool =>
      handful.stones - piles.fold(0, (sum, pile) => sum + pile);

  int get deals => pool == 0 ? Rules.dealsByWalk(piles) : -1;

  List<List<int>> get road =>
      pool == 0 ? Rules.road(piles) : [piles];

  bool get isDone => pool == 0 && deals == handful.asked;

  bool get gaveUp =>
      !handful.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Taps a pile slot: with stones in the pool, the slot takes
  /// one; with the pool empty, the slot's pile sweeps back to
  /// the pool. Slot [piles.length] starts a new pile.
  Play tapAt(int slot) {
    if (isOver || slot < 0 || slot > piles.length) return this;
    final held = List.of(piles);
    if (pool > 0) {
      if (slot == held.length) {
        held.add(1);
      } else {
        held[slot]++;
      }
    } else {
      if (slot == held.length) return this;
      held.removeAt(slot);
    }
    held.sort((a, b) => b - a);
    return Play._(handful, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The slot the show-me points at: toward a nearest landing
  /// hand, growing what wants growing or sweeping a stray
  /// pile; null when none lands.
  int? get next {
    if (isOver || !handful.winnable) return null;
    List<int>? bestAim;
    var nearest = 1 << 30;
    Rules.hands(handful.stones, (hand) {
      if (Rules.dealsByWalk(hand) != handful.asked) return;
      var apart = 0;
      for (var at = 0;
          at < (hand.length > piles.length
              ? hand.length
              : piles.length);
          at++) {
        final aim = at < hand.length ? hand[at] : 0;
        final held = at < piles.length ? piles[at] : 0;
        apart += (aim - held).abs();
      }
      if (apart < nearest) {
        nearest = apart;
        bestAim = List.of(hand);
      }
    });
    final aim = bestAim;
    if (aim == null) return null;
    if (pool > 0) {
      for (var at = 0; at < aim.length; at++) {
        final held = at < piles.length ? piles[at] : 0;
        if (held < aim[at]) {
          return at < piles.length ? at : piles.length;
        }
      }
      return piles.length;
    }
    for (var at = 0; at < piles.length; at++) {
      final wanted = at < aim.length ? aim[at] : 0;
      if (piles[at] > wanted) return at;
    }
    return null;
  }
}
