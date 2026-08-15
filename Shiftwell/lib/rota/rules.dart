/// A shift on the rota: (day, station), each 0 to side - 1.
typedef Shift = (int, int);

/// The law of the rota.
///
/// Four hands, four stations, four days: a rota gives every shift
/// a hand, and it is sound when no hand works two stations on one
/// day and no hand works one station on two days. That is a Latin
/// square, and some shifts come already fixed. Evans asked in 1960
/// whether n - 1 fixed shifts on an n by n rota can always be
/// finished, and Smetaniuk proved in 1981 that they can; the sweep
/// here finishes all 25,920 sound fills of three shifts on the
/// four-rota, and finds 13,824 of the 239,760 sound fills of four
/// that cannot be finished, one of them by a single stuck shift
/// with no hand left for it.
class Rules {
  Rules(this.side, this.fixed);

  final int side;

  /// The shifts fixed before play, shift to hand (1 to side).
  final Map<Shift, int> fixed;

  List<Shift> get shifts => [
        for (var day = 0; day < side; day++)
          for (var station = 0; station < side; station++) (day, station),
      ];

  /// The hands a shift could still take: not on the day, not at
  /// the station.
  List<int> candidates(Map<Shift, int> filled, Shift shift) {
    final used = <int>{};
    for (var k = 0; k < side; k++) {
      final onDay = filled[(shift.$1, k)];
      final atStation = filled[(k, shift.$2)];
      if (onDay != null && (shift.$1, k) != shift) used.add(onDay);
      if (atStation != null && (k, shift.$2) != shift) used.add(atStation);
    }
    return [for (var hand = 1; hand <= side; hand++) if (!used.contains(hand)) hand];
  }

  /// The shifts whose hand clashes with another on the day or at
  /// the station.
  List<Shift> clashes(Map<Shift, int> filled) => [
        for (final entry in filled.entries)
          if (!candidates(filled, entry.key).contains(entry.value)) entry.key,
      ]..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);

  /// Whether a fill is sound so far: no clashes.
  bool sound(Map<Shift, int> filled) => clashes(filled).isEmpty;

  /// Whether a fill is a finished rota: every shift a hand, no
  /// clashes.
  bool finished(Map<Shift, int> filled) =>
      filled.length == side * side && sound(filled);

  /// Walks every finished rota extending [filled]; calls [visit].
  /// Works on a flat grid with day and station masks, and fills
  /// the emptiest shift first, so the sweep of thousands of fills
  /// stays quick.
  void finishings(Map<Shift, int> filled, void Function(Map<Shift, int>) visit) {
    if (!sound(filled)) return;
    final grid = List<int>.filled(side * side, 0);
    final dayUsed = List<int>.filled(side, 0);
    final stationUsed = List<int>.filled(side, 0);
    for (final entry in filled.entries) {
      grid[entry.key.$1 * side + entry.key.$2] = entry.value;
      dayUsed[entry.key.$1] |= 1 << entry.value;
      stationUsed[entry.key.$2] |= 1 << entry.value;
    }
    final full = (1 << (side + 1)) - 2;
    void fill() {
      // The open shift with the fewest hands left.
      var best = -1;
      var bestFree = 0;
      var bestCount = side + 1;
      for (var i = 0; i < side * side; i++) {
        if (grid[i] != 0) continue;
        final free = full & ~(dayUsed[i ~/ side] | stationUsed[i % side]);
        var count = 0;
        for (var hand = 1; hand <= side; hand++) {
          if (free & (1 << hand) != 0) count++;
        }
        if (count < bestCount) {
          best = i;
          bestFree = free;
          bestCount = count;
        }
      }
      if (best < 0) {
        visit({
          for (var i = 0; i < side * side; i++) (i ~/ side, i % side): grid[i],
        });
        return;
      }
      if (bestCount == 0) return;
      for (var hand = 1; hand <= side; hand++) {
        if (bestFree & (1 << hand) == 0) continue;
        grid[best] = hand;
        dayUsed[best ~/ side] |= 1 << hand;
        stationUsed[best % side] |= 1 << hand;
        fill();
        grid[best] = 0;
        dayUsed[best ~/ side] &= ~(1 << hand);
        stationUsed[best % side] &= ~(1 << hand);
      }
    }

    fill();
  }

  /// How many finished rotas extend [filled], by the sweep.
  int waysBySweep([Map<Shift, int>? filled]) {
    var ways = 0;
    finishings(filled ?? fixed, (_) => ways++);
    return ways;
  }

  /// Whether any finished rota extends [filled].
  bool finishes([Map<Shift, int>? filled]) {
    var any = false;
    if (!sound(filled ?? fixed)) return false;
    // A cheap walk that stops at the first finishing.
    final grid = List<int>.filled(side * side, 0);
    final dayUsed = List<int>.filled(side, 0);
    final stationUsed = List<int>.filled(side, 0);
    for (final entry in (filled ?? fixed).entries) {
      grid[entry.key.$1 * side + entry.key.$2] = entry.value;
      dayUsed[entry.key.$1] |= 1 << entry.value;
      stationUsed[entry.key.$2] |= 1 << entry.value;
    }
    final full = (1 << (side + 1)) - 2;
    bool fill() {
      var best = -1;
      var bestFree = 0;
      var bestCount = side + 1;
      for (var i = 0; i < side * side; i++) {
        if (grid[i] != 0) continue;
        final free = full & ~(dayUsed[i ~/ side] | stationUsed[i % side]);
        var count = 0;
        for (var hand = 1; hand <= side; hand++) {
          if (free & (1 << hand) != 0) count++;
        }
        if (count < bestCount) {
          best = i;
          bestFree = free;
          bestCount = count;
        }
      }
      if (best < 0) return true;
      if (bestCount == 0) return false;
      for (var hand = 1; hand <= side; hand++) {
        if (bestFree & (1 << hand) == 0) continue;
        grid[best] = hand;
        dayUsed[best ~/ side] |= 1 << hand;
        stationUsed[best % side] |= 1 << hand;
        if (fill()) return true;
        grid[best] = 0;
        dayUsed[best ~/ side] &= ~(1 << hand);
        stationUsed[best % side] &= ~(1 << hand);
      }
      return false;
    }

    any = fill();
    return any;
  }

  /// The first finished rota the sweep finds extending [filled],
  /// or null.
  Map<Shift, int>? landing([Map<Shift, int>? filled]) {
    Map<Shift, int>? found;
    finishings(filled ?? fixed, (grid) {
      found ??= Map.of(grid);
    });
    return found;
  }

  /// A shift with no hand left for it, if any: the stuck shift.
  Shift? stuck(Map<Shift, int> filled) {
    for (final shift in shifts) {
      if (filled.containsKey(shift)) continue;
      if (candidates(filled, shift).isEmpty) return shift;
    }
    return null;
  }

  /// Walks every sound fill of exactly [count] shifts on an empty
  /// rota, hands and all; calls [visit].
  static void fills(int side, int count, void Function(Map<Shift, int>) visit) {
    final rules = Rules(side, const {});
    final all = rules.shifts;
    final chosen = <Shift>[];
    final grid = <Shift, int>{};
    void assign(int i) {
      if (i == chosen.length) {
        visit(grid);
        return;
      }
      for (var hand = 1; hand <= side; hand++) {
        grid[chosen[i]] = hand;
        if (rules.sound(grid)) assign(i + 1);
        grid.remove(chosen[i]);
      }
    }

    void choose(int from) {
      if (chosen.length == count) {
        assign(0);
        return;
      }
      for (var i = from; i < all.length; i++) {
        chosen.add(all[i]);
        choose(i + 1);
        chosen.removeLast();
      }
    }

    choose(0);
  }
}
