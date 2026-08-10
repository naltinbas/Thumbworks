import 'net.dart';

/// Two webs of wire with none shared, each joining the same posts, both
/// stations among them.
class TwoWebs {
  const TwoWebs({required this.posts, required this.one, required this.other});

  /// The posts the webs join, as bits. Both stations are in it; posts off to
  /// the side that neither web needs are not.
  final int posts;

  /// Each is a set of wires as bits, and each joins every post in [posts].
  final int one;
  final int other;
}

/// The fact about a net that decides the whole game before it starts.
///
/// If some set of posts, both stations among them, is joined twice over by
/// two webs of wire with none shared, the linesman cannot be beaten even
/// moving second: a cut wounds at most one web, and he braces a wire of the
/// other web that mends the wound. Two webs, one cut a turn, and both are
/// never wounded at once.
///
/// Lehman proved in 1964 that this is exact: the linesman moving second wins
/// exactly when such a pair of webs exists, over some set of posts and not
/// necessarily all of them. The set matters. A net can have a spare post
/// hanging off to the side that no pair of webs could reach, and the linesman
/// wins through the posts that count. A test holds all of this against the
/// game search on a few hundred nets made up at random, which is this game's
/// anchor.
class Webs {
  const Webs._();

  /// Two webs with no wire shared over some set of posts with both stations
  /// in it, or null when no such pair exists anywhere in the net.
  ///
  /// Found the plain way: every set of posts, every way of joining it with
  /// one fewer wires than posts, every pair of such webs. Nets here are small
  /// enough that nothing cleverer earns its keep.
  static TwoWebs? findTwoWebs(Net net) {
    for (var posts = 0; posts < (1 << net.count); posts++) {
      if ((posts & (1 << net.stationA)) == 0) continue;
      if ((posts & (1 << net.stationB)) == 0) continue;

      final webs = _websOver(net, posts);
      for (var one = 0; one < webs.length; one++) {
        for (var other = one + 1; other < webs.length; other++) {
          if (webs[one] & webs[other] != 0) continue;
          return TwoWebs(posts: posts, one: webs[one], other: webs[other]);
        }
      }
    }
    return null;
  }

  /// Every set of wires, one fewer than the posts in [posts], that lies
  /// wholly inside [posts] and joins all of it, as bits.
  static List<int> _websOver(Net net, int posts) {
    final inside = <int>[
      for (var wire = 0; wire < net.many; wire++)
        if ((posts & (1 << net[wire].from)) != 0 &&
            (posts & (1 << net[wire].to)) != 0)
          wire,
    ];
    var count = 0;
    for (var post = 0; post < net.count; post++) {
      if ((posts & (1 << post)) != 0) count++;
    }
    final wanted = count - 1;
    if (inside.length < wanted || wanted <= 0) return const [];

    final webs = <int>[];

    void grow(int from, int chosen, int taken) {
      if (taken == wanted) {
        if (_joinsAll(net, posts, chosen)) webs.add(chosen);
        return;
      }
      if (inside.length - from < wanted - taken) return;
      for (var at = from; at < inside.length; at++) {
        grow(at + 1, chosen | (1 << inside[at]), taken + 1);
      }
    }

    grow(0, 0, 0);
    return webs;
  }

  static bool _joinsAll(Net net, int posts, int wires) {
    var start = -1;
    var count = 0;
    for (var post = 0; post < net.count; post++) {
      if ((posts & (1 << post)) != 0) {
        start = post;
        count++;
      }
    }
    if (start < 0) return false;

    final seen = List.filled(net.count, false);
    final waiting = <int>[start];
    seen[start] = true;
    var reached = 1;

    while (waiting.isNotEmpty) {
      final here = waiting.removeLast();
      for (var wire = 0; wire < net.many; wire++) {
        if ((wires & (1 << wire)) == 0 || !net[wire].touches(here)) continue;
        final there = net[wire].otherEnd(here);
        if (!seen[there]) {
          seen[there] = true;
          reached++;
          waiting.add(there);
        }
      }
    }
    return reached == count;
  }
}
