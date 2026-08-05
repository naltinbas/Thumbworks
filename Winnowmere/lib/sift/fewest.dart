import 'network.dart';

/// The fewest comparators that will sort a given number of lines.
///
/// Worked out rather than looked up, by walking outwards: every network of no
/// comparators, then every network of one, and so on, until one of them
/// sorts. What makes that possible at all is that a network is only ever
/// worth what its outputs are worth, so two networks that turn the 2^n rows
/// of noughts and ones into the same set of rows are the same network as far
/// as anything after them is concerned. Keeping one of each set rather than
/// one of each network is the difference between a walk that finishes and one
/// that does not.
///
/// Three, four and five lines settle in a moment; six takes half a second and
/// seven takes about a minute and a half. Eight is a good deal further and is
/// not attempted here.
class Fewest {
  const Fewest._();

  /// The fewest comparators for [lines], and one network that does it.
  static (int, Sieve)? forLines(int lines, {int giveUpAfter = 20}) =>
      fromHere(Sieve(lines, const []), giveUpAfter: giveUpAfter);

  /// The fewest more that finish a network somebody has started, and one way
  /// of doing it.
  static (int, Sieve)? fromHere(Sieve from, {int giveUpAfter = 20}) {
    final lines = from.lines;
    final start = _outputsOf(from, lines);
    if (_allSorted(start, lines)) return (0, from);

    var edge = <Set<int>, Sieve>{start: from};
    final seen = <String>{_key(start)};

    for (var deep = 1; deep <= giveUpAfter; deep++) {
      final next = <Set<int>, Sieve>{};

      for (final one in edge.entries) {
        for (final cross in Sieve(lines, const []).everyCross) {
          final after = <int>{
            for (final row in one.key) _throughOne(row, cross),
          };
          if (after.length == one.key.length && _same(after, one.key)) {
            continue;
          }
          final sieve = one.value.and(cross);
          if (_allSorted(after, lines)) return (deep, sieve);

          final key = _key(after);
          if (!seen.add(key)) continue;
          next[after] = sieve;
        }
      }
      if (next.isEmpty) return null;
      edge = next;
    }
    return null;
  }

  static Set<int> _outputsOf(Sieve sieve, int lines) => {
        for (var row = 0; row < (1 << lines); row++) sieve.throughBits(row),
      };

  static int _throughOne(int row, Cross cross) {
    final upper = (row >> cross.upper) & 1;
    final lower = (row >> cross.lower) & 1;
    if (upper <= lower) return row;
    return row ^ ((1 << cross.upper) | (1 << cross.lower));
  }

  static bool _allSorted(Set<int> rows, int lines) {
    for (final row in rows) {
      var seenOne = false;
      for (var line = 0; line < lines; line++) {
        final bit = (row >> line) & 1;
        if (bit == 1) {
          seenOne = true;
        } else if (seenOne) {
          return false;
        }
      }
    }
    return true;
  }

  static bool _same(Set<int> one, Set<int> other) =>
      one.length == other.length && one.every(other.contains);

  static String _key(Set<int> rows) {
    final sorted = rows.toList()..sort();
    return sorted.join(',');
  }
}
