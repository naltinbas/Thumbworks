import 'fewest.dart';
import 'rounds.dart';
import 'till.dart';

/// A round part counted out.
class Play {
  Play._(this.round, this.fewests, this.tray);

  factory Play.of(Round round, Fewests fewests) =>
      Play._(round, fewests, const []);

  final Round round;

  /// The table of fewest coins, kept for as long as the till is open.
  final Fewests fewests;

  Till get till => round.till;

  /// The coins on the tray, as kinds, in the order they were put down.
  final List<int> tray;

  int get paid => tray.fold(0, (sum, kind) => sum + till.coins[kind].pence);

  int get owed => round.amount - paid;

  int get used => tray.length;

  bool get isDone => owed == 0;

  bool get isFewest => isDone && used <= round.fewest;

  /// Whether a coin would go over the amount.
  bool wouldOverpay(int kind) => till.coins[kind].pence > owed;

  /// Puts a coin on the tray.
  Play put(int kind) {
    if (isDone || kind < 0 || kind >= till.kinds) return this;
    if (wouldOverpay(kind)) return this;
    return Play._(round, fewests, [...tray, kind]);
  }

  /// Takes the latest coin of a kind back off the tray.
  Play take(int kind) {
    final at = tray.lastIndexOf(kind);
    if (at < 0) return this;
    return Play._(round, fewests, [...tray]..removeAt(at));
  }

  Play get again => Play.of(round, fewests);

  /// The fewest coins that finish from here.
  int get left => fewests.fewestFor(owed);

  /// The best this round can now be counted out in, with what is on the tray.
  int get couldFinishIn => used + left;

  /// Asked. The largest coin of an optimal way of finishing from here, which
  /// is worked out from what is owed rather than from the round's own answer,
  /// so it is still right after a poor coin.
  int? get next {
    if (isDone) return null;
    final counting = fewests.countingFor(owed);
    for (var kind = till.kinds - 1; kind >= 0; kind--) {
      if (counting.coins[kind] > 0) return kind;
    }
    return null;
  }

  /// How many of a kind are on the tray.
  int onTray(int kind) => tray.where((coin) => coin == kind).length;
}
