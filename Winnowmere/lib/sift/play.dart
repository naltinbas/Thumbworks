import 'network.dart';
import 'noughts.dart';
import 'puzzles.dart';

/// A network being built.
class Play {
  const Play._(this.sifting, this.sieve, this.changes);

  factory Play.of(Sifting sifting) => Play._(sifting, sifting.start, 0);

  final Sifting sifting;
  final Sieve sieve;

  /// How many comparators have been put in or taken out.
  final int changes;

  int get lines => sifting.lines;
  int get count => sieve.count;

  /// The comparators that were there at the start and cannot be taken out.
  int get given => sifting.given.length;

  /// How many more than the fewest are in.
  int get over => count - sifting.fewest;

  /// The first row of noughts and ones that comes out unsorted, or null.
  int? get fails => Noughts.fails(sieve);

  /// How many of the 2^n rows come out sorted.
  int get right => Noughts.right(sieve);

  int get rows => 1 << lines;

  bool get isDone => fails == null;

  /// Whether it sorts in the fewest there is.
  bool get isTight => isDone && count == sifting.fewest;

  /// This network with a comparator added at the end.
  Play add(int one, int other) {
    if (one == other) return this;
    if (one < 0 || other < 0 || one >= lines || other >= lines) return this;
    return Play._(sifting, sieve.and(Cross(one, other)), changes + 1);
  }

  /// This network with one taken out. The ones it started with stay.
  Play take(int which) {
    if (which < given || which >= sieve.count) return this;
    return Play._(sifting, sieve.without(which), changes + 1);
  }

  Play get again => Play.of(sifting);

  /// What a row of noughts and ones comes out as, as words.
  String outOf(int row) => Noughts.words(sieve.throughBits(row), lines);

  String wordsOf(int row) => Noughts.words(row, lines);
}
