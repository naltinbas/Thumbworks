import 'works.dart';

/// The most that can be got to the mill, and the reason nothing more can.
///
/// Two answers, and the pair of them is the whole point of this game. One is
/// an amount down every pipe that really does deliver that much. The other is
/// a set of pipes that, if you cut them, leaves no way from the spring to the
/// mill at all. Add up what those pipes hold and you get the same number.
///
/// So the first says "this much can be done" and the second says "and no more
/// can", and neither is an opinion. That is Ford and Fulkerson, 1956: the
/// most that can flow is what the smallest cut holds.
class Most {
  const Most({
    required this.amount,
    required this.down,
    required this.cut,
    required this.nearSide,
  });

  /// How much reaches the mill.
  final int amount;

  /// How much goes down each pipe.
  final List<int> down;

  /// The pipes of the smallest cut: cut these and nothing gets through.
  final List<int> cut;

  /// The ponds still reachable from the spring once the pipes are as full as
  /// they can be. The cut is every pipe leaving this set.
  final Set<int> nearSide;

  /// What the cut holds, which is the same as [amount] and is checked.
  int holdsOfCut(Works works) {
    var total = 0;
    for (final pipe in cut) {
      total += works.pipes[pipe].holds;
    }
    return total;
  }
}

/// Works out the most that can reach the mill.
///
/// The method is the obvious one done carefully: find a way from the spring to
/// the mill with room to spare, push as much down it as the tightest pipe on
/// it will take, and go again. The care is in two places. Each way is found by
/// walking outwards, so it is the shortest one, which is what stops the search
/// taking as many rounds as the numbers are large. And every pipe carries a
/// way back, so water already sent can be sent somewhere else later. Without
/// that, a first choice that turns out badly can never be undone and the
/// answer comes out too small.
class Flow {
  Flow(this.works);

  final Works works;

  Most work() {
    final pipes = works.pipes.length;
    final down = List<int>.filled(pipes, 0);

    while (true) {
      // Walk outwards from the spring, along pipes with room and back along
      // pipes carrying something.
      final cameBy = List<int>.filled(works.count, -1);
      final forwards = List<bool>.filled(works.count, true);
      final seen = <int>{works.spring};
      final todo = <int>[works.spring];

      while (todo.isNotEmpty && !seen.contains(works.mill)) {
        final here = todo.removeAt(0);
        for (final pipe in works.out(here)) {
          final next = works.pipes[pipe].to;
          if (seen.contains(next)) continue;
          if (down[pipe] >= works.pipes[pipe].holds) continue;
          cameBy[next] = pipe;
          forwards[next] = true;
          seen.add(next);
          todo.add(next);
        }
        for (final pipe in works.into(here)) {
          final next = works.pipes[pipe].from;
          if (seen.contains(next)) continue;
          if (down[pipe] <= 0) continue;
          cameBy[next] = pipe;
          forwards[next] = false;
          seen.add(next);
          todo.add(next);
        }
      }

      if (!seen.contains(works.mill)) {
        // Nothing more can get through. What was reached is the near side of
        // the smallest cut, and the cut is every pipe leaving it.
        final cut = <int>[];
        for (var pipe = 0; pipe < pipes; pipe++) {
          if (seen.contains(works.pipes[pipe].from) &&
              !seen.contains(works.pipes[pipe].to)) {
            cut.add(pipe);
          }
        }
        return Most(
          amount: _reaching(down),
          down: down,
          cut: cut,
          nearSide: seen,
        );
      }

      // The tightest pipe on the way decides how much more can go.
      var room = 1 << 30;
      var at = works.mill;
      while (at != works.spring) {
        final pipe = cameBy[at];
        final spare = forwards[at]
            ? works.pipes[pipe].holds - down[pipe]
            : down[pipe];
        if (spare < room) room = spare;
        at = forwards[at] ? works.pipes[pipe].from : works.pipes[pipe].to;
      }

      at = works.mill;
      while (at != works.spring) {
        final pipe = cameBy[at];
        if (forwards[at]) {
          down[pipe] += room;
          at = works.pipes[pipe].from;
        } else {
          down[pipe] -= room;
          at = works.pipes[pipe].to;
        }
      }
    }
  }

  int _reaching(List<int> down) {
    var total = 0;
    for (final pipe in works.into(works.mill)) {
      total += down[pipe];
    }
    for (final pipe in works.out(works.mill)) {
      total -= down[pipe];
    }
    return total;
  }
}
