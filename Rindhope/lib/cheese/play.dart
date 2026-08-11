import 'block.dart';
import 'fewest.dart';

/// A block part eaten: the shape standing, and whose bite it has been.
class Play {
  const Play._(
    this.block,
    this.heights,
    this.made,
    this.overBy,
    this.theirBite,
    this.before,
  );

  factory Play.of(Block block) {
    var play = Play._(block, block.whole, 0, Mouth.none, null, null);
    if (block.mouseFirst) {
      final (x, y) = Bites.reply(block.whole);
      play = Play._(
        block,
        Bites.bitten(block.whole, x, y),
        0,
        Mouth.none,
        (x, y),
        null,
      );
    }
    return play;
  }

  final Block block;

  /// The columns still standing, tallest allowed on the left.
  final List<int> heights;

  /// Bites of the player's own.
  final int made;

  /// Who took the mouldy crumb, if anyone yet.
  final Mouth overBy;

  /// The grey mouse's last bite, for drawing, or null.
  final (int, int)? theirBite;

  /// The play before the player's last bite, for taking the whole exchange
  /// back, or null at the start.
  final Play? before;

  bool get isOver => overBy != Mouth.none;

  /// Won: the grey mouse took the mould.
  bool get won => overBy == Mouth.them;

  /// Whether the player, biting next, still forces the win.
  bool get winnable => !isOver && !Bites.isLoss(heights);

  /// The fewest bites of the player's own this block can still be won in,
  /// or null once the mould is the player's whatever happens.
  int? get couldFinishIn {
    if (isOver) return won ? made : null;
    if (!winnable) return null;
    return made + Bites.fewestWin(heights);
  }

  bool standing(int x, int y) =>
      x >= 0 && x < heights.length && y >= 0 && y < heights[x];

  /// The player's bite, and the grey mouse's answer on its heels. Returns
  /// this unchanged when no crumb stands there.
  Play touch(int x, int y) {
    if (isOver || !standing(x, y)) return this;
    if (x == 0 && y == 0) {
      return Play._(block, heights, made + 1, Mouth.you, null, this);
    }
    final after = Bites.bitten(heights, x, y);
    if (Bites.poisonOnly(after)) {
      // Only the mould left: the grey mouse must take it.
      return Play._(block, after, made + 1, Mouth.them, null, this);
    }
    final (theirX, theirY) = Bites.reply(after);
    if (theirX == 0 && theirY == 0) {
      return Play._(block, after, made + 1, Mouth.them, null, this);
    }
    return Play._(
      block,
      Bites.bitten(after, theirX, theirY),
      made + 1,
      Mouth.none,
      (theirX, theirY),
      this,
    );
  }

  /// The whole last exchange back, or this at the start.
  Play get back => before ?? this;

  /// The winning bite from here, or null when there is none to be had.
  (int, int)? get next => Bites.next(heights);
}

enum Mouth { none, you, them }
