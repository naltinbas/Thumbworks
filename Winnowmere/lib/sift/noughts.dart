import 'network.dart';

/// Whether a network really sorts, and the row that shows it does not.
///
/// The whole of the checking rests on one old result, which is the reason
/// this game can be sure of anything at all:
///
/// **A network of comparators sorts every row of numbers if and only if it
/// sorts every row of noughts and ones.**
///
/// It is not obvious and it is not difficult. Suppose a network fails on some
/// row of numbers, so two of the outputs come out the wrong way round. Pick
/// the smaller of those two, and turn the whole row into noughts and ones by
/// writing 0 for everything smaller than it and 1 for everything else. Every
/// comparator does the same thing to the noughts and ones that it did to the
/// numbers, because comparing is all it does and that turning keeps order. So
/// the network fails on that row of noughts and ones as well.
///
/// Which turns "does this sort every row there is" into 2^n rows, and 2^n for
/// eight lines is 256. That is what makes the answer instant rather than a
/// search over every ordering.
class Noughts {
  const Noughts._();

  /// The first row of noughts and ones the network leaves unsorted, or null.
  ///
  /// Given back as bits, bit 0 being the top line. Sorted here means every
  /// nought above every one, since 0 is smaller than 1.
  static int? fails(Sieve sieve) {
    for (var row = 0; row < (1 << sieve.lines); row++) {
      final out = sieve.throughBits(row);
      if (!_isSorted(out, sieve.lines)) return row;
    }
    return null;
  }

  static bool sorts(Sieve sieve) => fails(sieve) == null;

  /// Whether the noughts are all above the ones.
  static bool _isSorted(int row, int lines) {
    var seenOne = false;
    for (var line = 0; line < lines; line++) {
      final bit = (row >> line) & 1;
      if (bit == 1) {
        seenOne = true;
      } else if (seenOne) {
        return false;
      }
    }
    return true;
  }

  /// A row of noughts and ones as a string, top line first, for saying out
  /// loud what went wrong.
  static String words(int row, int lines) => [
        for (var line = 0; line < lines; line++) (row >> line) & 1,
      ].join();

  /// How many of the 2^n rows the network gets right, which is what a player
  /// is really watching go up.
  static int right(Sieve sieve) {
    var count = 0;
    for (var row = 0; row < (1 << sieve.lines); row++) {
      if (_isSorted(sieve.throughBits(row), sieve.lines)) count++;
    }
    return count;
  }
}
