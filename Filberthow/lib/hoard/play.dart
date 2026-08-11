import 'hoard.dart';
import 'rules.dart';

/// A hoard part taken: what stands, what the cap is, whose the last nut
/// was.
class Play {
  const Play._(
    this.hoard,
    this.nuts,
    this.cap,
    this.made,
    this.theirLast,
    this.overBy,
    this.before,
  );

  Play.of(Hoard hoard)
      : this._(hoard, hoard.nuts, hoard.nuts - 1, 0, 0, Paw.none, null);

  final Hoard hoard;

  /// Nuts still in the hoard.
  final int nuts;

  /// The most the player may take next.
  final int cap;

  /// Takes of the player's own.
  final int made;

  /// What the grey squirrel took last, for the words, or nought.
  final int theirLast;

  /// Who took the last nut, if anyone yet.
  final Paw overBy;

  /// The play before the player's last take, or null at the start.
  final Play? before;

  bool get isOver => overBy != Paw.none;

  bool get won => overBy == Paw.you;

  /// Whether the player, taking next, still wins against perfect play.
  bool get winnable => !isOver && !Rules.isLoss(nuts, cap);

  /// Whether the player may take so many.
  bool mayTake(int take) =>
      !isOver && take >= 1 && take <= cap && take <= nuts;

  /// The player's take, and the grey squirrel's on its heels.
  Play take(int take) {
    if (!mayTake(take)) return this;
    var left = nuts - take;
    if (left == 0) {
      return Play._(hoard, 0, 0, made + 1, theirLast, Paw.you, this);
    }
    var theirCap = 2 * take;
    if (theirCap > left) theirCap = left;
    var theirs = Rules.winningTake(left, theirCap);
    if (theirs == 0) theirs = Rules.stubbornTake(left, theirCap);
    if (theirs > left) theirs = left;
    left -= theirs;
    if (left == 0) {
      return Play._(hoard, 0, 0, made + 1, theirs, Paw.them, this);
    }
    var yourCap = 2 * theirs;
    if (yourCap > left) yourCap = left;
    return Play._(hoard, left, yourCap, made + 1, theirs, Paw.none, this);
  }

  /// The whole last exchange back, or this at the start.
  Play get back => before ?? this;

  /// The winning take from here, or null when there is none.
  int? get next {
    if (isOver) return null;
    final take = Rules.winningTake(nuts, cap);
    return take == 0 ? null : take;
  }

  /// The split of what stands, biggest cluster first.
  List<int> get clusters => Rules.split(nuts);
}

enum Paw { none, you, them }
