/// One field: what it is called, and which squares of the map it covers.
class Field {
  Field(this.name, this.squares);

  final String name;

  /// Every square it takes up, as (column, row).
  final List<(int, int)> squares;
}

/// An estate map: fields, and which of them share a hedge.
///
/// A map is written down as a grid of letters, one letter per field, and a
/// full stop where there is no field at all. Two fields share a hedge when a
/// square of one is directly above, below, beside a square of the other. That
/// is the only thing the game needs to know about the shape of the land, and
/// it comes straight off the picture rather than being listed separately, so
/// the two can never disagree.
class Land {
  Land({
    required this.name,
    required List<String> rows,
    Map<String, String> called = const {},
  })  : rows = List.unmodifiable(rows),
        wide = rows.first.length,
        tall = rows.length {
    for (final row in rows) {
      if (row.length != wide) {
        throw ArgumentError('the rows of $name are not the same length');
      }
    }

    // Fields are numbered by where their letter first appears, reading the
    // map the way anybody reads it.
    final order = <String>[];
    for (final row in rows) {
      for (final letter in row.split('')) {
        if (letter != '.' && !order.contains(letter)) order.add(letter);
      }
    }
    letters = List.unmodifiable(order);

    fields = List.unmodifiable([
      for (final letter in order)
        Field(called[letter] ?? letter, [
          for (var row = 0; row < tall; row++)
            for (var column = 0; column < wide; column++)
              if (rows[row][column] == letter) (column, row),
        ]),
    ]);

    _touching = List.generate(count, (_) => <int>{});
    for (var row = 0; row < tall; row++) {
      for (var column = 0; column < wide; column++) {
        final here = at(column, row);
        if (here < 0) continue;
        for (final (across, down) in const [(1, 0), (0, 1)]) {
          final there = at(column + across, row + down);
          if (there < 0 || there == here) continue;
          _touching[here].add(there);
          _touching[there].add(here);
        }
      }
    }
  }

  final String name;

  /// The map as it was written down.
  final List<String> rows;

  final int wide;
  final int tall;

  late final List<String> letters;
  late final List<Field> fields;
  late final List<Set<int>> _touching;

  int get count => fields.length;

  /// The field covering a square, or -1 for a square outside the estate.
  int at(int column, int row) {
    if (column < 0 || row < 0 || column >= wide || row >= tall) return -1;
    final letter = rows[row][column];
    return letter == '.' ? -1 : letters.indexOf(letter);
  }

  /// Whether two fields share a hedge.
  bool touches(int one, int other) => _touching[one].contains(other);

  Set<int> beside(int field) => _touching[field];

  /// Every pair of fields that share a hedge, once each.
  List<(int, int)> get hedges => [
        for (var one = 0; one < count; one++)
          for (final other in _touching[one])
            if (other > one) (one, other),
      ];

  /// Whether a painting is a proper one: nothing left unpainted, and no two
  /// fields that share a hedge in the same dye.
  bool isProper(List<int> dyes) {
    if (dyes.length != count) return false;
    for (var field = 0; field < count; field++) {
      if (dyes[field] < 0) return false;
      for (final other in _touching[field]) {
        if (dyes[field] == dyes[other]) return false;
      }
    }
    return true;
  }
}
