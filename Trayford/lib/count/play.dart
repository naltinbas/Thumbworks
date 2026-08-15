import 'rules.dart';
import 'tray.dart';

/// A tray being filled. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.tray, this.rules, this.eggs, this.moves, this.before);

  factory Play.of(Tray tray) => Play._(tray, Rules(tray.rows), 0, 0, null);

  /// A play stood at a count, for the mark and the tests.
  factory Play.standing(Tray tray, int eggs) => Play._(tray, Rules(tray.rows), eggs, 1, null);

  final Tray tray;
  final Rules rules;

  /// The eggs in the tray.
  final int eggs;

  /// Fillings taken, counted every one.
  final int moves;

  final Play? before;

  /// The line past which the hopeless tray admits it.
  static const gaveUpAt = 12;

  List<int> get leftovers => rules.leftovers(eggs);

  /// Which askings the count meets, row by row.
  List<bool> get met => [
        for (var i = 0; i < tray.rows.length; i++)
          eggs % tray.rows[i] == tray.asked[i],
      ];

  bool get isDone => rules.meets(eggs, tray.asked);

  bool get gaveUp => !tray.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Fills the tray to [count] eggs: tapping the slot of that count.
  Play fill(int count) {
    if (isOver || count < 0 || count > rules.capacity || count == eggs) return this;
    return Play._(tray, rules, count, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The count the show-me points at: the smallest in the tray that
  /// meets the asking, or null when none does.
  int? get next {
    if (isOver || !tray.winnable) return null;
    final counts = rules.counts(tray.asked);
    return counts.isEmpty ? null : counts.first;
  }
}
