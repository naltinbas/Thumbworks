/// The law of the low.
///
/// Posts joined by lines, and a number on every post from nought
/// up to the count of lines, no number twice. Each line wears
/// the gap between its ends, and a numbering is graceful when
/// the gaps run one to the count of lines with none repeated.
///
/// Paths, stars and rings of four all take one; the ring of five
/// never will, by parity: round a ring the gaps sum even, since
/// each gap shares its evenness with the sum of its ends and
/// every post is counted twice, but one to five sums to fifteen.
/// The suite reads every gap, walks every numbering, and refuses
/// the bake the moment any two computations part ways.
class Rules {
  Rules(this.posts, this.lines);

  final int posts;
  final List<(int, int)> lines;

  /// The gap each line wears under a numbering; -1 while either
  /// end is unnumbered. Numberings list by post, -1 for bare.
  List<int> gaps(List<int> numbering) => [
        for (final (a, b) in lines)
          numbering[a] < 0 || numbering[b] < 0
              ? -1
              : (numbering[a] - numbering[b]).abs(),
      ];

  /// The posts sharing a number with another post.
  List<int> clashes(List<int> numbering) {
    final seen = <int, List<int>>{};
    for (var post = 0; post < posts; post++) {
      final mark = numbering[post];
      if (mark >= 0) (seen[mark] ??= []).add(post);
    }
    return [
      for (final shared in seen.values)
        if (shared.length > 1) ...shared,
    ];
  }

  /// The lines wearing a gap another line also wears.
  List<int> repeats(List<int> numbering) {
    final worn = gaps(numbering);
    final seen = <int, List<int>>{};
    for (var line = 0; line < lines.length; line++) {
      if (worn[line] >= 0) (seen[worn[line]] ??= []).add(line);
    }
    return [
      for (final shared in seen.values)
        if (shared.length > 1) ...shared,
    ];
  }

  /// Whether a numbering is graceful: all posts marked with
  /// distinct numbers nought to lines, gaps exactly one to lines.
  bool graceful(List<int> numbering) {
    if (numbering.any((mark) => mark < 0)) return false;
    if (clashes(numbering).isNotEmpty) return false;
    if (numbering.any((mark) => mark > lines.length)) return false;
    final worn = List.of(gaps(numbering))..sort();
    for (var at = 0; at < lines.length; at++) {
      if (worn[at] != at + 1) return false;
    }
    return true;
  }

  /// Every full numbering, walked; calls [visit] with each. The
  /// sweep the checker and the suite share.
  void numberings(void Function(List<int>) visit) {
    final numbering = List.filled(posts, -1);
    final taken = List.filled(lines.length + 1, false);
    void walk(int post) {
      if (post == posts) {
        visit(numbering);
        return;
      }
      for (var mark = 0; mark <= lines.length; mark++) {
        if (taken[mark]) continue;
        taken[mark] = true;
        numbering[post] = mark;
        walk(post + 1);
        numbering[post] = -1;
        taken[mark] = false;
      }
    }

    walk(0);
  }

  /// How many numberings come graceful.
  int ways() {
    var count = 0;
    numberings((numbering) {
      if (graceful(numbering)) count++;
    });
    return count;
  }

  /// One graceful numbering, or null.
  List<int>? numbering() {
    List<int>? found;
    numberings((graced) {
      if (found == null && graceful(graced)) {
        found = List.of(graced);
      }
    });
    return found;
  }

  /// Whether the complement, every mark turned to lines-minus-it,
  /// maps graceful to graceful across the whole sweep.
  bool complementsHold() {
    var sound = true;
    numberings((numbered) {
      if (!graceful(numbered)) return;
      final flipped = [
        for (final mark in numbered) lines.length - mark,
      ];
      if (!graceful(flipped)) sound = false;
    });
    return sound;
  }

  /// Whether every full numbering of a ring wears an even gap
  /// sum: the parity that bars the five-ring.
  bool ringParityHolds() {
    var sound = true;
    numberings((numbered) {
      final total = gaps(numbered).fold(0, (a, b) => a + b);
      if (total.isOdd) sound = false;
    });
    return sound;
  }
}
