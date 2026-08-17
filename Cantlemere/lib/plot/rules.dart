import 'frac.dart';

/// A square field of nine acres with pegs driven at every whole point of
/// its three by three grid, and the triangular plots their corners make.
///
/// Sizes are kept in half acres so that every one of them is a whole
/// number: a plot's size is twice the area its corners enclose, and the
/// whole field is 18. Nothing here is ever rounded.
class Rules {
  /// The field is three across, so its pegs run 0 to 3 both ways.
  static const side = 3;

  /// The whole field, in half acres.
  static const field = side * side * 2;

  static const pegs = (side + 1) * (side + 1);

  static (int, int) peg(int i) => (i % (side + 1), i ~/ (side + 1));

  static int pegAt(int x, int y) => y * (side + 1) + x;

  /// The colour of a peg, taken from its own two numbers and nothing
  /// else. This is Monsky's colouring pulled back to whole numbers: 1
  /// where the across number is odd, 2 where it is even and the up
  /// number odd, 0 where both are even.
  static int colour(int i) {
    final (x, y) = peg(i);
    if (x.isOdd) return 1;
    return y.isOdd ? 2 : 0;
  }

  /// Twice the area a plot's three corners enclose, always a whole
  /// number and never nothing, since a plot with its corners in a line
  /// is no plot.
  static int halves(List<int> corners) {
    final (ax, ay) = peg(corners[0]);
    final (bx, by) = peg(corners[1]);
    final (cx, cy) = peg(corners[2]);
    final twice = (bx - ax) * (cy - ay) - (by - ay) * (cx - ax);
    return twice < 0 ? -twice : twice;
  }

  /// Whether a plot wears all three colours. Monsky's argument turns on
  /// these: a motley plot always has an odd number of half acres, so it
  /// can never be a whole number of thirds of the field.
  static bool motley(List<int> corners) =>
      {colour(corners[0]), colour(corners[1]), colour(corners[2])}.length == 3;

  /// Every plot the pegs allow, corners in order. The ones whose corners
  /// fall in a line are left out.
  static final List<List<int>> plots = () {
    final out = <List<int>>[];
    for (var a = 0; a < pegs; a++) {
      for (var b = a + 1; b < pegs; b++) {
        for (var c = b + 1; c < pegs; c++) {
          final corners = [a, b, c];
          if (halves(corners) != 0) out.add(corners);
        }
      }
    }
    return out;
  }();

  /// The first voice on whether two plots may lie together: it looks for
  /// a line to separate them, and finds one along an edge of one plot or
  /// the other whenever the two do not overlap. Whole numbers only.
  static bool apart(List<int> one, List<int> two) {
    bool separates(List<int> edged, List<int> other) {
      for (var i = 0; i < 3; i++) {
        final (ax, ay) = peg(edged[i]);
        final (bx, by) = peg(edged[(i + 1) % 3]);
        final dx = bx - ax, dy = by - ay;
        // Which side the plot's own third corner is on, so the test does
        // not care which way round the corners were named.
        final (cx, cy) = peg(edged[(i + 2) % 3]);
        final mine = dx * (cy - ay) - dy * (cx - ax);
        if (mine == 0) continue;
        var all = true;
        for (final p in other) {
          final (px, py) = peg(p);
          final side = dx * (py - ay) - dy * (px - ax);
          // A corner sitting on the line is allowed; only a corner on
          // the same side as the plot's own interior is not.
          if (side == 0) continue;
          if ((side > 0) == (mine > 0)) {
            all = false;
            break;
          }
        }
        if (all) return true;
      }
      return false;
    }

    return separates(one, two) || separates(two, one);
  }

  /// Whether a set of plots cuts the whole field: no two of them overlap
  /// and their half acres come to the field's own 18. That is enough,
  /// since plots that do not overlap and come to the whole area can
  /// leave nothing uncovered.
  static bool cuts(List<List<int>> laid) {
    var total = 0;
    for (var i = 0; i < laid.length; i++) {
      total += halves(laid[i]);
      for (var j = i + 1; j < laid.length; j++) {
        if (!apart(laid[i], laid[j])) return false;
      }
    }
    return total == field;
  }

  // ---------------------------------------------------------------
  // The second voice: the field cut into cells by every line its pegs
  // can draw, so that a plot becomes a set of cells and a cut of the
  // field becomes an exact cover. It works this out for itself rather
  // than being told, and it never touches a decimal.
  // ---------------------------------------------------------------

  /// Every line through two or more pegs, written as across times a plus
  /// up times b equals c, in lowest terms.
  static final List<(int, int, int)> lines = () {
    int gcd(int a, int b) {
      while (b != 0) {
        final t = a % b;
        a = b;
        b = t;
      }
      return a;
    }

    final seen = <(int, int, int)>{};
    for (var i = 0; i < pegs; i++) {
      for (var j = i + 1; j < pegs; j++) {
        final (px, py) = peg(i);
        final (qx, qy) = peg(j);
        var a = qy - py, b = px - qx;
        var c = a * px + b * py;
        var g = gcd(gcd(a.abs(), b.abs()), c.abs());
        if (g == 0) g = 1;
        a ~/= g;
        b ~/= g;
        c ~/= g;
        if (a < 0 || (a == 0 && b < 0)) {
          a = -a;
          b = -b;
          c = -c;
        }
        seen.add((a, b, c));
      }
    }
    return seen.toList()
      ..sort((x, y) => x.$1 != y.$1
          ? x.$1 - y.$1
          : x.$2 != y.$2
              ? x.$2 - y.$2
              : x.$3 - y.$3);
  }();

  /// A point inside each cell the lines cut the field into. They are
  /// found by walking the field in strips between the places where lines
  /// cross, and taking a point in the middle of each gap.
  static final List<(Frac, Frac)> cellPoints = () {
    final xs = <Frac>{Frac.zero, Frac.of(side)};
    for (var i = 0; i < lines.length; i++) {
      for (var j = i + 1; j < lines.length; j++) {
        final (a1, b1, c1) = lines[i];
        final (a2, b2, c2) = lines[j];
        final under = a1 * b2 - a2 * b1;
        if (under == 0) continue;
        final x = Frac(c1 * b2 - c2 * b1, under);
        if (Frac.zero <= x && x <= Frac.of(side)) xs.add(x);
      }
    }
    final across = xs.toList()..sort();
    final out = <(Frac, Frac)>[];
    for (var i = 0; i + 1 < across.length; i++) {
      final x = (across[i] + across[i + 1]) / Frac.of(2);
      final ys = <Frac>{Frac.zero, Frac.of(side)};
      for (final (a, b, c) in lines) {
        if (b == 0) continue;
        final y = (Frac.of(c) - Frac.of(a) * x) / Frac.of(b);
        if (Frac.zero <= y && y <= Frac.of(side)) ys.add(y);
      }
      final up = ys.toList()..sort();
      for (var j = 0; j + 1 < up.length; j++) {
        out.add((x, (up[j] + up[j + 1]) / Frac.of(2)));
      }
    }
    // Two points in the same cell read the same against every line, so
    // one of each reading is kept and the rest thrown away.
    final kept = <String, (Frac, Frac)>{};
    for (final at in out) {
      final reading = StringBuffer();
      for (final (a, b, c) in lines) {
        final where = Frac.of(a) * at.$1 + Frac.of(b) * at.$2 - Frac.of(c);
        reading.write(where.sign > 0 ? '+' : '-');
      }
      kept.putIfAbsent(reading.toString(), () => at);
    }
    return kept.values.toList();
  }();

  static int get cells => cellPoints.length;

  /// Whether a point lies strictly inside a plot.
  static bool holds(List<int> corners, (Frac, Frac) at) {
    var sign = 0;
    for (var i = 0; i < 3; i++) {
      final (ax, ay) = peg(corners[i]);
      final (bx, by) = peg(corners[(i + 1) % 3]);
      final side = Frac.of(bx - ax) * (at.$2 - Frac.of(ay)) -
          Frac.of(by - ay) * (at.$1 - Frac.of(ax));
      final s = side.sign;
      if (s == 0) return false;
      if (sign == 0) {
        sign = s;
      } else if (sign != s) {
        return false;
      }
    }
    return true;
  }

  /// Which cells each plot covers, a bit apiece, worked out once.
  static final List<List<int>> plotCells = () {
    final words = (cells + 63) ~/ 64;
    return [
      for (final corners in plots)
        () {
          final mask = List.filled(words, 0);
          for (var k = 0; k < cells; k++) {
            if (holds(corners, cellPoints[k])) {
              mask[k >> 6] |= 1 << (k & 63);
            }
          }
          return mask;
        }(),
    ];
  }();

  /// The plots that cover a given cell and no earlier one, which is what
  /// the cover walk needs to try.
  static final List<List<int>> plotsFirstAt = () {
    final out = List.generate(cells, (_) => <int>[]);
    for (var p = 0; p < plots.length; p++) {
      final mask = plotCells[p];
      for (var k = 0; k < cells; k++) {
        if (mask[k >> 6] >> (k & 63) & 1 == 1) {
          out[k].add(p);
          break;
        }
      }
    }
    return out;
  }();

  /// Walks every way of cutting the field into plots, taking always the
  /// lowest cell not yet covered and trying each plot that covers it.
  /// [onCut] is handed the plots of each cut as it is found; [most] caps
  /// how many plots a cut may have.
  static void walkCuts(void Function(List<int>) onCut, {int most = 99}) {
    final words = (cells + 63) ~/ 64;
    final covered = List.filled(words, 0);
    final laid = <int>[];
    final full = List.filled(words, 0);
    for (var k = 0; k < cells; k++) {
      full[k >> 6] |= 1 << (k & 63);
    }

    int firstBare() {
      for (var w = 0; w < words; w++) {
        var bare = full[w] & ~covered[w];
        if (bare == 0) continue;
        // The lowest bit set, found by halving rather than by counting,
        // which is what makes the walk quick enough to ship.
        var b = 0;
        if (bare & 0xFFFFFFFF == 0) {
          b += 32;
          bare >>>= 32;
        }
        if (bare & 0xFFFF == 0) {
          b += 16;
          bare >>>= 16;
        }
        if (bare & 0xFF == 0) {
          b += 8;
          bare >>>= 8;
        }
        if (bare & 0xF == 0) {
          b += 4;
          bare >>>= 4;
        }
        if (bare & 0x3 == 0) {
          b += 2;
          bare >>>= 2;
        }
        if (bare & 0x1 == 0) b += 1;
        return (w << 6) | b;
      }
      return -1;
    }

    void step() {
      final k = firstBare();
      if (k < 0) {
        onCut(laid);
        return;
      }
      if (laid.length >= most) return;
      for (final p in plotsFirstAt[k]) {
        final mask = plotCells[p];
        var clash = false;
        for (var w = 0; w < words; w++) {
          if (mask[w] & covered[w] != 0) {
            clash = true;
            break;
          }
        }
        if (clash) continue;
        for (var w = 0; w < words; w++) {
          covered[w] |= mask[w];
        }
        laid.add(p);
        step();
        laid.removeLast();
        for (var w = 0; w < words; w++) {
          covered[w] &= ~mask[w];
        }
      }
    }

    step();
  }

  /// Every cut of the field into a given number of plots, and with all
  /// the plots the same size when [even] is set. Worked out by the cell
  /// walk, which is the voice that never looks at a size.
  static List<List<int>> cutsOf(int pieces, {bool even = false}) {
    final out = <List<int>>[];
    walkCuts((laid) {
      if (laid.length != pieces) return;
      if (even) {
        final first = halves(plots[laid[0]]);
        for (final p in laid) {
          if (halves(plots[p]) != first) return;
        }
      }
      out.add([...laid]);
    }, most: pieces);
    return out;
  }

  /// The colours round the edge of the field, peg by peg, starting at
  /// the corner where both numbers are even and going round.
  static List<int> get rim {
    final walk = <int>[];
    for (var x = 0; x <= side; x++) {
      walk.add(pegAt(x, 0));
    }
    for (var y = 1; y <= side; y++) {
      walk.add(pegAt(side, y));
    }
    for (var x = side - 1; x >= 0; x--) {
      walk.add(pegAt(x, side));
    }
    for (var y = side - 1; y >= 1; y--) {
      walk.add(pegAt(0, y));
    }
    return [for (final p in walk) colour(p)];
  }

  /// How many times the rim steps between the two colours that a motley
  /// plot must have a side between. Monsky's argument needs this to be
  /// odd, and on a field of an odd number of acres it is.
  static int rimSteps() {
    final round = rim;
    var n = 0;
    for (var k = 0; k < round.length; k++) {
      final a = round[k], b = round[(k + 1) % round.length];
      if ((a == 0 && b == 1) || (a == 1 && b == 0)) n++;
    }
    return n;
  }
}
