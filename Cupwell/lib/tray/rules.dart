import 'dart:collection';

/// The law of the tray: cups up or down, and every turn turns exactly
/// [each] of them over at once.
class Rules {
  const Rules(this.cups, this.each);

  final int cups;

  /// Cups turned over in one turn, exactly.
  final int each;

  /// A tray as bits: bit i set when cup i is down.
  int get allUp => 0;
  int get allDown => (1 << cups) - 1;

  static int downCount(int tray) {
    var n = 0;
    for (var t = tray; t > 0; t >>= 1) {
      n += t & 1;
    }
    return n;
  }

  /// Every set of [each] cups, as bits.
  List<int> get turns {
    final out = <int>[];
    for (var set = 0; set < (1 << cups); set++) {
      if (downCount(set) == each) out.add(set);
    }
    return out;
  }

  static int turned(int tray, int set) => tray ^ set;

  /// The fewest turns from [from] to all up, by walking every tray a
  /// turn can reach, nearest first; null when all up is out of reach.
  int? fewest(int from) {
    final seen = <int>{from};
    final queue = Queue<(int, int)>()..add((from, 0));
    while (queue.isNotEmpty) {
      final (tray, d) = queue.removeFirst();
      if (tray == allUp) return d;
      for (final set in turns) {
        final next = turned(tray, set);
        if (seen.add(next)) queue.add((next, d + 1));
      }
    }
    return null;
  }

  /// The trays a turn can reach from [from], any number of turns.
  Set<int> reachable(int from) {
    final seen = <int>{from};
    final queue = Queue<int>()..add(from);
    while (queue.isNotEmpty) {
      final tray = queue.removeFirst();
      for (final set in turns) {
        final next = turned(tray, set);
        if (seen.add(next)) queue.add(next);
      }
    }
    return seen;
  }

  /// The sequences of [length] turns from [from], and how many end all
  /// up.
  (int righting, int all) sequences(int from, int length) {
    var righting = 0, all = 0;
    void grow(int tray, int left) {
      if (left == 0) {
        all++;
        if (tray == allUp) righting++;
        return;
      }
      for (final set in turns) {
        grow(turned(tray, set), left - 1);
      }
    }

    grow(from, length);
    return (righting, all);
  }

  /// A turn that brings all up nearer, from [from]: the first set whose
  /// result is one turn closer, or null.
  int? nextTurn(int from) {
    final now = fewest(from);
    if (now == null || now == 0) return null;
    for (final set in turns) {
      final f = fewest(turned(from, set));
      if (f != null && f == now - 1) return set;
    }
    return null;
  }

  /// The parity law: a turn of an even count of cups keeps the count of
  /// down cups odd or even as it was, so an odd count down never comes
  /// all up. Whether that bars [from].
  bool barredByParity(int from) => each.isEven && downCount(from).isOdd;
}
