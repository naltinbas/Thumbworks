import 'field.dart';
import 'rule_of_three.dart';

/// A way down to one peg.
class Route {
  const Route({required this.jumps, required this.looked});

  final List<Jump> jumps;

  /// How many positions the search had to look at.
  final int looked;

  int get moves => jumps.length;
}

/// Looks for a way of taking a board down to a single peg.
///
/// A position is a bag of pegs and nothing else, so it is one number, and two
/// ways of reaching the same position are the same position. That is what
/// makes the search affordable: the number of positions is far smaller than
/// the number of orders they can be reached in, and remembering the ones that
/// led nowhere is the whole of the pruning.
///
/// The rule of three does the rest. Before looking at a position at all it
/// asks whether any hollow at all could still be the last one, and that is a
/// pair of sums rather than a search.
class Solver {
  Solver(this.field, {this.finishAt = -1, this.give = 1 << 30})
      : _rule = RuleOfThree(field);

  final Field field;

  /// The hollow the last peg must end in, or -1 for anywhere.
  final int finishAt;

  /// How many positions it may look at before giving up. A search that gives
  /// up says so rather than saying no: on the big board there are positions
  /// nothing here could settle, and "I cannot see from here" is the truth
  /// where "there is no way" would be a guess.
  final int give;

  final RuleOfThree _rule;

  /// Positions already shown to lead nowhere.
  final _dead = <int>{};

  int _looked = 0;
  var _gaveUp = false;

  /// A way from here down to one peg, or null if there is none — or if the
  /// search gave up, which [gaveUp] tells apart.
  Route? from(int pegs) {
    _dead.clear();
    _looked = 0;
    _gaveUp = false;
    final jumps = <Jump>[];
    if (!_walk(pegs, jumps)) return null;
    return Route(jumps: jumps, looked: _looked);
  }

  /// Whether there is a way from here down to one peg, or null if the search
  /// gave up before it could say.
  bool? canFinish(int pegs) {
    final route = from(pegs);
    if (route != null) return true;
    return _gaveUp ? null : false;
  }

  /// How many positions the last search looked at.
  int get looked => _looked;

  /// Whether the last search ran out of looking before it could answer.
  bool get gaveUp => _gaveUp;

  bool _walk(int pegs, List<Jump> jumps) {
    if (_isOne(pegs)) {
      return finishAt < 0 || pegs == 1 << finishAt;
    }
    if (_dead.contains(pegs)) return false;
    if (_looked >= give) {
      _gaveUp = true;
      return false;
    }
    _looked++;

    if (!_stillPossible(pegs)) {
      _dead.add(pegs);
      return false;
    }

    for (final jump in field.jumps) {
      if (!canJump(pegs, jump)) continue;
      jumps.add(jump);
      if (_walk(after(pegs, jump), jumps)) return true;
      jumps.removeLast();
      if (_gaveUp) return false;
    }

    _dead.add(pegs);
    return false;
  }

  /// Whether the invariant still allows the finish being looked for.
  bool _stillPossible(int pegs) {
    if (finishAt >= 0) return _rule.couldFinishAt(pegs, finishAt);
    return _rule.couldFinish(pegs).isNotEmpty;
  }

  static bool _isOne(int pegs) => pegs != 0 && pegs & (pegs - 1) == 0;

  /// Whether a jump can be made: a peg to jump, a peg to take, and an empty
  /// hollow to land in.
  static bool canJump(int pegs, Jump jump) =>
      pegs & (1 << jump.from) != 0 &&
      pegs & (1 << jump.over) != 0 &&
      pegs & (1 << jump.to) == 0;

  /// The pegs after a jump.
  static int after(int pegs, Jump jump) =>
      (pegs & ~(1 << jump.from) & ~(1 << jump.over)) | (1 << jump.to);

  /// Every jump that can be made from a position.
  static List<Jump> jumpsIn(Field field, int pegs) =>
      [for (final jump in field.jumps) if (canJump(pegs, jump)) jump];

  static int count(int pegs) {
    var found = 0;
    var left = pegs;
    while (left != 0) {
      left &= left - 1;
      found++;
    }
    return found;
  }
}
