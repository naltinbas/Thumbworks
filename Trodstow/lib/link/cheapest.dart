import 'parish.dart';

/// The cheapest set of paths that joins the whole parish.
class Network {
  const Network({required this.cut, required this.yards});

  /// The paths to cut.
  final List<int> cut;

  /// What they come to.
  final int yards;
}

/// The reason one particular path has to be in every cheapest network.
class MustBeIn {
  const MustBeIn({
    required this.trod,
    required this.thisSide,
    required this.thatSide,
    required this.crossing,
  });

  final int trod;

  /// The hamlets on each side of the line this path crosses.
  final List<int> thisSide;
  final List<int> thatSide;

  /// Every path that crosses that line, this one among them.
  final List<int> crossing;
}

/// The reason one particular path is in no cheapest network at all.
class NeverIn {
  const NeverIn({required this.trod, required this.loop});

  final int trod;

  /// The loop it closes, this path among them. It is the dearest on that
  /// loop, and any loop has a path you could do without.
  final List<int> loop;
}

/// Works out the cheapest network, and why each path is in it or is not.
///
/// Cheapest first, taking any path that joins two pieces of the parish that
/// are not joined yet and passing over any that would close a loop. That is
/// Kruskal's method from 1956, and it is right for a reason worth having in
/// the game rather than only in a comment.
///
/// Draw a line anywhere across the parish, so that some hamlets are on one
/// side and some on the other. Every network that joins the parish has to
/// cross that line somewhere. So if one crossing path is cheaper than every
/// other crossing path, it is in every cheapest network there is: swap it for
/// whichever crossing path a network does use, and the network still joins
/// everything and costs less. That is the cut property, and it is what the
/// game shows when it is asked why a path has to be there.
///
/// The other way round is the same argument upside down. A path that closes a
/// loop and is the dearest on that loop is in no cheapest network at all,
/// because any network using it could drop it and put back a cheaper path from
/// the same loop.
class Cheapests {
  const Cheapests._();

  /// Cheapest first, starting from paths already cut.
  static Network from(Parish parish, Iterable<int> already) {
    final cut = List.of(already);
    for (final trod in parish.byCost) {
      if (cut.contains(trod)) continue;
      if (parish.wouldLoop(cut, trod)) continue;
      cut.add(trod);
    }
    return Network(cut: cut, yards: parish.yardsOf(cut));
  }

  static Network of(Parish parish) => from(parish, const []);

  /// The same answer, worked out the other way round: start at one hamlet and
  /// keep adding the cheapest path that reaches somewhere new. Prim's method,
  /// which shares nothing with the first but the parish.
  static Network byGrowing(Parish parish) {
    final reached = <int>{0};
    final cut = <int>[];

    while (reached.length < parish.count) {
      var best = -1;
      for (var trod = 0; trod < parish.many; trod++) {
        final ends = parish[trod];
        final one = reached.contains(ends.from);
        final other = reached.contains(ends.to);
        if (one == other) continue;
        if (best < 0 || parish[trod].yards < parish[best].yards) best = trod;
      }
      if (best < 0) break;
      cut.add(best);
      reached
        ..add(parish[best].from)
        ..add(parish[best].to);
    }
    return Network(cut: cut, yards: parish.yardsOf(cut));
  }

  /// And a third time, by trying every set of paths there is. Slow and stupid
  /// on purpose: it is what holds the other two to account.
  static int byTrying(Parish parish) {
    var best = 1 << 30;
    final wanted = parish.count - 1;

    void grow(List<int> cut, int from) {
      if (cut.length == wanted) {
        if (!parish.joinsItAll(cut)) return;
        final yards = parish.yardsOf(cut);
        if (yards < best) best = yards;
        return;
      }
      for (var trod = from; trod < parish.many; trod++) {
        grow([...cut, trod], trod + 1);
      }
    }

    grow(const [], 0);
    return best;
  }

  /// Why a path in the network has to be there: the line it crosses, and every
  /// other path that crosses the same line.
  static MustBeIn whyIn(Parish parish, List<int> network, int trod) {
    // Take the path out and see what the network is left in two of.
    final without = [
      for (final other in network)
        if (other != trod) other,
    ];
    final sides = parish.sidesWith(without);
    final here = sides[parish[trod].from];

    final thisSide = [
      for (var place = 0; place < parish.count; place++)
        if (sides[place] == here) place,
    ];
    final thatSide = [
      for (var place = 0; place < parish.count; place++)
        if (sides[place] != here) place,
    ];
    final crossing = [
      for (var other = 0; other < parish.many; other++)
        if ((sides[parish[other].from] == here) !=
            (sides[parish[other].to] == here))
          other,
    ];

    return MustBeIn(
      trod: trod,
      thisSide: thisSide,
      thatSide: thatSide,
      crossing: crossing,
    );
  }

  /// Why a path outside the network is in no cheapest one: the loop it closes
  /// against the network, which it is the dearest path on.
  static NeverIn? whyNot(Parish parish, List<int> network, int trod) {
    if (network.contains(trod)) return null;
    final loop = _wayThrough(parish, network, parish[trod].from,
        parish[trod].to);
    if (loop == null) return null;
    final whole = [...loop, trod];
    for (final other in loop) {
      if (parish[other].yards > parish[trod].yards) return null;
    }
    return NeverIn(trod: trod, loop: whole);
  }

  /// The paths of the network that lead from one hamlet to another.
  static List<int>? _wayThrough(
    Parish parish,
    List<int> network,
    int from,
    int to,
  ) {
    final came = <int, int>{};
    final seen = <int>{from};
    final waiting = <int>[from];

    while (waiting.isNotEmpty) {
      final here = waiting.removeLast();
      if (here == to) break;
      for (final trod in network) {
        if (!parish[trod].touches(here)) continue;
        final there = parish[trod].otherEnd(here);
        if (!seen.add(there)) continue;
        came[there] = trod;
        waiting.add(there);
      }
    }
    if (!seen.contains(to)) return null;

    final way = <int>[];
    var at = to;
    while (at != from) {
      final trod = came[at]!;
      way.add(trod);
      at = parish[trod].otherEnd(at);
    }
    return way.reversed.toList();
  }

  /// What somebody gets by cutting the paths that get everybody to one place
  /// by the shortest way.
  ///
  /// It is a reasonable thing to want and it is not this question. The network
  /// that gets every hamlet to the church as quickly as possible is usually
  /// not the network that uses the least path, and on every parish here it is
  /// dearer.
  static Network byShortestWay(Parish parish, [int hub = 0]) {
    final far = List.filled(parish.count, 1 << 30);
    final came = List.filled(parish.count, -1);
    far[hub] = 0;
    final left = {for (var place = 0; place < parish.count; place++) place};

    while (left.isNotEmpty) {
      var here = -1;
      for (final place in left) {
        if (here < 0 || far[place] < far[here]) here = place;
      }
      if (far[here] >= 1 << 30) break;
      left.remove(here);

      for (var trod = 0; trod < parish.many; trod++) {
        if (!parish[trod].touches(here)) continue;
        final there = parish[trod].otherEnd(here);
        final by = far[here] + parish[trod].yards;
        if (by < far[there]) {
          far[there] = by;
          came[there] = trod;
        }
      }
    }

    final cut = [
      for (var place = 0; place < parish.count; place++)
        if (came[place] >= 0) came[place],
    ];
    return Network(cut: cut, yards: parish.yardsOf(cut));
  }

  /// The cheapest path out of every hamlet, all together.
  ///
  /// Every one of these is in the cheapest network, whatever else is. Take the
  /// line with that one hamlet on one side and everywhere else on the other:
  /// this is the cheapest path across it, so the cut property puts it in. It
  /// is a free head start and it is worth knowing.
  static Network byNearest(Parish parish) {
    final cut = <int>[];
    for (var place = 0; place < parish.count; place++) {
      var best = -1;
      for (var trod = 0; trod < parish.many; trod++) {
        if (!parish[trod].touches(place)) continue;
        if (best < 0 || parish[trod].yards < parish[best].yards) best = trod;
      }
      if (best >= 0 && !cut.contains(best) && !parish.wouldLoop(cut, best)) {
        cut.add(best);
      }
    }
    // Whatever is left over has to be joined up somehow.
    return from(parish, cut);
  }
}
