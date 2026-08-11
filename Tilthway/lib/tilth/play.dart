import 'rules.dart';
import 'tilth.dart';

/// A tilth part sown: the furrows as they stand, and the barn's count.
class Play {
  const Play._(this.tilth, this.board, this.barned, this.before);

  Play.of(Tilth tilth)
      : this._(tilth, List.unmodifiable(tilth.board), 0, null);

  final Tilth tilth;

  /// Seeds by furrow, furrow one nearest the barn.
  final List<int> board;

  /// Seeds home in the barn.
  final int barned;

  /// The tilth before the last sowing, or null at the start.
  final Play? before;

  bool get isHome => barned == tilth.seeds;

  int seedsIn(int furrow) =>
      furrow >= 1 && furrow <= board.length ? board[furrow - 1] : 0;

  /// Whether a furrow may be sown: holding exactly its number.
  bool maySow(int furrow) =>
      !isHome &&
      furrow >= 1 &&
      furrow <= board.length &&
      board[furrow - 1] == furrow;

  /// Sows a furrow. Returns this unchanged when it may not be sown.
  Play sow(int furrow) {
    if (!maySow(furrow)) return this;
    return Play._(
      tilth,
      List.unmodifiable(Rules.sown([...board], furrow)),
      barned + 1,
      this,
    );
  }

  /// The last sowing back, or this at the start.
  Play get back => before ?? this;

  /// The furrows visibly dead: overfull, only ever gaining.
  List<int> get trapped => Rules.overfull([...board]);

  /// Whether the tilth can still be played home.
  bool get canStill => Rules.canWin([...board]);

  /// A sowing that keeps the way home, or null.
  int? get next {
    if (isHome || !canStill) return null;
    for (final furrow in Rules.sowable([...board])) {
      if (Rules.canWin(Rules.sown([...board], furrow))) return furrow;
    }
    return null;
  }
}
