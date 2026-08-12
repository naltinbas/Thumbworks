/// The law of the wall.
///
/// A wall is courses laid one atop another, each course one kind of
/// stone. The waller's rule: no run of courses may be laid twice
/// over, back to back. A run of any length counts, one course or
/// five, and the repeat must come straight after.
///
/// What a wall can climb to is known two ways that share nothing.
/// The sweep lays every wall there is, course by course, and counts
/// what survives at every height; the walk grows one wall from the
/// standing courses and knows whether the asked height is still in
/// reach. Two kinds of stone die at the third course, three kinds
/// climb past any height asked here, and a wall can pen itself in
/// with every course of it sound.
class Rules {
  /// The doubled run in a wall, lowest and longest first, or null:
  /// (where the first half starts, how long each half runs).
  static (int, int)? doubledRun(List<int> courses) {
    for (var from = 0; from < courses.length; from++) {
      for (var run = 1;
          from + 2 * run <= courses.length;
          run++) {
        var same = true;
        for (var at = 0; at < run; at++) {
          if (courses[from + at] != courses[from + run + at]) {
            same = false;
            break;
          }
        }
        if (same) return (from, run);
      }
    }
    return null;
  }

  /// Whether the wall stands sound: no run laid twice over.
  static bool sound(List<int> courses) => doubledRun(courses) == null;

  /// Whether a sound wall can still climb to [height] with [kinds]
  /// of stone, growing every way there is.
  static bool canClimb(List<int> courses, int kinds, int height) {
    if (courses.length >= height) return true;
    for (var kind = 0; kind < kinds; kind++) {
      final grown = [...courses, kind];
      if (sound(grown) && canClimb(grown, kinds, height)) {
        return true;
      }
    }
    return false;
  }

  /// A kind that keeps [height] in reach, or null when the wall is
  /// penned in.
  static int? nextKind(List<int> courses, int kinds, int height) {
    for (var kind = 0; kind < kinds; kind++) {
      final grown = [...courses, kind];
      if (sound(grown) && canClimb(grown, kinds, height)) {
        return kind;
      }
    }
    return null;
  }

  /// How many sound walls stand at exactly [height], swept.
  static int soundWalls(int kinds, int height) {
    var count = 0;
    final courses = <int>[];

    void lay() {
      if (courses.length == height) {
        count++;
        return;
      }
      for (var kind = 0; kind < kinds; kind++) {
        courses.add(kind);
        if (sound(courses)) lay();
        courses.removeLast();
      }
    }

    lay();
    return count;
  }

  /// Whether every sound wall short of [height] either still
  /// climbs or is penned outright, with not one that limps: sound,
  /// extendable, and doomed. True on every pitch that ships.
  static bool neverLimps(int kinds, int height) {
    var holds = true;
    final courses = <int>[];

    void lay() {
      if (!holds || courses.length >= height) return;
      var extendable = false;
      for (var kind = 0; kind < kinds; kind++) {
        courses.add(kind);
        if (sound(courses)) extendable = true;
        courses.removeLast();
      }
      if (extendable && !canClimb(courses, kinds, height)) {
        holds = false;
        return;
      }
      for (var kind = 0; kind < kinds; kind++) {
        courses.add(kind);
        if (sound(courses)) lay();
        courses.removeLast();
      }
    }

    lay();
    return holds;
  }

  /// The tallest any wall of [kinds] kinds reaches, hunting to
  /// [roof].
  static int tallest(int kinds, int roof) {
    var best = 0;
    final courses = <int>[];

    void lay() {
      if (courses.length > best) best = courses.length;
      if (courses.length >= roof) return;
      for (var kind = 0; kind < kinds; kind++) {
        courses.add(kind);
        if (sound(courses)) lay();
        courses.removeLast();
      }
    }

    lay();
    return best;
  }
}
