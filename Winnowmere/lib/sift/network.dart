/// One comparator: it looks at two lines and puts the smaller on the upper of
/// them.
///
/// Which way round the two are written does not matter to what it does, so
/// they are always kept with the upper one first. That way two comparators
/// that do the same thing are the same comparator.
class Cross {
  Cross(int one, int other)
      : upper = one < other ? one : other,
        lower = one < other ? other : one;

  final int upper;
  final int lower;

  @override
  bool operator ==(Object other) =>
      other is Cross && other.upper == upper && other.lower == lower;

  @override
  int get hashCode => Object.hash(upper, lower);

  @override
  String toString() => '$upper-$lower';
}

/// A network: some lines, and comparators in the order they act.
///
/// Everything comes down these lines at once and every comparator does its
/// work in turn. There is nothing else to it: no loops, no conditions and
/// nowhere for a number to go except along the line it is on.
class Sieve {
  Sieve(this.lines, List<Cross> crosses)
      : crosses = List.unmodifiable(crosses);

  final int lines;
  final List<Cross> crosses;

  int get count => crosses.length;

  Sieve get empty => Sieve(lines, const []);

  Sieve and(Cross cross) => Sieve(lines, [...crosses, cross]);

  Sieve without(int which) => Sieve(lines, [
        for (var i = 0; i < crosses.length; i++)
          if (i != which) crosses[i],
      ]);

  /// What comes out when a row of numbers goes in.
  List<int> through(List<int> going) {
    final out = List.of(going);
    for (final cross in crosses) {
      if (out[cross.upper] > out[cross.lower]) {
        final was = out[cross.upper];
        out[cross.upper] = out[cross.lower];
        out[cross.lower] = was;
      }
    }
    return out;
  }

  /// The same, for a row of noughts and ones held as bits: bit 0 is the top
  /// line. This is the one the checking uses, and it is why the checking is
  /// quick.
  int throughBits(int going) {
    var out = going;
    for (final cross in crosses) {
      final upper = (out >> cross.upper) & 1;
      final lower = (out >> cross.lower) & 1;
      if (upper > lower) {
        out ^= (1 << cross.upper) | (1 << cross.lower);
      }
    }
    return out;
  }

  /// Every place a comparator could go.
  List<Cross> get everyCross => [
        for (var upper = 0; upper < lines; upper++)
          for (var lower = upper + 1; lower < lines; lower++)
            Cross(upper, lower),
      ];
}
