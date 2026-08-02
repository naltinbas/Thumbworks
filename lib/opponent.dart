import 'package:flutter/foundation.dart';

import 'game/board.dart';
import 'game/search.dart';

/// How hard the opponent thinks.
enum Strength {
  /// Two plies. Sees a man it can take and a man about to be taken, and not
  /// much else. This is the one to learn the rules against.
  steady('Steady', 2),

  /// Four plies. Will not walk into a capture and will set one up.
  sharp('Sharp', 4),

  /// Six plies. Plans, and takes a second or two to do it.
  deep('Deep', 6);

  const Strength(this.label, this.depth);

  final String label;
  final int depth;
}

/// What to think about, in one object because that is what crosses to the
/// other thread.
class Ask {
  const Ask(this.board, this.depth);

  final Board board;
  final int depth;
}

/// Thinks, on a thread that is not the one drawing the screen.
///
/// Six plies is most of a second on a phone, and a second of a frozen screen
/// is a phone that looks broken. So the search goes to a worker: the board is
/// copied over, the answer comes back, and the animation of the last move
/// keeps running while it happens.
///
/// Everything the search touches is a plain immutable object, which is what
/// makes this a one-line change rather than a rewrite.
Future<Thought> ponder(Ask ask) => compute(_think, ask);

Thought _think(Ask ask) => Search(depth: ask.depth).think(ask.board);
