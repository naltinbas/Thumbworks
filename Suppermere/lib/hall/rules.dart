import 'dart:collection';

/// A quarrel between two guests, the smaller number first.
typedef Quarrel = (int, int);

/// The law of the hall: guests who quarrel may not share a table, and
/// there are two tables.
class Rules {
  const Rules(this.guests, this.quarrels);

  final int guests;
  final List<Quarrel> quarrels;

  static const left = 0;
  static const right = 1;

  /// The quarrels that put two guests at one table, given tables by
  /// guest with -1 for standing.
  List<Quarrel> clashes(List<int> tables) => [
        for (final (a, b) in quarrels)
          if (tables[a] >= 0 && tables[a] == tables[b]) (a, b),
      ];

  bool seated(List<int> tables) => tables.every((t) => t >= 0);

  bool lands(List<int> tables) => seated(tables) && clashes(tables).isEmpty;

  /// Every seating of the guests, two tables apiece: 2^guests of them.
  void seatings(void Function(List<int>) visit) {
    for (var bits = 0; bits < (1 << guests); bits++) {
      visit([for (var g = 0; g < guests; g++) (bits >> g) & 1]);
    }
  }

  /// The sweep: seatings with no quarrel at a table, and seatings in all.
  (int, int) sweep() {
    var landing = 0, all = 0;
    seatings((t) {
      all++;
      if (lands(t)) landing++;
    });
    return (landing, all);
  }

  List<List<int>> get _neighbours {
    final out = List.generate(guests, (_) => <int>[]);
    for (final (a, b) in quarrels) {
      out[a].add(b);
      out[b].add(a);
    }
    return out;
  }

  /// A seating built with no sweep, guest by guest: the first guest of
  /// each party sits left, and every quarreller of a seated guest sits
  /// across; null when that puts a quarreller at the same table, which
  /// happens exactly when an odd ring of quarrels runs through them.
  List<int>? byWalking() {
    final tables = List.filled(guests, -1);
    final near = _neighbours;
    for (var start = 0; start < guests; start++) {
      if (tables[start] >= 0) continue;
      tables[start] = left;
      final queue = Queue<int>()..add(start);
      while (queue.isNotEmpty) {
        final g = queue.removeFirst();
        for (final h in near[g]) {
          if (tables[h] < 0) {
            tables[h] = 1 - tables[g];
            queue.add(h);
          } else if (tables[h] == tables[g]) {
            return null;
          }
        }
      }
    }
    return tables;
  }

  /// An odd ring of quarrels, as the guests round it, or null when there
  /// is none: found by walking, the two ends of a clashing quarrel traced
  /// back to where their walks met.
  List<int>? oddRing() {
    final near = _neighbours;
    final tables = List.filled(guests, -1);
    final parent = List.filled(guests, -1);
    for (var start = 0; start < guests; start++) {
      if (tables[start] >= 0) continue;
      tables[start] = left;
      final queue = Queue<int>()..add(start);
      while (queue.isNotEmpty) {
        final g = queue.removeFirst();
        for (final h in near[g]) {
          if (tables[h] < 0) {
            tables[h] = 1 - tables[g];
            parent[h] = g;
            queue.add(h);
          } else if (tables[h] == tables[g]) {
            // Trace both back to their meeting.
            final up = <int>[g];
            final down = <int>[h];
            var x = g, y = h;
            final seen = <int>{g};
            while (x != -1) {
              x = parent[x];
              if (x != -1) {
                up.add(x);
                seen.add(x);
              }
            }
            while (!seen.contains(y)) {
              y = parent[y];
              down.add(y);
            }
            final meet = y;
            final ring = <int>[];
            for (final u in up) {
              ring.add(u);
              if (u == meet) break;
            }
            final back = down.sublist(0, down.length - 1).reversed.toList();
            ring.addAll(back);
            return ring;
          }
        }
      }
    }
    return null;
  }

  /// The parties: guests joined by quarrels, however far.
  int get parties {
    final near = _neighbours;
    final seen = List.filled(guests, false);
    var n = 0;
    for (var start = 0; start < guests; start++) {
      if (seen[start]) continue;
      n++;
      final queue = Queue<int>()..add(start);
      seen[start] = true;
      while (queue.isNotEmpty) {
        final g = queue.removeFirst();
        for (final h in near[g]) {
          if (!seen[h]) {
            seen[h] = true;
            queue.add(h);
          }
        }
      }
    }
    return n;
  }
}
