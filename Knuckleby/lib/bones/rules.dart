/// The law of the bones.
///
/// A die is its faces; a pair of dice is the table of every throw,
/// how often each total falls across all the ways the two can land.
/// Two pairs are the same trade when their tables agree to the last
/// count.
///
/// Which pairs fall like the standard ones is known two ways that
/// share nothing. The sweep recuts every pair of dice there is and
/// compares tables; the factor-trade never rolls at all: a die is a
/// polynomial with a term a face, a pair multiplies to the standard
/// product, and splitting that product's factors two fair-handed
/// ways builds every matching pair directly. The suite proves the
/// two against each other on every bench that ships.
class Rules {
  /// The table of a pair: how often each total falls.
  static Map<int, int> table(List<int> one, List<int> two) {
    final counts = <int, int>{};
    for (final a in one) {
      for (final b in two) {
        counts[a + b] = (counts[a + b] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Whether two tables agree to the last count.
  static bool sameTable(Map<int, int> a, Map<int, int> b) {
    if (a.length != b.length) return false;
    for (final total in a.keys) {
      if (a[total] != b[total]) return false;
    }
    return true;
  }

  /// The standard die of [faces] sides: 1 up to the count.
  static List<int> standard(int faces) =>
      [for (var pip = 1; pip <= faces; pip++) pip];

  /// Every die of [faces] sides with pips from [low] to [high],
  /// faces told nondecreasing.
  static List<List<int>> everyDie(int faces, int low, int high) {
    final dice = <List<int>>[];
    final die = <int>[];

    void cut(int from) {
      if (die.length == faces) {
        dice.add(List.of(die));
        return;
      }
      for (var pip = from; pip <= high; pip++) {
        die.add(pip);
        cut(pip);
        die.removeLast();
      }
    }

    cut(low);
    return dice;
  }

  /// Every pair of dice of [facesOne] and [facesTwo] sides whose
  /// table matches the standard pair's, pips from [low] to [high].
  /// Each pair is told once, sorted.
  static List<(List<int>, List<int>)> matching(
      int facesOne, int facesTwo,
      {int low = 1, int high = 8}) {
    final wanted = table(standard(facesOne), standard(facesTwo));
    final ones = everyDie(facesOne, low, high);
    final twos = facesOne == facesTwo
        ? ones
        : everyDie(facesTwo, low, high);
    final found = <(List<int>, List<int>)>[];
    for (var at = 0; at < ones.length; at++) {
      final start = facesOne == facesTwo ? at : 0;
      for (var other = start; other < twos.length; other++) {
        if (sameTable(table(ones[at], twos[other]), wanted)) {
          found.add((ones[at], twos[other]));
        }
      }
    }
    return found;
  }

  /// The same pairs from the factor-trade, never rolling a die: the
  /// standard product's factors dealt two fair-handed ways. Only
  /// for the benches whose factors are written here.
  static List<(List<int>, List<int>)> byFactors(int faces) {
    // x, x+1, and the cyclotomic pieces of the standard die.
    const x = [0, 1];
    final parts = faces == 4
        ? const [
            [1, 1], // x + 1
            [1, 0, 1], // x^2 + 1
          ]
        : const [
            [1, 1], // x + 1
            [1, 1, 1], // x^2 + x + 1
            [1, -1, 1], // x^2 - x + 1
          ];

    final found = <String, (List<int>, List<int>)>{};
    final shares = List<int>.filled(parts.length, 0);

    void deal(int part) {
      if (part == parts.length) {
        var one = x;
        var two = x;
        for (var at = 0; at < parts.length; at++) {
          for (var copy = 0; copy < shares[at]; copy++) {
            one = _multiply(one, parts[at]);
          }
          for (var copy = 0; copy < 2 - shares[at]; copy++) {
            two = _multiply(two, parts[at]);
          }
        }
        final faceOne = _faces(one);
        final faceTwo = _faces(two);
        if (faceOne == null || faceTwo == null) return;
        if (faceOne.length != faces || faceTwo.length != faces) {
          return;
        }
        final pair = _sorted(faceOne, faceTwo);
        found['${pair.$1} ${pair.$2}'] = pair;
        return;
      }
      for (var share = 0; share <= 2; share++) {
        shares[part] = share;
        deal(part + 1);
      }
    }

    deal(0);
    final pairs = found.values.toList()
      ..sort((a, b) => '${a.$1}'.compareTo('${b.$1}'));
    return pairs;
  }

  static List<int> _multiply(List<int> p, List<int> q) {
    final out = List<int>.filled(p.length + q.length - 1, 0);
    for (var i = 0; i < p.length; i++) {
      for (var j = 0; j < q.length; j++) {
        out[i + j] += p[i] * q[j];
      }
    }
    return out;
  }

  /// A polynomial read back as faces, or null when any count runs
  /// negative and it is no die at all.
  static List<int>? _faces(List<int> poly) {
    final faces = <int>[];
    for (var pip = 0; pip < poly.length; pip++) {
      if (poly[pip] < 0) return null;
      for (var copy = 0; copy < poly[pip]; copy++) {
        faces.add(pip);
      }
    }
    return faces;
  }

  static (List<int>, List<int>) _sorted(List<int> a, List<int> b) {
    final one = List.of(a)..sort();
    final two = List.of(b)..sort();
    if (_compare(one, two) <= 0) return (one, two);
    return (two, one);
  }

  static int _compare(List<int> a, List<int> b) {
    for (var at = 0; at < a.length && at < b.length; at++) {
      if (a[at] != b[at]) return a[at] - b[at];
    }
    return a.length - b.length;
  }
}
