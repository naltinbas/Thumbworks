import 'dart:typed_data';

import 'lock.dart';

/// How every code marks against every other, worked out once.
///
/// A few thousand codes means a few million pairs, which is a table of a few
/// megabytes and a fraction of a second to fill. Everything after it — the
/// solver, the proof that no code takes more than so many guesses — is
/// lookups instead of arithmetic, and that is the difference between a proof
/// that runs in a second and one that runs in an hour.
class Marks {
  Marks._(this.lock, this._table);

  /// A table somebody else worked out, which is how one comes back from
  /// another isolate.
  factory Marks.from(Lock lock, Uint8List table) => Marks._(lock, table);

  factory Marks.of(Lock lock) {
    final codes = lock.codes;
    final table = Uint8List(codes * codes);
    for (var code = 0; code < codes; code++) {
      final row = code * codes;
      // A code marks itself as all right, and marking is the same both ways
      // round, so only half the table is worked out and the other half is
      // copied.
      for (var guess = code; guess < codes; guess++) {
        final mark = lock.markOf(code, guess).asOne(lock);
        table[row + guess] = mark;
        table[guess * codes + code] = mark;
      }
    }
    return Marks._(lock, table);
  }

  final Lock lock;
  final Uint8List _table;

  /// The table itself, for handing over.
  Uint8List get table => _table;

  /// The mark, as one number, of [guess] against [code].
  int at(int code, int guess) => _table[code * lock.codes + guess];

  /// The mark that means the lock is open.
  late final int allRight = Mark(lock.pegs, 0).asOne(lock);

  /// How much room a partition of marks needs.
  late final int width = Mark(lock.pegs, 0).asOne(lock) + 1;

  /// The codes in [from] that would have been marked the same way.
  ///
  /// This is the whole of what a player knows: not what the code is, but which
  /// codes are still consistent with everything they have been told.
  Int32List narrow(Int32List from, int guess, int mark) {
    final kept = Int32List(from.length);
    var found = 0;
    for (var i = 0; i < from.length; i++) {
      if (at(from[i], guess) == mark) kept[found++] = from[i];
    }
    return Int32List.sublistView(kept, 0, found);
  }

  /// Every code, to start from.
  Int32List get everything =>
      Int32List.fromList([for (var code = 0; code < lock.codes; code++) code]);
}

/// Works a table out, for handing back from another isolate.
///
/// A top level function taking one plain value, because that is what can be
/// started on an isolate of its own.
Uint8List tableFor((int, int) shape) =>
    Marks.of(Lock(pegs: shape.$1, colours: shape.$2)).table;
