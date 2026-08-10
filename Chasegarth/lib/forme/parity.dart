import 'chase.dart';

/// Whether an arrangement of type can be slid into reading right, and why.
///
/// Sliding a letter sideways changes nothing about the order the letters come
/// in when the frame is read straight through, so the number of pairs out of
/// order stays exactly as it was. Sliding one up or down carries it past every
/// other letter in one row, which is one fewer than the width of the chase.
///
/// So on a chase an odd number of cells wide, an up or down slide carries a
/// letter past an even number of others and the pairs out of order stay odd or
/// stay even, whatever anybody does. That count on its own is the thing that
/// never changes.
///
/// On a chase an even number of cells wide, an up or down slide carries a
/// letter past an odd number of others and flips it, but it also moves the
/// empty cell one row. So the two of them together, the pairs out of order plus
/// the rows between the empty cell and where it belongs, are what never
/// changes.
///
/// Either way it is fixed before anybody touches the frame, and exactly half of
/// all the arrangements there are have the wrong one and can never be made to
/// read right. Not because nobody has found a way. Because there is no way.
class Parity {
  const Parity._();

  /// The pairs of letters that are out of order when the frame is read
  /// straight through, ignoring the empty cell.
  static List<(int, int)> outOfOrder(List<int> stands) {
    final sorts = [
      for (final sort in stands)
        if (sort >= 0) sort,
    ];
    final pairs = <(int, int)>[];
    for (var one = 0; one < sorts.length; one++) {
      for (var other = one + 1; other < sorts.length; other++) {
        if (sorts[one] > sorts[other]) pairs.add((sorts[one], sorts[other]));
      }
    }
    return pairs;
  }

  /// How many rows the empty cell is from the row it belongs in.
  static int emptyAway(Chase chase, List<int> stands) {
    final empty = stands.indexOf(-1);
    final belongs = chase.locked.indexOf(-1);
    return (chase.rowOf(empty) - chase.rowOf(belongs)).abs();
  }

  /// The thing that never changes: odd or even.
  ///
  /// The rows the empty cell is away only come into it on a chase an even
  /// number of cells wide. On an odd one an up or down slide carries a letter
  /// past an even number of others and the pairs out of order do not flip, so
  /// counting the empty cell as well would break the very thing being counted.
  static bool isEven(Chase chase, List<int> stands) {
    final pairs = outOfOrder(stands).length;
    if (chase.wide.isOdd) return pairs.isEven;
    return (pairs + emptyAway(chase, stands)).isEven;
  }

  /// Whether an arrangement can be slid into reading right.
  static bool canBeLocked(Chase chase, List<int> stands) =>
      isEven(chase, stands) == isEven(chase, chase.locked);

  /// A pair of letters that could be swapped to make it possible, when it is
  /// not. Any pair will do, and the first two the reading disagrees about is
  /// the one worth naming.
  static (int, int)? swapThatWouldDoIt(Chase chase, List<int> stands) {
    if (canBeLocked(chase, stands)) return null;
    final sorts = [
      for (final sort in stands)
        if (sort >= 0) sort,
    ];
    for (var one = 0; one < sorts.length; one++) {
      for (var other = one + 1; other < sorts.length; other++) {
        if (sorts[one] > sorts[other]) return (sorts[one], sorts[other]);
      }
    }
    return null;
  }
}
