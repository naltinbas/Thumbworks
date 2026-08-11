import 'letter.dart';
import 'rules.dart';

/// A letter part stamped: how many of each are on it.
class Play {
  const Play._(this.letter, this.cheaps, this.dears, this.before);

  Play.of(Letter letter) : this._(letter, 0, 0, null);

  final Letter letter;

  /// Stamps affixed so far.
  final int cheaps;
  final int dears;

  /// The letter before the last stamp went on, or null at the start.
  final Play? before;

  int get total => cheaps * letter.cheap + dears * letter.dear;

  bool get isPaid => total == letter.amount;

  /// What is still owed, or nought.
  int get owed => letter.amount - total;

  /// Whether the letter can still be paid exactly from here.
  bool get canStill {
    if (total > letter.amount) return false;
    if (owed == 0) return true;
    return Rules.payable(owed, letter.cheap, letter.dear);
  }

  /// Affixes a stamp. True for the cheap one. Returns this unchanged
  /// once the letter is paid.
  Play affix(bool cheap) {
    if (isPaid) return this;
    return Play._(
      letter,
      cheaps + (cheap ? 1 : 0),
      dears + (cheap ? 0 : 1),
      this,
    );
  }

  /// The last stamp off again, or this at the start.
  Play get back => before ?? this;

  /// The stamp to affix next on a paying way, true for cheap, or null
  /// when no way remains.
  bool? get next {
    if (isPaid || !canStill) return null;
    final way = Rules.paying(owed, letter.cheap, letter.dear)!;
    if (way.$2 > 0) return false;
    return true;
  }
}
