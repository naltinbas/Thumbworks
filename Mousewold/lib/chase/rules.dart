/// The law of the chase.
///
/// A ground is posts joined by paths. The cat and the mouse stand on
/// posts; each turn the cat steps one path or stays, then the mouse
/// does. The cat wins by landing on the mouse; the mouse wins by
/// never being landed on.
///
/// Which grounds the cat can sweep is known two ways that share
/// nothing: the game searched to its end from every standing, and
/// the old folding rule, a ground folding up corner by corner
/// exactly when the cat can win. The suite proves the rule against
/// the search on every connected ground of six posts or fewer.
class Rules {
  Rules(this.posts, List<(int, int)> paths) {
    beside = List.generate(posts, (_) => <int>[]);
    for (final (a, b) in paths) {
      beside[a].add(b);
      beside[b].add(a);
    }
    _solve();
  }

  final int posts;

  /// Each post's neighbours.
  late final List<List<int>> beside;

  /// Moves from a post: stay, or step one path.
  List<int> movesFrom(int post) => [post, ...beside[post]];

  /// catchIn[cat][mouse]: how many cat turns to a certain catch with
  /// best play both sides, cat to move; -1 when the mouse escapes
  /// forever.
  late final List<List<int>> catchIn;

  void _solve() {
    // Backward induction: catchIn = 0 when standing together; else
    // cat picks the move minimising the mouse's best reply.
    catchIn = List.generate(
        posts, (_) => List<int>.filled(posts, -1));
    for (var post = 0; post < posts; post++) {
      catchIn[post][post] = 0;
    }
    var moved = true;
    while (moved) {
      moved = false;
      for (var cat = 0; cat < posts; cat++) {
        for (var mouse = 0; mouse < posts; mouse++) {
          if (cat == mouse) continue;
          // The cat steps; the mouse then flees to its best post.
          var best = -1;
          for (final catTo in movesFrom(cat)) {
            if (catTo == mouse) {
              best = best == -1 ? 1 : (best < 1 ? best : 1);
              continue;
            }
            // The mouse replies: it survives this round; it wants
            // the largest catchIn after, or an escape.
            var worst = 0;
            var escapes = false;
            for (final mouseTo in movesFrom(mouse)) {
              if (mouseTo == catTo) continue;
              final then = catchIn[catTo][mouseTo];
              if (then == -1) {
                escapes = true;
                break;
              }
              if (then > worst) worst = then;
            }
            if (escapes) continue;
            final rounds = worst + 1;
            if (best == -1 || rounds < best) best = rounds;
          }
          if (best != -1 && catchIn[cat][mouse] != best) {
            // Only ever improves downward from -1 or larger counts.
            if (catchIn[cat][mouse] == -1 ||
                best < catchIn[cat][mouse]) {
              catchIn[cat][mouse] = best;
              moved = true;
            }
          }
        }
      }
    }
  }

  /// Whether the cat sweeps the ground from a post: the mouse picks
  /// its start knowing the cat's.
  bool catWinsFrom(int catStart) {
    for (var mouse = 0; mouse < posts; mouse++) {
      if (mouse == catStart) continue;
      if (catchIn[catStart][mouse] == -1) return false;
    }
    return true;
  }

  /// Whether the cat sweeps the ground from anywhere.
  bool get catWins {
    for (var cat = 0; cat < posts; cat++) {
      if (catWinsFrom(cat)) return true;
    }
    return false;
  }

  /// The mouse's best start against a cat: escaping if it can, else
  /// the longest stand.
  int mouseStart(int catStart) {
    var best = -1;
    var bestRounds = -2;
    for (var mouse = 0; mouse < posts; mouse++) {
      if (mouse == catStart) continue;
      final rounds = catchIn[catStart][mouse];
      if (rounds == -1) return mouse;
      if (rounds > bestRounds) {
        bestRounds = rounds;
        best = mouse;
      }
    }
    return best;
  }

  /// The mouse's best reply after the cat lands on catTo.
  int mouseMove(int catTo, int mouse) {
    var best = mouse;
    var bestRounds = -2;
    for (final mouseTo in movesFrom(mouse)) {
      if (mouseTo == catTo) continue;
      final rounds = catchIn[catTo][mouseTo];
      if (rounds == -1) return mouseTo;
      if (rounds > bestRounds) {
        bestRounds = rounds;
        best = mouseTo;
      }
    }
    return best;
  }

  /// The cat's best step, or null when no step shortens the chase.
  int? catMove(int cat, int mouse) {
    final here = catchIn[cat][mouse];
    if (here == -1) return null;
    for (final catTo in movesFrom(cat)) {
      if (catTo == mouse) return catTo;
      // After the mouse's best reply, the count must fall.
      var worst = -1;
      var escapes = false;
      for (final mouseTo in movesFrom(mouse)) {
        if (mouseTo == catTo) continue;
        final then = catchIn[catTo][mouseTo];
        if (then == -1) {
          escapes = true;
          break;
        }
        if (then > worst) worst = then;
      }
      if (escapes) continue;
      if (worst + 1 == here) return catTo;
    }
    return null;
  }

  /// The folding rule: a corner is a post whose moves all lie within
  /// another post's moves. Fold corners away one by one; the ground
  /// is cat-win exactly when it folds to a single post. Returns the
  /// folding order, or null when the ground jams.
  List<int>? folding() {
    final gone = List<bool>.filled(posts, false);
    final order = <int>[];
    var left = posts;
    var moved = true;
    while (left > 1 && moved) {
      moved = false;
      for (var corner = 0; corner < posts && !moved; corner++) {
        if (gone[corner]) continue;
        for (var keeper = 0; keeper < posts; keeper++) {
          if (keeper == corner || gone[keeper]) continue;
          final cornerMoves = {
            corner,
            ...beside[corner].where((post) => !gone[post]),
          };
          final keeperMoves = {
            keeper,
            ...beside[keeper].where((post) => !gone[post]),
          };
          if (keeperMoves.containsAll(cornerMoves)) {
            gone[corner] = true;
            order.add(corner);
            left--;
            moved = true;
            break;
          }
        }
      }
    }
    return left == 1 ? order : null;
  }
}
