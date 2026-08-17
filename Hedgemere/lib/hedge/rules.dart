/// A hedge of posts joined by paths, no path making a loop and no post
/// cut off: a tree. Strip every post that has one path left, then do it
/// again, and again. What is left standing at the end is the hedge's
/// middle, and it is always one post or two. Never three.
///
/// Camille Jordan wrote it down in 1869. The middle sits at the halfway
/// mark of every longest path through the hedge, and a line has one
/// halfway post when it is an even number of steps long and two when it
/// is odd, which is where the one or two comes from.
class Rules {
  /// The posts of the hedge, numbered 1 up.
  static const posts = 7;

  /// Post 1 stands on its own; every post after it hangs off an earlier
  /// one. Every shape of hedge there is can be numbered this way, and
  /// each hanging gives one hedge.
  static const hangs = posts - 2;

  /// How many hangers post [p] can choose between: any earlier post.
  static int choices(int p) => p - 1;

  /// The hanging a go opens on, post 3 first. Post 2 has nowhere to
  /// hang but post 1, so it takes no dial.
  static const opening = [2, 3, 3, 4, 6];

  static int get howManyHangings {
    var out = 1;
    for (var p = 3; p <= posts; p++) {
      out *= choices(p);
    }
    return out;
  }

  static bool validHanging(List<int> hanging) {
    if (hanging.length != hangs) return false;
    for (var i = 0; i < hangs; i++) {
      final at = hanging[i];
      if (at < 1 || at > choices(i + 3)) return false;
    }
    return true;
  }

  /// Every hanging the dials allow.
  static Iterable<List<int>> hangings() sync* {
    final at = List.filled(hangs, 1);
    while (true) {
      yield List.of(at);
      var i = hangs - 1;
      while (i >= 0) {
        at[i]++;
        if (at[i] <= choices(i + 3)) break;
        at[i] = 1;
        i--;
      }
      if (i < 0) return;
    }
  }

  /// The paths of the hedge: post 2 to post 1, then each post to its
  /// hanger.
  static List<(int, int)> paths(List<int> hanging) => [
        (2, 1),
        for (var i = 0; i < hangs; i++) (i + 3, hanging[i]),
      ];

  /// Which posts each post is joined to.
  static List<Set<int>> joined(List<int> hanging) {
    final out = [for (var p = 0; p <= posts; p++) <int>{}];
    for (final (a, b) in paths(hanging)) {
      out[a].add(b);
      out[b].add(a);
    }
    return out;
  }

  /// The first voice: strip every post with one path left, round after
  /// round, and see what is still standing. Nothing here measures a
  /// distance.
  static (List<int> middle, int rounds, List<int> fell) peel(
      List<int> hanging) {
    final left = joined(hanging).map((p) => p.toSet()).toList();
    final standing = <int>{for (var p = 1; p <= posts; p++) p};
    final fell = List.filled(posts + 1, 0);
    var rounds = 0;
    while (standing.length > 2) {
      final leaves = [
        for (final p in standing)
          if (left[p].length <= 1) p,
      ];
      for (final p in leaves) {
        for (final q in left[p]) {
          left[q].remove(p);
        }
        left[p].clear();
        standing.remove(p);
        fell[p] = rounds + 1;
      }
      rounds++;
    }
    return (standing.toList()..sort(), rounds, fell);
  }

  /// How far every post is from [from], by walking outward.
  static List<int> stepsFrom(List<Set<int>> joined, int from) {
    final away = List.filled(posts + 1, -1);
    away[from] = 0;
    final queue = <int>[from];
    for (var head = 0; head < queue.length; head++) {
      final p = queue[head];
      for (final q in joined[p]) {
        if (away[q] < 0) {
          away[q] = away[p] + 1;
          queue.add(q);
        }
      }
    }
    return away;
  }

  /// The second voice: the worst walk from each post, and the posts
  /// whose worst walk is the shortest. Nothing here strips anything.
  static (List<int> middle, int radius, int longest) measure(
      List<int> hanging) {
    final adj = joined(hanging);
    final worst = List.filled(posts + 1, 0);
    for (var p = 1; p <= posts; p++) {
      final away = stepsFrom(adj, p);
      var far = 0;
      for (var q = 1; q <= posts; q++) {
        if (away[q] > far) far = away[q];
      }
      worst[p] = far;
    }
    var radius = worst[1], longest = 0;
    for (var p = 1; p <= posts; p++) {
      if (worst[p] < radius) radius = worst[p];
      if (worst[p] > longest) longest = worst[p];
    }
    return ([for (var p = 1; p <= posts; p++) if (worst[p] == radius) p],
        radius,
        longest);
  }

  /// The middle by the first voice, which is what the board draws.
  static List<int> middle(List<int> hanging) => peel(hanging).$1;

  static int rounds(List<int> hanging) => peel(hanging).$2;

  /// The longest walk through the hedge, end to end.
  static int longest(List<int> hanging) => measure(hanging).$3;

  /// The taps the dials take to get from one hanging to another.
  static int taps(List<int> from, List<int> to) {
    var out = 0;
    for (var i = 0; i < hangs; i++) {
      out += (from[i] - to[i]).abs();
    }
    return out;
  }

  static String tellHanging(List<int> hanging) => [
        for (var i = 0; i < hangs; i++) '${i + 3} off ${hanging[i]}',
      ].join(', ');

  static String tellMiddle(List<int> middle) => middle.length == 1
      ? 'post ${middle.first}'
      : 'posts ${middle.first} and ${middle.last}';

  static String tellRounds(int rounds) =>
      '$rounds ${rounds == 1 ? 'round' : 'rounds'}';
}
