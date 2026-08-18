/// Six guests and the trestle tables they sit at.
///
/// A seating is which guests share a table, and nothing more: the tables
/// have no names and no order, so moving everybody from the near trestle
/// to the far one changes nothing. A seating is kept as a list of tables,
/// each a list of guests, sorted so that one seating is written one way
/// only.
///
/// Everything here is counting. There is no arithmetic beyond adding and
/// multiplying whole numbers.
class Rules {
  /// Guests at the supper.
  static const guests = 6;

  static String name(int guest) => String.fromCharCode(65 + guest);

  /// A seating written down one way only: each table sorted, and the
  /// tables ordered by their first guest.
  static List<List<int>> tidy(List<List<int>> seating) {
    final out = [
      for (final table in seating)
        if (table.isNotEmpty) ([...table]..sort())
    ];
    out.sort((a, b) => a.first - b.first);
    return out;
  }

  static String write(List<List<int>> seating) =>
      tidy(seating).map((t) => t.map(name).join()).join(' ');

  /// The first voice: every way of seating the guests, written out one
  /// by one. The last guest either joins a table already laid or has a
  /// trestle of their own, which is how the walk is built and also the
  /// whole of the second voice's reasoning.
  static List<List<List<int>>> seatings([int? howMany]) {
    final n = howMany ?? guests;
    if (n == 0) return [<List<int>>[]];
    final out = <List<List<int>>>[];
    for (final rest in seatings(n - 1)) {
      for (var i = 0; i < rest.length; i++) {
        out.add([
          for (var j = 0; j < rest.length; j++)
            if (j == i) [...rest[j], n - 1] else [...rest[j]],
        ]);
      }
      out.add([
        for (final table in rest) [...table],
        [n - 1],
      ]);
    }
    return out;
  }

  /// The second voice, which seats nobody. The ways of putting n guests
  /// at exactly k tables come to k times the ways for one guest fewer at
  /// k tables, plus the ways for one guest fewer at k tables less one:
  /// the last guest either joins one of the k tables or starts the new
  /// one. That is Stirling's counting of the second kind.
  static int byRecurrence(int n, int k) {
    if (k < 0 || k > n) return 0;
    final rows = List.generate(n + 1, (_) => List.filled(n + 1, 0));
    rows[0][0] = 1;
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= i; j++) {
        rows[i][j] = j * rows[i - 1][j] + rows[i - 1][j - 1];
      }
    }
    return rows[n][k];
  }

  /// The ways of seating n guests at any number of tables, which is the
  /// row added up. Bell counted these.
  static int allWays(int n) {
    var total = 0;
    for (var k = 1; k <= n; k++) {
      total += byRecurrence(n, k);
    }
    return n == 0 ? 1 : total;
  }

  /// The sizes of the tables in a seating, smallest first.
  static List<int> sizes(List<List<int>> seating) =>
      [for (final table in seating) table.length]..sort();

  /// Whether no two tables hold the same number.
  static bool allDifferent(List<List<int>> seating) =>
      sizes(seating).toSet().length == seating.length;

  /// Whether nobody is sitting on their own.
  static bool nobodyAlone(List<List<int>> seating) {
    for (final table in seating) {
      if (table.length < 2) return false;
    }
    return seating.isNotEmpty;
  }

  /// The fewest guests that would let [tables] tables all hold different
  /// numbers, which is 1 and 2 and 3 and so on added up. This is the
  /// whole of the last ask's reason, and it needs no seating at all.
  static int fewestFor(int tables) => tables * (tables + 1) ~/ 2;

  /// Which table each guest is at, for a seating.
  static List<int> seatOf(List<List<int>> seating) {
    final out = List.filled(guests, 0);
    final tidied = tidy(seating);
    for (var t = 0; t < tidied.length; t++) {
      for (final g in tidied[t]) {
        out[g] = t;
      }
    }
    return out;
  }

  /// The seating that comes of putting each guest at the table named in
  /// [seatOf], with empty tables dropped.
  static List<List<int>> fromSeats(List<int> seats) {
    final most = seats.reduce((a, b) => a > b ? a : b);
    final tables = List.generate(most + 1, (_) => <int>[]);
    for (var g = 0; g < seats.length; g++) {
      tables[seats[g]].add(g);
    }
    return tidy(tables);
  }
}
