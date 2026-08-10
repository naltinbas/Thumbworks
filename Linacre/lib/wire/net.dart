/// One post: what it is called, and where it stands when drawn.
class Post {
  const Post(this.name, this.x, this.y);

  final String name;

  /// Where it goes, from 0 to 1 across and down. The drawing scales these to
  /// whatever glass it is given, so a net is written down once and looks
  /// right on every phone.
  final double x;
  final double y;
}

/// One wire, between two posts.
class Wire {
  const Wire(this.from, this.to);

  final int from;
  final int to;

  bool touches(int post) => from == post || to == post;

  int otherEnd(int post) => post == from ? to : from;
}

/// A net with the braced wire shrunk away, and the way back to the original.
class Shrunk {
  const Shrunk({required this.net, required this.rootOf, required this.wireOf});

  final Net net;

  /// For each original post, the original post it was merged into.
  final List<int> rootOf;

  /// For each wire of the small net, the original wire it is.
  final List<int> wireOf;
}

/// The net: posts, the wires between them, and the two stations that matter.
class Net {
  Net({
    required this.name,
    required List<Post> posts,
    required List<Wire> wires,
    required this.stationA,
    required this.stationB,
  })  : posts = List.unmodifiable(posts),
        wires = List.unmodifiable(wires);

  final String name;
  final List<Post> posts;
  final List<Wire> wires;

  /// The two stations the message has to pass between.
  final int stationA;
  final int stationB;

  int get count => posts.length;
  int get many => wires.length;

  Wire operator [](int wire) => wires[wire];

  /// Whether the braced wires alone join the stations. Braced wires are given
  /// as bits.
  bool bracedJoin(int braced) => _reaches(braced, everyWire: false);

  /// Whether anything still joins the stations once the cut wires are gone.
  /// Cut wires are given as bits.
  bool anythingJoins(int cut) => _reaches(cut, everyWire: true);

  /// The net with the braced wires shrunk away and the cut wires gone.
  ///
  /// Posts joined by braced wire become one post, because wire the cutter can
  /// never touch might as well be no distance at all. What is left is the
  /// game still to be played, and it is where the live argument comes from:
  /// two webs over what is left settle the rest of the game on their own.
  Shrunk shrunk(int cut, int braced) {
    final group = [for (var post = 0; post < count; post++) post];

    int rootOf(int post) {
      var at = post;
      while (group[at] != at) {
        at = group[at];
      }
      return at;
    }

    for (var wire = 0; wire < many; wire++) {
      if ((braced & (1 << wire)) == 0) continue;
      final one = rootOf(wires[wire].from);
      final other = rootOf(wires[wire].to);
      if (one != other) group[one] = other;
    }

    final root = [for (var post = 0; post < count; post++) rootOf(post)];
    final seen = <int>[];
    final where = List.filled(count, -1);
    for (var post = 0; post < count; post++) {
      if (root[post] == post) {
        where[post] = seen.length;
        seen.add(post);
      }
    }

    final smallPosts = <Post>[
      for (final post in seen) posts[post],
    ];
    final smallWires = <Wire>[];
    final wireOf = <int>[];
    for (var wire = 0; wire < many; wire++) {
      if ((cut & (1 << wire)) != 0) continue;
      if ((braced & (1 << wire)) != 0) continue;
      final one = where[root[wires[wire].from]];
      final other = where[root[wires[wire].to]];
      if (one == other) continue;
      smallWires.add(Wire(one, other));
      wireOf.add(wire);
    }

    return Shrunk(
      net: Net(
        name: name,
        posts: smallPosts,
        wires: smallWires,
        stationA: where[root[stationA]],
        stationB: where[root[stationB]],
      ),
      rootOf: root,
      wireOf: wireOf,
    );
  }

  bool _reaches(int marked, {required bool everyWire}) {
    final seen = List.filled(count, false);
    final waiting = <int>[stationA];
    seen[stationA] = true;

    while (waiting.isNotEmpty) {
      final here = waiting.removeLast();
      if (here == stationB) return true;
      for (var wire = 0; wire < many; wire++) {
        final usable = everyWire
            ? (marked & (1 << wire)) == 0
            : (marked & (1 << wire)) != 0;
        if (!usable || !wires[wire].touches(here)) continue;
        final there = wires[wire].otherEnd(here);
        if (!seen[there]) {
          seen[there] = true;
          waiting.add(there);
        }
      }
    }
    return false;
  }
}
