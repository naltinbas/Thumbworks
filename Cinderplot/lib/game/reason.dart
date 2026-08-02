import 'field.dart';
import 'play.dart';

/// The kinds of reasoning a board can ask for, easiest first.
enum Rule {
  /// One number, on its own. It has as many mines around it as it says, and
  /// once you know where they are the rest of its neighbours are clear.
  counted,

  /// Two numbers, where everything one of them can see the other can see too.
  /// The difference between what they say goes in the squares only the second
  /// one can see.
  subset,

  /// Every way the mines could lie, listed. If a square holds a mine in all
  /// of them it holds one; if it is clear in all of them it is clear.
  whole,
}

/// One thing that can be worked out from what is on the board.
class Finding {
  const Finding({
    required this.rule,
    required this.safe,
    required this.mined,
    this.clue = -1,
    this.other = -1,
  });

  final Rule rule;

  /// Squares this step proves are clear, and squares it proves are mines.
  final Set<int> safe;
  final Set<int> mined;

  /// The number the step was read off, and the second one for a [Rule.subset]
  /// step. Not for the proof — for the hint, which has to point at something.
  final int clue;
  final int other;

  bool get isEmpty => safe.isEmpty && mined.isEmpty;
}

/// Works out what can be worked out, and refuses to guess.
///
/// This is the whole of the game's promise. A board only ships if this can
/// clear it, so being an incomplete solver is safe: it decides which boards
/// exist, and the boards it cannot finish are the ones that never get made.
/// What it cannot do is be *wrong*, and every rule here is a rule whose
/// conclusion follows from the numbers on the board alone.
class Reasoner {
  Reasoner(this.play, {this.upTo = Rule.whole, Set<int>? known})
      : known = known == null ? <int>{} : {...known};

  final Play play;

  /// The hardest rule allowed. A board can be made to need no more than
  /// counting, which is a different game from one that needs the third rule.
  final Rule upTo;

  /// Squares proved to hold a mine. The player's flags are not consulted:
  /// a flag is an opinion, and reasoning from one would let a wrong flag
  /// prove anything.
  final Set<int> known;

  Field get field => play.field;

  bool _isUnknown(int at) => !play.isOpen(at) && !known.contains(at);

  List<int> _unknownAround(int at) =>
      [for (final near in field.around(at)) if (_isUnknown(near)) near];

  /// How many mines a number still has to account for.
  int _needAt(int at) {
    var need = field.countAt(at);
    for (final near in field.around(at)) {
      if (known.contains(near)) need--;
    }
    return need;
  }

  /// The open squares that still have something unknown next to them.
  List<int> get _clues => [
        for (final at in play.opened)
          if (_unknownAround(at).isNotEmpty) at,
      ];

  /// The next thing that follows from the board, or null if nothing does.
  ///
  /// Tries the rules in order, so a step is always the easiest one available
  /// — which matters for the hint, where being told to enumerate when a 1 was
  /// staring at you is not help.
  Finding? get step {
    final counted = _counted();
    if (counted != null) return counted;
    if (upTo == Rule.counted) return null;

    final subset = _subset();
    if (subset != null) return subset;
    if (upTo == Rule.subset) return null;

    return _whole();
  }

  /// One number, on its own.
  Finding? _counted() {
    for (final at in _clues) {
      final unknown = _unknownAround(at);
      final need = _needAt(at);
      if (need == 0) {
        return Finding(rule: Rule.counted, clue: at, safe: {...unknown}, mined: {});
      }
      if (need == unknown.length) {
        return Finding(rule: Rule.counted, clue: at, safe: {}, mined: {...unknown});
      }
    }
    return null;
  }

  /// Two numbers, one of which sees a subset of what the other sees.
  Finding? _subset() {
    final clues = _clues;
    final unknownOf = {for (final at in clues) at: _unknownAround(at).toSet()};

    for (final small in clues) {
      final theirs = unknownOf[small]!;
      for (final big in clues) {
        if (big == small) continue;
        final ours = unknownOf[big]!;
        if (ours.length <= theirs.length) continue;
        if (!ours.containsAll(theirs)) continue;

        final only = ours.difference(theirs);
        final gap = _needAt(big) - _needAt(small);
        if (gap == 0) {
          return Finding(
            rule: Rule.subset,
            clue: big,
            other: small,
            safe: only,
            mined: {},
          );
        }
        if (gap == only.length) {
          return Finding(
            rule: Rule.subset,
            clue: big,
            other: small,
            safe: {},
            mined: only,
          );
        }
      }
    }
    return null;
  }

  /// Every way the mines could lie.
  ///
  /// The unknown squares next to a number are split into groups that share no
  /// number between them, because two such groups cannot constrain each other
  /// and listing them together would multiply the work for nothing. Each
  /// group is walked through by backtracking; a square that comes out the
  /// same way every time is proved.
  Finding? _whole() {
    final edge = <int>{};
    for (final at in _clues) {
      edge.addAll(_unknownAround(at));
    }
    if (edge.isEmpty) return null;

    final groups = _groupsOf(edge);
    var leastMines = 0;
    var mostMines = 0;
    Finding? found;

    for (final group in groups) {
      final ways = _waysFor(group);
      // Too many arrangements to list, or none at all. Neither is a thing to
      // report: the first is not reasoning anybody does at a board, and the
      // second means the board is already impossible, which cannot happen on
      // a board that was built by this same solver.
      if (ways == null || ways.ways == 0) return null;

      leastMines += ways.least;
      mostMines += ways.most;

      if (found != null) continue;
      final always = <int>{};
      final never = <int>{};
      for (var i = 0; i < group.length; i++) {
        if (ways.mineIn[i] == ways.ways) always.add(group[i]);
        if (ways.mineIn[i] == 0) never.add(group[i]);
      }
      if (always.isNotEmpty || never.isNotEmpty) {
        found = Finding(rule: Rule.whole, safe: never, mined: always);
      }
    }
    if (found != null) return found;

    // The mines that are left, against the squares no number can see.
    final left = field.mines.length - known.length;
    final outside = <int>{
      for (var at = 0; at < field.cells; at++)
        if (_isUnknown(at) && !edge.contains(at)) at,
    };
    if (outside.isEmpty) return null;

    // If the edge cannot hold fewer than all the mines there are, there is
    // nothing left over for anywhere else.
    if (leastMines == left) {
      return Finding(rule: Rule.whole, safe: outside, mined: {});
    }
    // And if the edge cannot hold enough of them, everywhere else is a mine.
    if (mostMines + outside.length == left) {
      return Finding(rule: Rule.whole, safe: {}, mined: outside);
    }
    return null;
  }

  /// Splits the edge into groups that share no number.
  List<List<int>> _groupsOf(Set<int> edge) {
    final near = {for (final at in edge) at: <int>{}};
    for (final clue in _clues) {
      final seen = [for (final at in field.around(clue)) if (edge.contains(at)) at];
      for (final a in seen) {
        for (final b in seen) {
          if (a != b) near[a]!.add(b);
        }
      }
    }

    final groups = <List<int>>[];
    final done = <int>{};
    for (final start in edge) {
      if (done.contains(start)) continue;
      final group = <int>[];
      final todo = <int>[start];
      done.add(start);
      while (todo.isNotEmpty) {
        final here = todo.removeLast();
        group.add(here);
        for (final next in near[here]!) {
          if (done.add(next)) todo.add(next);
        }
      }
      group.sort();
      groups.add(group);
    }
    return groups;
  }

  /// How many arrangements this will walk through before deciding it is not
  /// the kind of thinking anybody does at a board.
  static const mostWays = 1 << 22;

  /// The tally of every consistent way the mines could lie in one group.
  ///
  /// The arrangements themselves are never kept — there can be millions, and
  /// the only questions asked of them are how many there were, how many mines
  /// the fewest and the most had, and how often each square held one.
  ({int ways, List<int> mineIn, int least, int most})? _waysFor(
    List<int> group,
  ) {
    final n = group.length;
    final indexOf = {for (var i = 0; i < n; i++) group[i]: i};

    // Only numbers touching this group can say anything about it — and every
    // unknown square such a number can see is in this group, because two
    // squares a number can both see are in the same group by construction.
    final watchers = <List<int>>[for (var i = 0; i < n; i++) []];
    final need = <int>[];
    final watching = <int>[];
    for (final clue in _clues) {
      final theirs = _unknownAround(clue);
      if (!theirs.any(indexOf.containsKey)) continue;
      // Every unknown square a number can see is in the same group, because
      // two squares one number sees are joined by that number.
      assert(theirs.every(indexOf.containsKey));
      final which = need.length;
      need.add(_needAt(clue));
      watching.add(theirs.length);
      for (final at in theirs) {
        watchers[indexOf[at]!].add(which);
      }
    }

    final mines = List.filled(need.length, 0);
    final spare = [...watching];
    final left = field.mines.length - known.length;

    var ways = 0;
    var laid = 0;
    var least = n + 1;
    var most = -1;
    final mineIn = List.filled(n, 0);
    final laying = List.filled(n, false);
    var looked = 0;
    var gaveUp = false;

    void walk(int i) {
      if (gaveUp) return;
      if (++looked > mostWays) {
        gaveUp = true;
        return;
      }
      if (i == n) {
        ways++;
        if (laid < least) least = laid;
        if (laid > most) most = laid;
        for (var k = 0; k < n; k++) {
          if (laying[k]) mineIn[k]++;
        }
        return;
      }

      for (final mine in const [false, true]) {
        if (mine && laid >= left) continue;
        var ok = true;
        for (final which in watchers[i]) {
          if (mine) mines[which]++;
          spare[which]--;
          if (mines[which] > need[which] ||
              mines[which] + spare[which] < need[which]) {
            ok = false;
          }
        }
        if (ok) {
          laying[i] = mine;
          if (mine) laid++;
          walk(i + 1);
          if (mine) laid--;
          laying[i] = false;
        }
        for (final which in watchers[i]) {
          if (mine) mines[which]--;
          spare[which]++;
        }
        if (gaveUp) return;
      }
    }

    walk(0);
    if (gaveUp) return null;
    if (ways == 0) return (ways: 0, mineIn: mineIn, least: 0, most: 0);
    return (ways: ways, mineIn: mineIn, least: least, most: most);
  }
}
