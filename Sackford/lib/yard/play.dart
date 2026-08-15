import 'level.dart';
import 'rules.dart';

/// A yard being loaded. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.cartOf, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, List<int?>.filled(level.sacks.length, null), 0, null);

  /// A play stood at a loading, for the mark and the tests.
  factory Play.standing(Level level, List<int?> cartOf) => Play._(level, List.of(cartOf), 0, null);

  final Level level;

  /// Each sack's cart, or null while on the ground.
  final List<int?> cartOf;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 40;

  List<int> get sacks => level.sacks;
  int get carts => level.carts;

  /// Each cart's load.
  List<int> get loads {
    final out = List.filled(carts, 0);
    for (var i = 0; i < sacks.length; i++) {
      final c = cartOf[i];
      if (c != null) out[c] += sacks[i];
    }
    return out;
  }

  int get loaded => cartOf.where((c) => c != null).length;

  /// The carts loaded past ten.
  List<bool> get over => loads.map((l) => l > Rules.capacity).toList();

  bool get isDone => level.meets(cartOf);

  /// The hopeless ask admits it once every sack is on a cart with none
  /// past ten, which cannot happen, or a cart is over and the taps run
  /// out.
  bool get gaveUp => !level.winnable && !isDone && (loaded == sacks.length && over.every((o) => !o) || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Taps sack [i]: it goes to the next cart, and from the last back to
  /// the ground.
  Play tap(int i) {
    if (isOver || i < 0 || i >= sacks.length) return this;
    final next = List.of(cartOf);
    final now = cartOf[i];
    next[i] = now == null ? 0 : now == carts - 1 ? null : now + 1;
    return Play._(level, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the first sack not on the aim's cart,
  /// and how many taps put it there; null when nothing lands.
  (int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (var i = 0; i < sacks.length; i++) {
      if (cartOf[i] != aim[i]) {
        final now = cartOf[i];
        final nowStep = now == null ? 0 : now + 1;
        return (i, (aim[i] + 1 - nowStep) % (carts + 1));
      }
    }
    return null;
  }

  /// The search's first loading for the ask, kept once found.
  static List<int>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = Rules.loadings(level.sacks, level.carts, atMost: 1).$2;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<int>?>{};
}
