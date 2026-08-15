/// A yard of wrestlers, every pair having met once: [threw] holds
/// (a, b) when a threw b.
class Yard {
  Yard(this.size, Iterable<(int, int)> bouts) : threw = bouts.toSet();

  /// The yard as bits: pair (a, b) with a < b is bit number
  /// pairIndex(a, b), set when a threw b.
  factory Yard.fromBits(int size, int bits) {
    final bouts = <(int, int)>[];
    for (var a = 0; a < size; a++) {
      for (var b = a + 1; b < size; b++) {
        bouts.add((bits >> pairIndex(a, b)) & 1 == 1 ? (a, b) : (b, a));
      }
    }
    return Yard(size, bouts);
  }

  final int size;
  final Set<(int, int)> threw;

  static int pairIndex(int a, int b) => b * (b - 1) ~/ 2 + a;

  static int pairs(int size) => size * (size - 1) ~/ 2;

  bool beat(int a, int b) => threw.contains((a, b));

  /// Whether every pair met once and only once.
  bool get sound {
    if (threw.length != pairs(size)) return false;
    for (var a = 0; a < size; a++) {
      for (var b = a + 1; b < size; b++) {
        if (beat(a, b) == beat(b, a)) return false;
      }
    }
    return true;
  }

  /// How many each threw.
  List<int> get scores => [for (var a = 0; a < size; a++) [for (var b = 0; b < size; b++) if (beat(a, b)) b].length];

  /// Whether a line stands: each threw the next.
  bool chainHolds(List<int> line) {
    for (var i = 0; i + 1 < line.length; i++) {
      if (!beat(line[i], line[i + 1])) return false;
    }
    return true;
  }

  /// Whether a line closes into a ring: a chain whose last threw the first.
  bool ringHolds(List<int> line) =>
      line.length == size && chainHolds(line) && beat(line.last, line.first);

  /// Every ordering of the yard, visited in turn.
  void orderings(void Function(List<int>) visit) {
    final line = <int>[];
    final used = List.filled(size, false);
    void grow() {
      if (line.length == size) {
        visit(line);
        return;
      }
      for (var w = 0; w < size; w++) {
        if (used[w]) continue;
        used[w] = true;
        line.add(w);
        grow();
        line.removeLast();
        used[w] = false;
      }
    }

    grow();
  }

  /// The orderings that are chains, and those that close into rings.
  (int chains, int rings) count() {
    var chains = 0, rings = 0;
    orderings((line) {
      if (chainHolds(line)) {
        chains++;
        if (beat(line.last, line.first)) rings++;
      }
    });
    return (chains, rings);
  }

  /// The first ordering that lands, chain or ring, or null.
  List<int>? landing({required bool ring}) {
    List<int>? found;
    orderings((line) {
      if (found == null && (ring ? ringHolds(line) : chainHolds(line))) found = List.of(line);
    });
    return found;
  }

  /// Redei's chain, built with no search: take the wrestlers one at a
  /// time and slot each in front of the first in the line he threw,
  /// or at the end if he threw nobody there. Whoever stood before that
  /// place threw him, since he did not throw them.
  List<int> insertion() {
    final line = <int>[];
    for (var w = 0; w < size; w++) {
      var at = line.length;
      for (var i = 0; i < line.length; i++) {
        if (beat(w, line[i])) {
          at = i;
          break;
        }
      }
      line.insert(at, w);
    }
    return line;
  }

  /// Whether every wrestler can reach every other along throws.
  bool get strong {
    for (var start = 0; start < size; start++) {
      final seen = List.filled(size, false);
      final stack = [start];
      seen[start] = true;
      while (stack.isNotEmpty) {
        final a = stack.removeLast();
        for (var b = 0; b < size; b++) {
          if (!seen[b] && beat(a, b)) {
            seen[b] = true;
            stack.add(b);
          }
        }
      }
      if (seen.contains(false)) return false;
    }
    return true;
  }

  /// A wrestler nobody threw, if there is one.
  int? get champion {
    for (var a = 0; a < size; a++) {
      if ([for (var b = 0; b < size; b++) if (beat(b, a)) b].isEmpty) return a;
    }
    return null;
  }
}
