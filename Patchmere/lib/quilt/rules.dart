/// A two-patch: two neighbouring cells of the quilt, the smaller
/// cell first.
typedef Patch = (int, int);

/// One quilt of so many rows and columns, and the law of Cram on it:
/// sew a two-patch on any two free neighbouring cells, and whoever
/// sews last wins.
class Quilt {
  Quilt(this.rows, this.cols) : patches = _patches(rows, cols);

  final int rows;
  final int cols;

  /// Every place a two-patch can go, across and down.
  final List<Patch> patches;

  int get cells => rows * cols;

  int cell(int r, int c) => r * cols + c;
  int rowOf(int cell) => cell ~/ cols;
  int colOf(int cell) => cell % cols;

  static List<Patch> _patches(int rows, int cols) => [
        for (var r = 0; r < rows; r++)
          for (var c = 0; c + 1 < cols; c++) (r * cols + c, r * cols + c + 1),
        for (var r = 0; r + 1 < rows; r++)
          for (var c = 0; c < cols; c++) (r * cols + c, (r + 1) * cols + c),
      ];

  /// The count the arithmetic gives: rows times gaps across, plus
  /// columns times gaps down.
  int get patchesByArithmetic => rows * (cols - 1) + cols * (rows - 1);

  bool free(int sewn, int cell) => (sewn >> cell) & 1 == 0;

  bool fits(int sewn, Patch patch) => free(sewn, patch.$1) && free(sewn, patch.$2);

  List<Patch> moves(int sewn) => [for (final p in patches) if (fits(sewn, p)) p];

  int sew(int sewn, Patch patch) => sewn | (1 << patch.$1) | (1 << patch.$2);

  /// The cell across the middle of the quilt from [cell].
  int across(int cell) => (rows - 1 - rowOf(cell)) * cols + (cols - 1 - colOf(cell));

  /// The patch across the middle from [patch].
  Patch mirror(Patch patch) {
    final a = across(patch.$1), b = across(patch.$2);
    return a < b ? (a, b) : (b, a);
  }

  /// The patches that are their own mirror: none on an even-by-even
  /// or odd-by-odd quilt, exactly one when one side is odd.
  List<Patch> get selfMirrored => [for (final p in patches) if (mirror(p) == p) p];

  /// The middle patch, where exactly one side is odd; null otherwise.
  Patch? get middle => selfMirrored.length == 1 ? selfMirrored.first : null;

  final _wins = <int, bool>{};

  /// Whether the sewer to move wins with best play.
  bool moverWins(int sewn) {
    final known = _wins[sewn];
    if (known != null) return known;
    var wins = false;
    for (final p in patches) {
      if (fits(sewn, p) && !moverWins(sew(sewn, p))) {
        wins = true;
        break;
      }
    }
    _wins[sewn] = wins;
    return wins;
  }

  /// The patches that win from here.
  List<Patch> winningMoves(int sewn) => [
        for (final p in patches)
          if (fits(sewn, p) && !moverWins(sew(sewn, p))) p,
      ];

  /// A picture of the quilt for the eye: dots free, hashes sewn.
  String picture(int sewn) => [
        for (var r = 0; r < rows; r++)
          [for (var c = 0; c < cols; c++) free(sewn, cell(r, c)) ? '.' : '#'].join(),
      ].join('/');
}
