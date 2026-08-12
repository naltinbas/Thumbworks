import 'purse.dart';
import 'rules.dart';

/// A purse being paid. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.purse, this.tray, this.moves, this.before);

  factory Play.of(Purse purse) => Play._(purse, const [], 0, null);

  /// A play stood at a tray, for the mark and the tests.
  factory Play.standing(Purse purse, List<int> tray) =>
      Play._(purse, List.of(tray), tray.length, null);

  final Purse purse;

  /// The coins in the tray.
  final List<int> tray;

  /// Coins moved in and out, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless purse admits it.
  static const gaveUpAt = 12;

  int get total => Rules.total(tray);

  List<(int, int)> get neighbours => Rules.neighbours(tray);

  /// The one payment the well already shows on the hopeless
  /// purse.
  List<int> get shown =>
      purse.secondWay ? Rules.greedy(purse.price) : const [];

  bool get isDone {
    if (!Rules.pays(tray, purse.price)) return false;
    if (!purse.secondWay) return true;
    final ours = List.of(tray)..sort();
    final theirs = List.of(shown)..sort();
    return '$ours' != '$theirs';
  }

  bool get gaveUp => !purse.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Puts a coin in the tray, or takes it back out.
  Play tapAt(int coin) {
    if (isOver) return this;
    if (tray.contains(coin)) {
      return Play._(purse,
          [for (final held in tray) if (held != coin) held],
          moves + 1, this);
    }
    return Play._(purse, [...tray, coin], moves + 1, this);
  }

  Play get back => before ?? this;

  /// The coin the sweep would move next towards the one payment;
  /// null when no payment lands the asking.
  (int, bool)? get next {
    if (purse.secondWay || isDone) return null;
    final aim = Rules.payments(purse.price).single;
    for (final coin in tray) {
      if (!aim.contains(coin)) return (coin, false);
    }
    for (final coin in aim) {
      if (!tray.contains(coin)) return (coin, true);
    }
    return null;
  }
}
