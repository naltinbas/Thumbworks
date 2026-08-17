/// Four fields, four sheep and two whistles.
///
/// Each whistle moves every sheep at once: the left one sends the sheep
/// in field 0 to wherever the left whistle points field 0, and so on for
/// the rest. Two sheep that land in the same field stay together from
/// then on, so a flock can only ever get smaller. A call is a string of
/// whistles, and it gathers the flock when it leaves every sheep in one
/// field.
///
/// Some folds cannot be gathered at all. Jan Cerny gave the test in
/// 1964: a fold can be gathered exactly when every two sheep can be
/// brought together, and he built the fold of four fields that needs
/// the longest call of all, nine whistles.
class Rules {
  /// The fields of a fold.
  static const fields = 4;

  static const whistles = ['L', 'R'];

  /// A fold: where each whistle sends each field.
  static const folds = <String, List<List<int>>>{
    'the near fold': [
      [1, 1, 3, 3],
      [2, 0, 2, 0],
    ],
    'the low fold': [
      [0, 0, 1, 2],
      [1, 2, 3, 3],
    ],
    'the far fold': [
      [0, 0, 2, 3],
      [1, 2, 3, 0],
    ],
    'the long fold': [
      [1, 2, 3, 0],
      [1, 1, 2, 3],
    ],
    'the turning fold': [
      [1, 2, 3, 0],
      [0, 2, 1, 3],
    ],
  };

  /// Every sheep in every field: the flock as it starts.
  static int get whole => (1 << fields) - 1;

  /// Where a flock stands after one whistle.
  static int after(List<List<int>> fold, int flock, int whistle) {
    var out = 0;
    for (var field = 0; field < fields; field++) {
      if (flock >> field & 1 == 1) out |= 1 << fold[whistle][field];
    }
    return out;
  }

  /// Where a flock stands after a whole call.
  static int afterCall(List<List<int>> fold, int flock, List<int> call) {
    var out = flock;
    for (final whistle in call) {
      out = after(fold, out, whistle);
    }
    return out;
  }

  /// How many fields the flock is spread over.
  static int spread(int flock) {
    var count = 0;
    for (var field = 0; field < fields; field++) {
      if (flock >> field & 1 == 1) count++;
    }
    return count;
  }

  static bool gathered(int flock) => spread(flock) == 1;

  /// The fewest whistles that gather a flock, walking every flock there
  /// is: the first voice.
  static int? fewest(List<List<int>> fold, [int? from]) {
    final start = from ?? whole;
    final steps = <int, int>{start: 0};
    final queue = <int>[start];
    for (var head = 0; head < queue.length; head++) {
      final flock = queue[head];
      if (gathered(flock)) return steps[flock];
      for (var whistle = 0; whistle < whistles.length; whistle++) {
        final next = after(fold, flock, whistle);
        if (!steps.containsKey(next)) {
          steps[next] = steps[flock]! + 1;
          queue.add(next);
        }
      }
    }
    return null;
  }

  /// The whistle to blow next on a shortest call, or null.
  static int? towards(List<List<int>> fold, int flock) {
    final at = fewest(fold, flock);
    if (at == null || at == 0) return null;
    for (var whistle = 0; whistle < whistles.length; whistle++) {
      final next = fewest(fold, after(fold, flock, whistle));
      if (next != null && next == at - 1) return whistle;
    }
    return null;
  }

  /// Whether every two sheep can be brought together: Cerny's test,
  /// which never looks at a flock of more than two. The second voice.
  static bool pairsMeet(List<List<int>> fold) {
    for (var a = 0; a < fields; a++) {
      for (var b = a + 1; b < fields; b++) {
        final start = (1 << a) | (1 << b);
        final seen = <int>{start};
        final queue = <int>[start];
        var met = false;
        for (var head = 0; head < queue.length && !met; head++) {
          final pair = queue[head];
          if (gathered(pair)) {
            met = true;
            break;
          }
          for (var whistle = 0; whistle < whistles.length; whistle++) {
            final next = after(fold, pair, whistle);
            if (seen.add(next)) queue.add(next);
          }
        }
        if (!met) return false;
      }
    }
    return true;
  }

  /// Whether a whistle only turns the flock round, sending each field to
  /// a field of its own.
  static bool turnsOnly(List<List<int>> fold, int whistle) =>
      fold[whistle].toSet().length == fields;

  /// Every call of [length] whistles, in order.
  static Iterable<List<int>> calls(int length) sync* {
    for (var mask = 0; mask < (1 << length); mask++) {
      yield [for (var i = 0; i < length; i++) mask >> i & 1];
    }
  }

  /// How many calls of [length] gather the flock.
  static int gatherings(List<List<int>> fold, int length) {
    var count = 0;
    for (final call in calls(length)) {
      if (gathered(afterCall(fold, whole, call))) count++;
    }
    return count;
  }

  /// A call told in whistles: 'L R L'.
  static String tellCall(List<int> call) =>
      call.map((whistle) => whistles[whistle]).join(' ');

  /// Which fields a flock stands in.
  static List<int> standing(int flock) => [
        for (var field = 0; field < fields; field++)
          if (flock >> field & 1 == 1) field,
      ];

  /// A field's name: the fields are numbered from one for the player.
  static String tellField(int field) => '${field + 1}';
}
