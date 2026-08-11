import 'bench.dart';
import 'rules.dart';

/// A bench part cut: the bolts as they lie, and whose shears are next.
class Play {
  const Play._(
    this.bench,
    this.long,
    this.short,
    this.made,
    this.theirLast,
    this.overBy,
    this.before,
  );

  Play.of(Bench bench)
      : this._(bench, bench.long, bench.short, 0, 0, Shears.none, null);

  final Bench bench;

  /// The bolts as they lie, long at least short.
  final int long;
  final int short;

  /// Cuts of the player's own.
  final int made;

  /// How many times the mercer took last, for the words, or nought.
  final int theirLast;

  /// Who cut a bolt to nothing, if anyone yet.
  final Shears overBy;

  /// The play before the player's last cut, or null at the start.
  final Play? before;

  bool get isOver => overBy != Shears.none;

  bool get won => overBy == Shears.you;

  /// Whether the player, cutting next, still holds the bench.
  bool get winnable => !isOver && !Rules.isLoss(long, short);

  /// The most times the short bolt can come off the long.
  int get quotient => Rules.quotient(long, short);

  /// Whether the player may cut so many times.
  bool mayCut(int times) => !isOver && times >= 1 && times <= quotient;

  /// The player's cut, and the mercer's on its heels.
  Play cut(int times) {
    if (!mayCut(times)) return this;
    var newLong = long - times * short;
    var newShort = short;
    if (newLong == 0) {
      return Play._(bench, 0, short, made + 1, theirLast, Shears.you, this);
    }
    if (newLong < newShort) {
      final swap = newLong;
      newLong = newShort;
      newShort = swap;
    }
    // The mercer's answer.
    var theirs = Rules.winningTimes(newLong, newShort);
    if (theirs == 0) theirs = 1;
    final afterLong = newLong - theirs * newShort;
    if (afterLong == 0) {
      return Play._(
          bench, 0, newShort, made + 1, theirs, Shears.them, this);
    }
    var yourLong = afterLong;
    var yourShort = newShort;
    if (yourLong < yourShort) {
      final swap = yourLong;
      yourLong = yourShort;
      yourShort = swap;
    }
    return Play._(
        bench, yourLong, yourShort, made + 1, theirs, Shears.none, this);
  }

  /// The whole last exchange back, or this at the start.
  Play get back => before ?? this;

  /// The winning number of times, or null when there is none.
  int? get next {
    if (isOver) return null;
    final times = Rules.winningTimes(long, short);
    return times == 0 ? null : times;
  }
}

enum Shears { none, you, them }
