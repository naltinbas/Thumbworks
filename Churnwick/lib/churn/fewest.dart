import 'dart:collection';

import 'dairy.dart';

/// The shortest way to get the amount wanted standing in a churn.
class Measure {
  const Measure({required this.pours, required this.how, required this.seen});

  /// How many goes it takes.
  final int pours;

  /// One way of doing it in that many.
  final List<Pour> how;

  /// How many arrangements of milk had to be looked at.
  final int seen;
}

/// Works out the fewest goes a dairy takes, and what can be measured in it at
/// all.
class Pouring {
  const Pouring._();

  /// The whole number that every churn is a whole number of.
  ///
  /// This is the thing worth knowing about a dairy. Filling puts a churnful
  /// in, emptying takes a churnful out, and pouring moves milk from one to
  /// another without any of it going anywhere else. So whatever is standing
  /// in the churns is always a whole number of these added and taken away,
  /// and nothing that is not a multiple of it can ever stand anywhere. No
  /// search is needed to know that and no search could tell you it as
  /// plainly.
  static int stepOf(List<int> churns) =>
      churns.reduce((one, other) => _gcd(one, other));

  static int _gcd(int one, int other) {
    var big = one, small = other;
    while (small != 0) {
      final left = big % small;
      big = small;
      small = left;
    }
    return big;
  }

  /// Every amount that can be got to stand in a churn: the multiples of the
  /// step, up to the biggest churn there is.
  static List<int> whatCanStand(Dairy dairy) {
    final step = stepOf(dairy.churns);
    return [
      for (var amount = step; amount <= dairy.biggest; amount += step) amount,
    ];
  }

  static bool canBeDone(Dairy dairy) =>
      dairy.want > 0 &&
      dairy.want <= dairy.biggest &&
      dairy.want % stepOf(dairy.churns) == 0;

  /// The fewest goes, found by looking at every arrangement of milk the dairy
  /// can be in, nearest first.
  ///
  /// There are not many of them: a dairy of three churns holding nine, seven
  /// and four has ten times eight times five arrangements at the very most,
  /// and most of those cannot be reached. So the whole thing is walked rather
  /// than reasoned about, and the answer is the fewest because nothing shorter
  /// was left unwalked.
  static Measure? fewestFor(Dairy dairy) => fewestFrom(dairy, dairy.empty);

  /// The same, from an arrangement of milk that is already part way along.
  static Measure? fewestFrom(Dairy dairy, List<int> start) {
    final from = <String, (List<int>, Pour)>{};
    final seen = <String>{_key(start)};
    final waiting = Queue<List<int>>()..add(start);
    var looked = 0;

    if (dairy.isDone(start)) {
      return const Measure(pours: 0, how: [], seen: 1);
    }

    while (waiting.isNotEmpty) {
      final standing = waiting.removeFirst();
      looked++;

      for (final pour in pouringsFrom(dairy, standing)) {
        final next = pour.on(dairy, standing);
        final key = _key(next);
        if (!seen.add(key)) continue;
        from[key] = (standing, pour);

        if (dairy.isDone(next)) {
          final how = <Pour>[];
          var back = next;
          while (from.containsKey(_key(back))) {
            final (was, done) = from[_key(back)]!;
            how.add(done);
            back = was;
          }
          return Measure(
            pours: how.length,
            how: how.reversed.toList(),
            seen: looked,
          );
        }
        waiting.add(next);
      }
    }
    return null;
  }

  /// The same number, worked out without looking at anything.
  ///
  /// Two churns leave only two things worth doing. Keep filling the first and
  /// tipping it into the second, emptying the second whenever it fills up, or
  /// do the same the other way round. One of those two is always the fewest
  /// there is, so counting both and taking the smaller settles a two churn
  /// dairy with no search at all.
  ///
  /// Null when there are not two churns, or when it cannot be done.
  static int? byTipping(Dairy dairy) {
    if (dairy.count != 2 || !canBeDone(dairy)) return null;
    final one = _keepTipping(dairy.churns[0], dairy.churns[1], dairy.want);
    final other = _keepTipping(dairy.churns[1], dairy.churns[0], dairy.want);
    if (one == null) return other;
    if (other == null) return one;
    return one < other ? one : other;
  }

  static int? _keepTipping(int from, int into, int want) {
    var here = 0, there = 0, goes = 0;
    final most = 4 * (from + into) + 10;

    while (goes < most) {
      if (here == want || there == want) return goes;
      if (here == 0) {
        here = from;
      } else if (there == into) {
        there = 0;
      } else {
        final moved = here < into - there ? here : into - there;
        here -= moved;
        there += moved;
      }
      goes++;
    }
    return null;
  }

  /// Every amount that really can be got to stand, found by walking the whole
  /// dairy. It is here to hold [whatCanStand] to account rather than to be
  /// used by the game.
  static Set<int> reachedByWalking(List<int> churns) {
    final dairy = Dairy(name: 'walk', churns: churns, want: -1);
    final start = dairy.empty;
    final seen = <String>{_key(start)};
    final waiting = Queue<List<int>>()..add(start);
    final stood = <int>{};

    while (waiting.isNotEmpty) {
      final standing = waiting.removeFirst();
      stood.addAll(standing);
      for (final pour in pouringsFrom(dairy, standing)) {
        final next = pour.on(dairy, standing);
        if (seen.add(_key(next))) waiting.add(next);
      }
    }
    stood.remove(0);
    return stood;
  }

  static String _key(List<int> standing) => standing.join(',');
}
