import 'moor.dart';

/// The shortest round there is, and how it was got at.
class Shortest {
  const Shortest({required this.length, required this.order, required this.looked});

  final int length;

  /// The places in the order to call at them, starting from the first.
  final List<int> order;

  /// How many part-rounds had to be worked out.
  final int looked;
}

/// Works out the shortest round that calls at every place once.
///
/// Not by trying every order. There are (n-1)!/2 of those and it is twenty
/// thousand at nine places and two hundred million at thirteen.
///
/// Instead: for every **set** of places and every place in it, work out the
/// shortest way to start at the first place, call at exactly that set, and
/// finish standing at that one. A set of nine has four hundred and fifty
/// three of those, and each is one step longer than a shorter one already
/// worked out. Every order is still accounted for, because an order that
/// calls at the same places and finishes in the same place is competing with
/// this one and only the shorter of them can be part of the answer.
///
/// Held and Karp, 1962. It is exponential and it is enormously less
/// exponential than the other way.
class Rounder {
  Rounder(this.moor);

  final Moor moor;

  static const _far = 1 << 29;

  /// The shortest round from the yard, calling at everywhere and back.
  Shortest work() {
    final found = through(0, [for (var i = 1; i < moor.count; i++) i], 0);
    // The order comes back with the yard at both ends; the round is a ring,
    // so it is written down once.
    return Shortest(
      length: found.length,
      order: found.order.sublist(0, found.order.length - 1),
      looked: found.looked,
    );
  }

  /// The shortest way from one place, calling at every place in [middle], and
  /// finishing at another.
  ///
  /// This is the whole working, and the round is the case where both ends are
  /// the yard. Half way through a round it is asked with the cart's place at
  /// one end and the yard at the other, which is why a hint is about the
  /// round being driven rather than the one that was on offer at the start.
  Shortest through(int from, List<int> middle, int to) {
    final places = middle.length;
    if (places == 0) {
      return Shortest(
        length: moor.between(from, to),
        order: [from, to],
        looked: 0,
      );
    }

    final sets = 1 << places;
    final best = List.generate(sets, (_) => List.filled(places, _far));
    final cameFrom = List.generate(sets, (_) => List.filled(places, -1));
    var looked = 0;

    for (var one = 0; one < places; one++) {
      best[1 << one][one] = moor.between(from, middle[one]);
    }

    for (var set = 1; set < sets; set++) {
      for (var last = 0; last < places; last++) {
        if (set & (1 << last) == 0) continue;
        final sofar = best[set][last];
        if (sofar >= _far) continue;
        looked++;

        for (var next = 0; next < places; next++) {
          if (set & (1 << next) != 0) continue;
          final then = set | (1 << next);
          final total = sofar + moor.between(middle[last], middle[next]);
          if (total < best[then][next]) {
            best[then][next] = total;
            cameFrom[then][next] = last;
          }
        }
      }
    }

    final all = sets - 1;
    var shortest = _far;
    var end = -1;
    for (var last = 0; last < places; last++) {
      final total = best[all][last] + moor.between(middle[last], to);
      if (total < shortest) {
        shortest = total;
        end = last;
      }
    }

    final order = <int>[to];
    var set = all;
    var at = end;
    while (at >= 0) {
      order.add(middle[at]);
      final was = cameFrom[set][at];
      set &= ~(1 << at);
      at = was;
    }
    order.add(from);

    return Shortest(
      length: shortest,
      order: order.reversed.toList(),
      looked: looked,
    );
  }

  /// The shortest round found by trying every order there is.
  ///
  /// Only for small rounds and only for tests: it is what the quick way is
  /// checked against, and the two share nothing but the answer.
  Shortest byTryingEverything() {
    final places = moor.count;
    final rest = [for (var i = 1; i < places; i++) i];
    var shortest = _far;
    var best = <int>[];
    var looked = 0;

    void walk(List<int> order, List<int> left) {
      if (left.isEmpty) {
        looked++;
        final length = moor.lengthOf(order);
        if (length < shortest) {
          shortest = length;
          best = List.of(order);
        }
        return;
      }
      for (var i = 0; i < left.length; i++) {
        final next = left[i];
        walk([...order, next], [
          for (var j = 0; j < left.length; j++)
            if (j != i) left[j],
        ]);
      }
    }

    walk([0], rest);
    return Shortest(length: shortest, order: best, looked: looked);
  }
}
