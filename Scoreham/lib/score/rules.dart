/// The law of the ring.
///
/// A ring of scores, each a notch up or a wipe down. Pick a start
/// and walk the whole ring from it, tallying as you go: the start is
/// good when the tally never once touches the ground.
///
/// How many good starts a ring holds is known two ways that share
/// nothing. The walk tries every start and counts; the ledger never
/// walks at all: a ring has exactly as many good starts as it runs
/// ahead, notches over wipes, and none when it does not. And there
/// is a start that always works when any does, found without
/// trying: the mark just past the tally's last lowest ebb. The
/// suite proves all three against each other on every ring there
/// is, to a dozen marks.
class Rules {
  /// Whether the walk from [start] keeps the tally above ground the
  /// whole way round.
  static bool staysAhead(List<int> marks, int start) {
    var tally = 0;
    for (var step = 0; step < marks.length; step++) {
      tally += marks[(start + step) % marks.length];
      if (tally <= 0) return false;
    }
    return true;
  }

  /// The tally after each step of the walk from [start].
  static List<int> walkFrom(List<int> marks, int start) {
    var tally = 0;
    return [
      for (var step = 0; step < marks.length; step++)
        tally += marks[(start + step) % marks.length],
    ];
  }

  /// Every good start of a ring, by the walk.
  static List<int> goodStarts(List<int> marks) => [
        for (var start = 0; start < marks.length; start++)
          if (staysAhead(marks, start)) start,
      ];

  /// How far the ring runs ahead: notches over wipes.
  static int ahead(List<int> marks) =>
      marks.fold(0, (tally, mark) => tally + mark);

  /// The start just past the tally's last lowest ebb: good whenever
  /// any start is, and found without walking twice.
  static int pastTheEbb(List<int> marks) {
    var tally = 0;
    var low = 1 << 30;
    var ebb = -1;
    for (var at = 0; at < marks.length; at++) {
      tally += marks[at];
      if (tally <= low) {
        low = tally;
        ebb = at;
      }
    }
    return (ebb + 1) % marks.length;
  }

  /// Whether the walk, the ledger, and the ebb agree on every ring
  /// of up to [most] marks.
  static bool allThreeAgree(int most) {
    for (var count = 1; count <= most; count++) {
      for (var bits = 0; bits < (1 << count); bits++) {
        final marks = [
          for (var at = 0; at < count; at++)
            (bits >> at) & 1 == 1 ? 1 : -1,
        ];
        final goods = goodStarts(marks);
        final ran = ahead(marks);
        if (goods.length != (ran > 0 ? ran : 0)) return false;
        if (ran > 0 && !goods.contains(pastTheEbb(marks))) {
          return false;
        }
      }
    }
    return true;
  }
}
