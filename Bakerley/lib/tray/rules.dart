/// The law of the tray: gingerbread fours, the five tetrominoes, the
/// bar I, the square O, the tee T, the skew S and the elbow L, laid on a
/// tray of cells to fill it exactly, turned and flipped as you like. A
/// filling is found by laying a four over the first bare cell, top row
/// first, and found again column by column. Chequer the tray and every
/// four but the tee covers two dark and two light cells, while the tee
/// covers three of one and one of the other; so a tray of equal dark and
/// light needs an even count of tees, and one of each of the five fours
/// never fills the five-by-four.
class Rules {
  static const kinds = ['I', 'O', 'T', 'S', 'L'];

  static const kindNames = ['bar', 'square', 'tee', 'skew', 'elbow'];

  /// Each four's cells, in one orientation, as (x, y).
  static const base = <List<(int, int)>>[
    [(0, 0), (1, 0), (2, 0), (3, 0)],
    [(0, 0), (1, 0), (0, 1), (1, 1)],
    [(0, 0), (1, 0), (2, 0), (1, 1)],
    [(1, 0), (2, 0), (0, 1), (1, 1)],
    [(0, 0), (0, 1), (0, 2), (1, 2)],
  ];

  /// The distinct orientations of kind [k], each normalized so its
  /// least x and least y are nought, sorted row-major.
  static List<List<(int, int)>> orientations(int k) => _orientations[k];

  static final _orientations = List.generate(kinds.length, (k) {
    final seen = <String>{};
    final out = <List<(int, int)>>[];
    var cells = base[k];
    for (var turn = 0; turn < 4; turn++) {
      cells = cells.map((c) => (c.$2, -c.$1)).toList();
      for (final flipped in [false, true]) {
        final shape = _normalize(flipped ? cells.map((c) => (-c.$1, c.$2)).toList() : cells);
        final key = shape.toString();
        if (seen.add(key)) out.add(shape);
      }
    }
    return out;
  });

  static List<(int, int)> _normalize(List<(int, int)> cells) {
    final mx = cells.map((c) => c.$1).reduce((a, b) => a < b ? a : b);
    final my = cells.map((c) => c.$2).reduce((a, b) => a < b ? a : b);
    final out = cells.map((c) => (c.$1 - mx, c.$2 - my)).toList()..sort((a, b) => a.$2 != b.$2 ? a.$2 - b.$2 : a.$1 - b.$1);
    return out;
  }

  /// The orientation of [k] got by turning [o] a quarter turn.
  static int turned(int k, int o) => _find(k, _normalize(orientations(k)[o].map((c) => (-c.$2, c.$1)).toList()));

  /// The orientation of [k] got by flipping [o] left to right.
  static int flipped(int k, int o) => _find(k, _normalize(orientations(k)[o].map((c) => (-c.$1, c.$2)).toList()));

  static int _find(int k, List<(int, int)> shape) {
    final key = shape.toString();
    for (var i = 0; i < orientations(k).length; i++) {
      if (orientations(k)[i].toString() == key) return i;
    }
    throw StateError('an orientation that is not there');
  }

  /// The dark cells less the light of a shape laid at (0, 0), chequered.
  static int shade(List<(int, int)> shape) => shape.fold(0, (sum, c) => sum + ((c.$1 + c.$2).isEven ? 1 : -1));

  /// The dark less light totals a bag of fours can make: the tray must
  /// come to one of them.
  static Set<int> shades(List<int> counts) {
    var totals = {0};
    for (var k = 0; k < kinds.length; k++) {
      final options = orientations(k).map(shade).toSet();
      for (var i = 0; i < counts[k]; i++) {
        totals = {for (final t in totals) for (final d in options) t + d};
      }
    }
    return totals;
  }

  /// Whether the chequered colouring allows the bag on a [w] by [h] tray.
  static bool colouringAllows(int w, int h, List<int> counts) {
    var board = 0;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        board += (x + y).isEven ? 1 : -1;
      }
    }
    return shades(counts).contains(board);
  }

  /// Every filling of the [w] by [h] tray by the bag [counts] (one count
  /// a kind): how many, and the first, as (kind, orientation, x, y) with
  /// (x, y) the shape's top left. [byColumns] reads column by column;
  /// [atMost] stops early.
  static (int, List<(int, int, int, int)>?) fillings(int w, int h, List<int> counts, {bool byColumns = false, int? atMost}) {
    final grid = List.generate(h, (_) => List.filled(w, false));
    final left = List.of(counts);
    final placed = <(int, int, int, int)>[];
    var found = 0;
    List<(int, int, int, int)>? first;

    (int, int)? firstBare() {
      if (byColumns) {
        for (var x = 0; x < w; x++) {
          for (var y = 0; y < h; y++) {
            if (!grid[y][x]) return (x, y);
          }
        }
      } else {
        for (var y = 0; y < h; y++) {
          for (var x = 0; x < w; x++) {
            if (!grid[y][x]) return (x, y);
          }
        }
      }
      return null;
    }

    void search() {
      if (atMost != null && found >= atMost) return;
      final bare = firstBare();
      if (bare == null) {
        found++;
        first ??= List.of(placed);
        return;
      }
      final (bx, by) = bare;
      for (var k = 0; k < kinds.length; k++) {
        if (left[k] == 0) continue;
        for (var o = 0; o < orientations(k).length; o++) {
          final shape = orientations(k)[o];
          // The shape's cell that lands on the bare cell: its first cell
          // in the reading order used, so nothing earlier is covered.
          final anchor = byColumns ? shape.reduce((a, b) => a.$1 != b.$1 ? (a.$1 < b.$1 ? a : b) : (a.$2 < b.$2 ? a : b)) : shape.first;
          final x0 = bx - anchor.$1, y0 = by - anchor.$2;
          if (!fits(grid, w, h, shape, x0, y0)) continue;
          for (final c in shape) {
            grid[y0 + c.$2][x0 + c.$1] = true;
          }
          left[k]--;
          placed.add((k, o, x0, y0));
          search();
          placed.removeLast();
          left[k]++;
          for (final c in shape) {
            grid[y0 + c.$2][x0 + c.$1] = false;
          }
        }
      }
    }

    search();
    return (found, first);
  }

  /// Whether [shape] laid with its top left at (x0, y0) lies inside the
  /// tray over bare cells only.
  static bool fits(List<List<bool>> grid, int w, int h, List<(int, int)> shape, int x0, int y0) {
    for (final c in shape) {
      final x = x0 + c.$1, y = y0 + c.$2;
      if (x < 0 || y < 0 || x >= w || y >= h || grid[y][x]) return false;
    }
    return true;
  }

  /// The first move, 'turn' or 'flip', on the shortest way from
  /// orientation [from] to [to] of kind [k]; null when there already.
  static String? firstMove(int k, int from, int to) {
    if (from == to) return null;
    // Breadth first over at most eight orientations.
    final seen = {from: ''};
    var frontier = [from];
    while (frontier.isNotEmpty) {
      final next = <int>[];
      for (final o in frontier) {
        for (final (move, reached) in [('turn', turned(k, o)), ('flip', flipped(k, o))]) {
          if (seen.containsKey(reached)) continue;
          seen[reached] = seen[o]!.isEmpty ? move : seen[o]!;
          if (reached == to) return seen[reached];
          next.add(reached);
        }
      }
      frontier = next;
    }
    return null;
  }
}
